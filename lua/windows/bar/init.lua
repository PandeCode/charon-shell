local astal = require("astal")
local Widget = require("astal.gtk3.widget")
local Variable = astal.Variable
local GLib = astal.require("GLib")
local bind = astal.bind
local Battery = astal.require("AstalBattery")
local Network = astal.require("AstalNetwork")
local Tray = astal.require("AstalTray")

local Niri = require("lua.extras.niri")

local Media = require("lua.windows.bar.media")
local Volume = require("lua.windows.bar.volume")

local map = require("lua.utils").map

local elements = require("lua.extras.elements")
local img = elements.img
local btn = elements.btn

local function Logo()
	return Widget.Button({
		on_clicked = require("lua.windows.console"),
		img("./media/nixos.png", 1, 1),
	})
end

local function SysTray()
	local tray = Tray.get_default()

	return Widget.Box({
		class_name = "SysTray",
		bind(tray, "items"):as(function(items)
			return map(items, function(item)
				return Widget.MenuButton({
					tooltip_markup = bind(item, "tooltip_markup"),
					use_popover = false,
					menu_model = bind(item, "menu-model"),
					action_group = bind(item, "action-group"):as(function(ag)
						return { "dbusmenu", ag }
					end),
					Widget.Icon({
						gicon = bind(item, "gicon"),
					}),
				})
			end)
		end),
	})
end

local function Wifi()
	local network = Network.get_default()
	local wifi = bind(network, "wifi")

	return Widget.Box({
		visible = wifi:as(function(v)
			return v ~= nil
		end),
		wifi:as(function(w)
			return Widget.Icon({
				tooltip_text = bind(w, "ssid"):as(tostring),
				class_name = "Wifi",
				icon = bind(w, "icon-name"),
			})
		end),
	})
end

local function BatteryLevel()
	local bat = Battery.get_default()

	return Widget.Box({
		class_name = "Battery",
		visible = bind(bat, "is-present"),
		Widget.Icon({
			icon = bind(bat, "battery-icon-name"),
		}),
		Widget.Label({
			label = bind(bat, "percentage"):as(function(p)
				return tostring(math.floor(p * 100)) .. " %"
			end),
		}),
	})
end

local function Time(format)
	local time = Variable(""):poll(1000, function()
		return GLib.DateTime.new_now_local():format(format)
	end)

	return Widget.Label({
		class_name = "Time",
		on_destroy = function()
			time:drop()
		end,
		label = time(),
	})
end

return function(gdkmonitor)
	local Anchor = astal.require("Astal").WindowAnchor

	return Widget.Window({
		class_name = "Bar",
		gdkmonitor = gdkmonitor,
		anchor = Anchor.TOP + Anchor.LEFT + Anchor.RIGHT,
		exclusivity = "EXCLUSIVE",
		Widget.CenterBox({
			Widget.Box({
				halign = "START",
				Logo(),
				Niri.Workspaces(),
				Niri.FocusedClient(),
			}),
			Widget.Box({
				Media(),
			}),
			Widget.Box({
				halign = "END",
				css = "padding-right: 15px",
				SysTray(),
				Wifi(),
				Volume(),
				BatteryLevel(),
				Time("%T %a %d %b %y"),
				Widget.Button({
					css = "all: unset",
					on_clicked = require("lua.windows.center"),
					Widget.Icon({
						icon = "open-menu",
					}),
				}),
			}),
		}),
	})
end
