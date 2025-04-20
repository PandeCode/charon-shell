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
local utf8 = require "lua-utf8"

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
local btni = elements.btni
local div = elements.div
local divv = elements.divv
local i = elements.i
local p = elements.p

local react = require "tslib.react"

-- require("ts.windows.stats").default()

local function Logo()
	local btn = Widget.Button {
		-- on_clicked = require "lua.windows.console",
		on_clicked = function()
			require("ts.windows.stats").default()
		end,
		class_name = "transparent",
		img("./media/nix.svg", 1, 1),
	}
	local fixed = Gtk.Fixed {
		visible = true,
	}
	fixed:add(btn)

	local angle = 0
	local time = 0

	local nixRunning = astal.Variable(false):poll(5000, "bash -c 'pidof nix; echo $?'", function(out)
		if out == "1" then
			return false
		else
			return true
		end
	end)

	astal.interval(42, function()
		if nixRunning:get() then
			time = time + 0.042
			angle = angle + 2 -- Spin
			local x = math.sin(time * 10) * 10 -- Shake (left-right)
			-- local y =  math.sin(time * 2) * 10 -- Bob (up-down)
			fixed:move(btn, x, 0)
		else
			fixed:move(btn, 0, 0)
		end
		return true
	end)

	return fixed
end
local function Calender()
	return elements.btni("x-office-calendar-symbolic", nil, require "lua.windows.calender")
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

	local show, setShow = table.unpack(react.useState(false, function(v)
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
				return tostring(math.floor(p * 100))
			end),
		},
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
		on_button_press_event = function()
			format = format % #formats + 1
			time:set(GLib.DateTime.new_now_local():format(formats[format]))
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

local function WindowName()
	local child = Niri.FocusedClient()
	local r = Widget.Revealer {
		child = child,
		reveal_child = false,
		transition_type = Gtk.RevealerTransitionType.SLIDE_RIGHT,
		transition_duration = 500,
	}

	local show, setShow = table.unpack(react.useState(false, function(v)
		return v and "go-previous-symbolic" or "go-next-symbolic"
	end))

	return Widget.Box {
		r,
		btni(show, "transparent", function()
			r.reveal_child = not r.reveal_child
			setShow(r.reveal_child)
			if r.reveal_child then
				Niri.var_focused_window:start_poll()
			else
				Niri.var_focused_window:stop_poll()
			end
		end, nil, { pixel_size = 1 }),
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
			class_name = "m-1 mr-0 rounded-lg transparent",
			Widget.Box {
				halign = "START",
				Logo(),
				Niri.Workspaces(),
				WindowName(),
				class_name = "m-1 pr-2 rounded-lg bg-base00-90",
			},
			center,
			Widget.Box {
				class_name = "m-1 mr-0 rounded-lg bg-base00-90",
				halign = "END",
				css = "padding-right: 15px",
				SysTray(),
				Wifi(),
				Volume(),
				BatteryLevel(),
				require("ts.windows.bar.stats").default(),
				Time(),
				btni("open-menu-symbolic", "transparent", function()
					require("ts.windows.center").default()
				end),
			},
		},
	}
end
