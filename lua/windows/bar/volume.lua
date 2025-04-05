local astal = require("astal")
local Widget = require("astal.gtk3.widget")
local Wp = astal.require("AstalWp")
local bind = astal.bind

return function()
	local speaker = Wp.get_default().audio.default_speaker

	return Widget.Button({
		class_name = "AudioSlider",
		on_clicked = require("lua.windows.volume"),
		css = "all: unset; padding: 5px;",
		Widget.Icon({
			icon = bind(speaker, "volume-icon"),
		}),
	})
end
