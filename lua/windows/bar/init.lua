local logger = require "lua.logger"
logger.global.debug "Creating Bar Require"

local astal = require "astal"
local Widget = require "astal.gtk3.widget"
local Variable = astal.Variable
local GLib = astal.require "GLib"
local Gtk = require("astal.gtk3").Gtk
local astalify = require("astal.gtk3").astalify
local bind = astal.bind
local Astal = astal.require "Astal"
local Battery = astal.require "AstalBattery"
local Network = astal.require "AstalNetwork"
local Tray = astal.require "AstalTray"

local Hyprland = require "lua.extras.hyprland"
local utf8 = require "lua-utf8"

local Media = require "lua.windows.bar.media"
local Volume = require "lua.windows.bar.volume"

local toCSS = require("lua.extras.tailwind").toCSS

local utils = require "lua.utils"
local utils_astal = require "lua.utils.astal"
local map = utils.map

local elements = require "lua.extras.elements"
local img = elements.img

local btn = elements.btn
local btni = elements.btni
local div = elements.div
local divv = elements.divv
local i = elements.i
local p = elements.p

local react = require "tslib.react"

-- require("ts.windows.stats").default()

local function Logo()
	local btn = div(
		Widget.EventBox {
			on_button_press_event = function(obj, evn)
				if evn.button == 1 then
					require("ts.windows.start").default()
				elseif evn.button == 2 then
					astal.exec_async "swaync-client -t -sw"
				elseif evn.button == 3 then
					require("ts.windows.stats").default()
				end
			end,
			class_name = "transparent",
			img("./media/nix.svg", 1, 1),
		},
		"p-2",
		{
			halign = "CENTER",
			valign = "CENTER",
		}
	)

	local progress = Astal.CircularProgress {
		value = 0,
		visible = true,
		rounded = true,
		class_name = "m-2 text-base0B",
		css = "font-size: 3px;",
		width = 34,
	}

	local overlay = Widget.Overlay {
		progress,
		btn,
	}
	local time = 0
	local running = false

	astal.interval(5000, function()
		astal.exec_async("bash -c 'pidof nix; echo $?'", function(out)
			if out ~= "1" then
				if running then
					return
				end
				running = true
				GLib.timeout_add(GLib.PRIORITY_DEFAULT, 42, function()
					if running then
						if time > 1 then
							time = 0
						end
						time = time + 0.042

						local start_angle = time
						local end_angle = start_angle + 1

						progress:set_value(math.sin(time * 10))
						progress:set_start_at(start_angle)
						progress:set_end_at(end_angle)
						return true
					else
						if time ~= 0 then
							time = 0
							progress.class_name = "m-2"
						end
						running = false
						return false
					end
				end)
			end
			running = false
		end)
	end)

	return overlay
end

