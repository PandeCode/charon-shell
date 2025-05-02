local astal = require "astal"
local Widget = require "astal.gtk3.widget"
local Cava = require "lua.windows.bar.cava"

local el = require "lua.extras.elements"
local img = el.img
local p = el.p

local lyrics = astal.Variable(""):poll(2000, "lyrics-line.sh", function(out, _)
	return out
end)

local art = astal.Variable(""):poll(2000, "album_art.sh", function(out, _)
	return out
end)

return function()
	local c = Cava {
		effect_type = "bars", -- Options: "bars", "wave", "particles", "circular"
		color = { 0.2, 0.6, 0.86, 0.8 }, -- Main color (R,G,B,A)
		wave_color = { 0.3, 0.8, 0.4, 0.8 }, -- Wave effect color
		particle_color = { 0.9, 0.3, 0.2, 0.7 }, -- Particle effect color
		mirror = false, -- Enable mirror effect (for bars and wave)
		bars = 32, -- Number of bars/sample points
	}

	local m = Widget.Box {
		Widget.Box {
			art(function(p_)
				return img(p_, 1.2, 1.2, "rounded-xl")
			end),
			lyrics(function(txt)
				return p(txt, "pl-1 text-base0A")
			end),
		},
		css = "min-width: 200px;",
	}
	local center = Widget.EventBox {
		Widget.Overlay {
			m,
			c,
		},
		on_button_press_event = require "lua.windows.player",
	}

	return center
end
