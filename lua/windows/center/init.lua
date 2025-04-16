local astal = require "astal"
local Gtk = require("astal.gtk3").Gtk
local Widget = require "astal.gtk3.widget"
local Gdk = require("astal.gtk3").Gdk
local Anchor = astal.require("Astal").WindowAnchor
local bind = astal.bind
local utils = require "lua.utils"
local ps = require "lua.utils.ps"
local logger = require "lua.logger"
local toCSS = require("lua.extras.tailwind").toCSS

local elements = require "lua.extras.elements"
local div = elements.div
local divv = elements.divv
local p = elements.p
local btni = elements.btni
local vscroll = elements.vscroll
local btn = elements.btn

local fn_exe = utils.fn_exe

local btnc = function(txt, fn)
	return elements.btn(
		txt,
		"bg-base01 text-base04 font-bold border-solid border-2 border-base04 px-4 m-1 rounded-full hover-bg-base04 hover-text-base00",
		fn
	)
end

local function CenterWindow()
	return Widget.Box {
		vertical = true,
		css = toCSS { minWidth = "30rem" },
		class_name = "bg-base00-90 rounded-lg m-2 p-2 border-solid border-base03-50 border-2",
		divv {
			Gtk.Grid {
				btnc("Dark Mode", function()
					astal.exec "theme.sh dark"
					ps.restart(3)
				end),
				btnc("Light Mode", function()
					astal.exec "theme.sh light"
					ps.restart(3)
				end),
			},
			Gtk.Grid {
				btnc("Rand Bg", fn_exe "bg.sh rand"),
				btnc("Last Bg", fn_exe "bg.sh last"),
				btnc("Next Bg", fn_exe "bg.sh next"),
				btnc("Prev Bg", fn_exe "bg.sh prev"),
				btnc("Reset Bg", fn_exe "bg.sh reset"),
			},
		},
	}
end

local utils_a = require "lua.utils.astal"
return utils_a.mkPopupToggleAnim(
	CenterWindow,
	{ title = "Center", anchor = Anchor.TOP + Anchor.RIGHT + Anchor.BOTTOM, class_name = "transparent" },
	{
		-- Gtk.RevealerTransitionType.SLIDE_LEFT,
		transition_type = Gtk.RevealerTransitionType.SLIDE_RIGHT,
	}
)
