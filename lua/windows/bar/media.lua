local astal = require("astal")
local Widget = require("astal.gtk3.widget")

local lyrics = astal.Variable(""):poll(2000, "lyrics-line.sh", function(out, _)
	return out
end)
local art = astal.Variable(""):poll(2000, "album_art.sh", function(out, _)
	return out
end)

return function()
	return Widget.Button({
		class_name = "Media",
		on_clicked = require("lua.windows.player"),
		css = "background: none; color: white ",
		Widget.Box({
			art(function(p)
				return Widget.Box({
					class_name = "Cover",
					valign = "CENTER",
					css = "background-image: url('" .. (p or "") .. "');",
				})
			end),
			lyrics(function(p)
				return Widget.Label({ label = p })
			end),
		}),
	})
end
