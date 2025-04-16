local astal = require "astal"
local Widget = require "astal.gtk3.widget"
local Variable = astal.Variable
local GLib = astal.require "GLib"
local Gtk = require("astal.gtk3").Gtk
local bind = astal.bind
local Battery = astal.require "AstalBattery"
local Network = astal.require "AstalNetwork"
local Tray = astal.require "AstalTray"

local Niri = require "lua.extras.niri"

local Media = require "lua.windows.bar.media"
local Volume = require "lua.windows.bar.volume"
local Cava = require "lua.windows.bar.cava"

local toCSS = require("lua.extras.tailwind").toCSS

local utils = require "lua.utils"
local utils_astal = require "lua.utils.astal"
local map = utils.map

local elements = require "lua.extras.elements"
local img = elements.img

local btn = elements.btn

local function Logo()
	return Widget.Button {
		on_clicked = require "lua.windows.console",
		class_name = "transparent",
		img("./media/nixos.png", 1, 1),
	}
end
local function Calender()
	return elements.btni("x-office-calendar-symbolic", nil, require "lua.windows.calender")
end

local function SysTray()
	local tray = Tray.get_default()

	return Widget.Box {
		class_name = "SysTray",
		bind(tray, "items"):as(function(items)
			return map(items, function(item)
				return Widget.MenuButton {
					tooltip_markup = bind(item, "tooltip_markup"),
					use_popover = false,
					class_name = "transparent",
					menu_model = bind(item, "menu-model"),
					action_group = bind(item, "action-group"):as(function(ag)
						return { "dbusmenu", ag }
					end),
					Widget.Icon {
						gicon = bind(item, "gicon"),
					},
				}
			end)
		end),
	}
end

local function Wifi()
	local network = Network.get_default()
	local wifi = bind(network, "wifi")

	return Widget.Button {
		class_name = "transparent",
		visible = wifi:as(function(v)
			return v ~= nil
		end),
		on_clicked = function()
			require "lua.windows.network"()
		end,
		wifi:as(function(w)
			return Widget.Icon {
				tooltip_text = bind(w, "ssid"):as(tostring),
				class_name = "Wifi",
				icon = bind(w, "icon-name"),
			}
		end),
	}
end

local function BatteryLevel()
	local bat = Battery.get_default()

	return Widget.Box {
		class_name = "Battery",
		visible = bind(bat, "is-present"),
		Widget.Icon {
			icon = bind(bat, "battery-icon-name"),
		},
		Widget.Label {
			label = bind(bat, "percentage"):as(function(p)
				return tostring(math.floor(p * 100)) .. " %"
			end),
		},
	}
end

local function Time(format)
	local time = Variable(""):poll(1000, function()
		return GLib.DateTime.new_now_local():format(format)
	end)

	return Widget.Label {
		class_name = "Time",
		on_destroy = function()
			time:drop()
		end,
		label = time(),
	}
end

return function(gdkmonitor)
	local Anchor = astal.require("Astal").WindowAnchor

	local c = Cava {
		effect_type = "bars", -- Options: "bars", "wave", "particles", "circular"
		color = { 0.2, 0.6, 0.86, 0.8 }, -- Main color (R,G,B,A)
		wave_color = { 0.3, 0.8, 0.4, 0.8 }, -- Wave effect color
		particle_color = { 0.9, 0.3, 0.2, 0.7 }, -- Particle effect color
		mirror = false, -- Enable mirror effect (for bars and wave)
		bars = 32, -- Number of bars/sample points
	}
	local m = Widget.Box { Media(), css = "min-width: 200px;" }
	local center = Widget.EventBox {
		Widget.Overlay {
			m,
			c,
		},
		on_button_press_event = require "lua.windows.player",
	}

	-- css = "all: unset;",
	-- }

	-- local main_box = nil and utils_astal.loadGlade "glade/sample.glade"
	-- main_box,

	return Widget.Window {
		class_name = "transparent",
		gdkmonitor = gdkmonitor,
		anchor = Anchor.TOP + Anchor.LEFT + Anchor.RIGHT,
		exclusivity = "EXCLUSIVE",
		Widget.CenterBox {
			class_name = "m-1 rounded-lg bg-base00-90",
			Widget.Box {
				halign = "START",
				Logo(),
				Niri.Workspaces(),
				Niri.FocusedClient(),
			},
			center,
			Widget.Box {
				halign = "END",
				css = "padding-right: 15px",
				SysTray(),
				Wifi(),
				Volume(),
				BatteryLevel(),
				Time "%T %a %d %b %y",
				Widget.Button {
					class_name = "bg-base00 hover-bg-base01",
					on_clicked = require "lua.windows.center",
					Widget.Icon {
						icon = "open-menu-symbolic",
					},
				},
			},
		},
	}
end
