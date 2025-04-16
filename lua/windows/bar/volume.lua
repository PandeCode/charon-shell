local astal = require("astal")
local Gdk = require("astal.gtk3").Gdk
local Wp = astal.require("AstalWp")
local bind = astal.bind

local utils = require("lua.utils")

local damping = -0.4

local el = require("lua.extras.elements")
local btni = el.btni
return function()
	local speaker = Wp.get_default().audio.default_speaker
	local b = btni(bind(speaker, "volume-icon"), "transparent", require("lua.windows.volume"), {
		tooltip_text = bind(speaker, "volume"):as(function(v)
			return v and tostring(math.floor(v * 100)) .. "%" or "Error getting volume"
		end),
		on_scroll_event = function(_, event)
			if event.direction == "SMOOTH" then
				print(string.format("Smooth scroll: delta_x=%.2f delta_y=%.2f", event.delta_x, event.delta_y))
				if math.abs(event.delta_y) > 0 then
					print("Smooth: Scrolled Down")
					speaker:set_volume(math.max(0, math.min(speaker:get_volume() + damping * event.delta_y, 1)))
				end
			else
				print("Event is not a scroll event or direction is nil.")
			end
			return true
		end,
	})

	-- b:add_events(Gdk.EventMask.SCROLL_MASK)
	return b
end
