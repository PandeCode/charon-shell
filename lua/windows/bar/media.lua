local astal = require "astal"
local Widget = require "astal.gtk3.widget"
local toCSS = require("lua.extras.tailwind").toCSS

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
	return Widget.Box {
		art(function(p_)
			return img(p_, 1.2, 1.2, "rounded-xl")
		end),
		lyrics(function(txt)
			return p(txt, "pl-1 text-base0A")
		end),
	}
end
