local astal = require "astal"
local Astal = astal.require "Astal"
local Widget = require "astal.gtk3.widget"
local Gdk = require("astal.gtk3").Gdk
local Wp = astal.require "AstalWp"
local bind = astal.bind

local utils = require "lua.utils"

local damping = -0.4

local el = require "lua.extras.elements"
local btni = el.btni

local volume_to_text = utils.mk_threshold_func({
	{ 0.7, "text-base05" },
	{ 0.4, "text-base03" },
	{ 0.1, "text-base01" },
}, "text-base00")

return function()
	local speaker = Wp.get_default().audio.default_speaker
	local b = btni(bind(speaker, "volume-icon"), "transparent", require "lua.windows.volume", {
		tooltip_text = bind(speaker, "volume"):as(function(v)
			return v and tostring(math.floor(v * 100)) .. "%" or "Error getting volume"
		end),
		on_scroll_event = function(_, event)
			if event.direction == "SMOOTH" then
				print(string.format("Smooth scroll: delta_x=%.2f delta_y=%.2f", event.delta_x, event.delta_y))
				if math.abs(event.delta_y) > 0 then
					print "Smooth: Scrolled Down"
					speaker:set_volume(math.max(0, math.min(speaker:get_volume() + damping * event.delta_y, 1)))
				end
			else
				print "Event is not a scroll event or direction is nil."
			end
			return true
		end,
	})

	return Widget.Box {
		Widget.Overlay {
			bind(speaker, "volume"):as(function(per)
				return Astal.CircularProgress {
					value = per,
					visible = true,
					rounded = true,
					class_name = "m-2 " .. volume_to_text(per),
					css = "font-size: 3px;",
					width = 34,
				}
			end),
			b,
		},
	}
end