local function SysTray()
	local tray = Tray.get_default()
	local child = Widget.Box {
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

	local r = Widget.Revealer {
		child = child,
		reveal_child = false,
		transition_type = Gtk.RevealerTransitionType.SLIDE_LEFT,
		transition_duration = 500,
	}

	local show, setShow = table.unpack(react.useVariable(false, function(v)
		return v and "go-next-symbolic" or "go-previous-symbolic"
	end))

	return Widget.Box {
		btni(show, "w-2 h-2 transparent rounded-full", function()
			r.reveal_child = not r.reveal_child
			setShow(r.reveal_child)
		end),
		r,
	}
end

local function Wifi()
	local network = Network.get_default()
	local wifi = bind(network, "wifi")

	local ping = Variable("#000000 NaN 0"):poll(5000, "ping.sh")

	return Widget.Button {
		on_destroy = function()
			ping:drop()
		end,
		class_name = "transparent",
		visible = wifi:as(function(v)
			return v ~= nil
		end),
		on_clicked = function(_, e)
			require("ts.windows.network").default()
		end,
		div({

			wifi:as(function(w)
				return Widget.Icon {
					tooltip_text = bind(w, "ssid"):as(tostring),
					class_name = "Wifi",
					icon = bind(w, "icon-name"),
				}
			end),
			ping(function(out)
				local color, icon, num = table.unpack(utils.split(out, " "))
				return p(num, nil, { css = "color: " .. color .. "" })
			end),
		}, nil, { spacing = 10 }),
	}
end

local function BatteryLevel()
	local bat = Battery.get_default()

	local battery_to_text = utils.mk_threshold_func({
		{ 0.8, "text-base0B" },
		{ 0.5, "text-base0A" },
		{ 0.2, "text-base0C" },
	}, "text-base0F")

	return Widget.EventBox {
		Widget.Box {
			visible = bind(bat, "is-present"),
			tooltip_text = bind(bat, "percentage"):as(function(percentage)
				local info = {
					"Percentage: " .. string.format("%.1f%%", percentage * 100),
					"State: " .. bat:get_state(),
					"Time to Empty: " .. (function()
						local secs = bat:get_time_to_empty()
						if secs > 0 then
							local hrs = math.floor(secs / 3600)
							local mins = math.floor((secs % 3600) / 60)
							return string.format("%dh %dm", hrs, mins)
						else
							return "N/A"
						end
					end)(),
					"Time to Full: " .. (function()
						local secs = bat:get_time_to_full()
						if secs > 0 then
							local hrs = math.floor(secs / 3600)
							local mins = math.floor((secs % 3600) / 60)
							return string.format("%dh %dm", hrs, mins)
						else
							return "N/A"
						end
					end)(),
					"Energy Now: " .. string.format("%.2fWh", bat:get_energy()),
					"Energy Full: " .. string.format("%.2fWh", bat:get_energy_full()),
				}
				return table.concat(info, "\n")
			end),
			Widget.Overlay {
				bind(bat, "percentage"):as(function(per)
					return Astal.CircularProgress {
						value = per,
						visible = true,
						rounded = true,
						class_name = "m-2 " .. battery_to_text(per),
						css = "font-size: 3px;",
						width = 34,
					}
				end),
				Widget.Icon {
					icon = bind(bat, "battery-icon-name"),
				},
			},
		},
		on_button_press_event = function(_, e)
			if e.button == 1 then
				require("ts.windows.power").default()
			end
		end,
	}
end

local function Time()
	local formats = {
		"%d/%m/%Y %H:%M",
		"%T %a %d %b %y", -- 24-hour time Day Date Month Year
		"%I:%M:%S %p - %A", -- 12-hour time with AM/PM and full day
		"%d/%m/%Y %H:%M", -- European style date and 24-hour time
		"%B %d, %Y - %I:%M %p", -- Month name Day, Year - 12-hour time
		"%Y-%m-%d %H:%M:%S", -- ISO 8601-ish
		"It's %A, the %d of %B!", -- Fun sentence style
		-- "Week %U - %H:%M:%S", -- Week number with time
		-- "Today: %x — Now: %X", -- Local date and time format
	}
	local format = 1

	local tooltip = Variable ""
	local time = Variable(""):poll(1000, function()
		tooltip:set(GLib.DateTime.new_now_local():format(formats[7]))
		return GLib.DateTime.new_now_local():format(formats[format])
	end)

	return Widget.EventBox {
		on_button_press_event = function(obj, evn)
			if evn.button == 3 then
				(require "ts.windows.time").default()
			else
				format = format % #formats + 1
				time:set(GLib.DateTime.new_now_local():format(formats[format]))
			end
		end,
		Widget.Label {
			on_destroy = function()
				time:drop()
			end,
			class_name = "transition",
			label = time(),
			tooltip_text = tooltip(),
		},
	}
end

local function Workspaces()
	if utils.getWM() == "niri" then
		return (require "lua.extras.niri").Workspaces()
	elseif utils.getWM() == "Hyprland" then
		return Hyprland.Workspaces()
	else
		return p "Workspaces (no wm)"
	end
end

local function WindowName()
	local child = nil
	local niri = false

	if utils.getWM() == "niri" then
		child = (require "lua.extras.niri").FocusedClient()
		niri = true
	elseif utils.getWM() == "Hyprland" then
		child = Hyprland.FocusedClient()
	else
		return p "Window Name (no wm)"
	end

	local r = Widget.Revealer {
		child = child,
		reveal_child = false,
		transition_type = Gtk.RevealerTransitionType.SLIDE_RIGHT,
		transition_duration = 500,
	}

	local show, setShow = table.unpack(react.useVariable(false, function(v)
		return v and "go-previous-symbolic" or "go-next-symbolic"
	end))

	return Widget.Box {
		r,
		btni(show, "transparent", function()
			r.reveal_child = not r.reveal_child
			setShow(r.reveal_child)
			if niri then
				if r.reveal_child then
					(require "lua.extras.niri").var_focused_window:start_poll()
				else
					(require "lua.extras.niri").var_focused_window:stop_poll()
				end
			end
		end, nil, { pixel_size = 1 }),
	}
end

return function(gdkmonitor)
	-- local main_box = nil and utils_astal.loadGlade "glade/sample.glade"
	-- main_box,

	local Anchor = astal.require("Astal").WindowAnchor

	logger.global.debug "Bar Created"
	return Widget.Window {
		class_name = "transparent",
		gdkmonitor = gdkmonitor,
		anchor = Anchor.TOP + Anchor.LEFT + Anchor.RIGHT,
		exclusivity = "EXCLUSIVE",
		Widget.CenterBox {
			class_name = "mx-2 py-2 rounded-lg transparent",
			Widget.Box {
				halign = "START",
				Logo(),
				Workspaces(),
				WindowName(),
				class_name = "py-1 rounded-lg bg-base00-90",
			},
			Media(),
			Widget.Box {
				class_name = "rounded-lg bg-base00-90",
				halign = "END",
				css = "padding-right: 15px",
				SysTray(),
				Wifi(),
				Volume(),
				BatteryLevel(),
				-- require("ts.windows.bar.stats").default(),
				Time(),
				btni("open-menu-symbolic", "transparent", function()
					require("ts.windows.center").default()
				end),
			},
		},
	}
end
