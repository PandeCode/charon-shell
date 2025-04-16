local astal = require "astal"
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
				Widget.CenterBox {
					hexpand = true,
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
					p(bind(source, "name")),
					audio_percent(source),
				},
			},
			div {
				div({ mute_btn(source) }, "pr-2"),
				audio_slider(source),
			},
		},
		"border-solid border-base04-90 border-2 shadow-lg m-2 p-2 rounded-lg bg-base00-90",
		{
			hexpand = true,
		}
	)
end

local function VolWindow()
	local WpAudio = Wp.get_default()
	local speaker = WpAudio:get_default_speaker()
	local microphone = WpAudio:get_default_microphone()

	local r1 = Widget.Revealer {
		child = divv(utils.map(WpAudio:get_audio():get_speakers(), function(e)
			return mk_line(e)
		end)),
		reveal_child = false,
		transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN,
		transition_duration = 500,
	}
	local r2 = Widget.Revealer {
		child = divv(utils.map(WpAudio:get_audio():get_streams(), function(e)
			return mk_line(e)
		end)),
		reveal_child = false,
		transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN,
		transition_duration = 500,
	}

	return divv(
			{
				mk_line(speaker),
				div {
					p "Speakers",
					btni("go-down-symbolic", nil, function()
						r1.reveal_child = not r1.reveal_child
					end),
				},
				r1,
				div {
					p "Audio Streams",
					btni("go-down-symbolic", nil, function()
						r2.reveal_child = not r2.reveal_child
					end),
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
