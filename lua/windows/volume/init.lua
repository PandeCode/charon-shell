local astal = require "astal"
local Astal = astal.require "Astal"
local Gtk = require("astal.gtk3").Gtk
local Widget = require "astal.gtk3.widget"
local GLib = astal.require "GLib"
local Anchor = astal.require("Astal").WindowAnchor
local bind = astal.bind
local Wp = astal.require "AstalWp"
local utils = require "lua.utils"
local utils_a = require "lua.utils.astal"

local elements = require "lua.extras.elements"
local div = elements.div
local divv = elements.divv
local p = elements.p
local btni = elements.btni
local btn = elements.btn
local i = elements.i

local mute_btn = function(endpoint)
	return btni(
		bind(endpoint, "volume-icon"),
		bind(endpoint, "mute"):as(function(m)
			return "mute-button" .. (m and " muted" or "") .. " rounded-lg"
		end),
		function()
			endpoint:set_mute(not endpoint:get_mute())
		end
	)
end

local audio_percent = function(endpoint)
	return p(bind(endpoint, "volume"):as(function(v)
		return string.format("%.0f%%", tostring(v * 100))
	end))
end

local audio_slider = function(endpoint)
	return Widget.Slider {
		class_name = bind(endpoint, "mute"):as(function(m)
			return "volume-slider" .. (m and " muted" or "")
		end),
		hexpand = true,
		value = bind(endpoint, "volume"),
		on_dragged = function(self)
			endpoint:set_volume(self.value)
		end,
	}
end

local mk_line = function(source)
	return divv(
		{
			div {
				Widget.Box {
					hexpand = true,
					spacing = 10,
					bind(source, "icon"):as(function(v)
						if v == nil then
							return v
						end
						local _ = "-symbolic"
						if v:sub(-#_) == _ then
							return i(v)
						end
						return i(v .. _)
					end),
					p(bind(source, "name"), nil, { tooltip_text = bind(source, "path") }),
					p(bind(source, "description"):as(function(d)
						return "(" .. d .. ")"
					end)),
					p(bind(source, "media-class")),
				},
			},
			div(
				{
					div { mute_btn(source) },
					audio_slider(source),
					audio_percent(source),
				},
				nil,
				{
					spacing = 10,
				}
			),
		},
		"border-none shadow-lg m-2 p-2 rounded-lg bg-base00-90",
		{
			hexpand = true,
			spacing = 10,
		}
	)
end

local function mk_revealer(s, audio)
	return Widget.Revealer {
		child = bind(audio, s):as(function(l)
			return #l > 0 and divv(utils.map(l, function(e)
				return mk_line(e)
			end)) or p("No " .. s)
		end),
		reveal_child = true,
		transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN,
		transition_duration = 500,
	}
end

local function VolWindow()
	local WpAudio = Wp.get_default()
	local speaker = WpAudio:get_default_speaker()
	local microphone = WpAudio:get_default_microphone()

	local audio = WpAudio:get_audio()

	local r1 = mk_revealer("speakers", audio)
	local r2 = mk_revealer("streams", audio)

	return divv(
		{
			mk_line(speaker),
			Widget.EventBox {
				on_button_press_event = function()
					r1.reveal_child = not r1.reveal_child
				end,
				class_name = "transparent",
				div {
					p "Speakers",
					i "go-down-symbolic",
				},
			},
			r1,
			Widget.EventBox {
				on_button_press_event = function()
					r2.reveal_child = not r2.reveal_child
				end,
				class_name = "transparent",
				div {
					p "Audio Streams",
					i "go-down-symbolic",
				},
			},
			r2,
			p "Microphones",
			mk_line(microphone),
		},
		"audio-sliders bg-base00-75 m-2 p-2 rounded-lg border-solid border-2 border-base04-90",
		{

			css = "min-width: 500px;",
			spacing = 8,
		}
	)
end

return utils_a.mkPopupToggleAnim(VolWindow, {
	anchor = Anchor.TOP + Anchor.RIGHT,
	class_name = "tranparent",
})
