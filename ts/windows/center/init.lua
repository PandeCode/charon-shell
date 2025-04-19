--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local ____react = require("tslib.react")
local astal = ____react.astal
local Gtk = ____react.Gtk
local Elements = ____react.Elements
local Astal = ____react.Astal
local ps = require("lua.utils.ps")
local Anchor = Astal.WindowAnchor
local ____require_result_0 = require("lua.utils.astal")
local mkPopupToggleAnim = ____require_result_0.mkPopupToggleAnim
local ____require_result_1 = require("lua.utils.init")
local inspect = ____require_result_1.inspect
local notify = ____require_result_1.notify
local function fexe(cmd)
    return function() return astal.exec_async(cmd) end
end
local function fbexe(cmd)
    return function() return astal.exec_async({"bash", "-c", cmd}) end
end
local function Center()
    return Elements.Create(
        "div",
        {vertical = true, css = {minWidth = "30em"}, spacing = 10, className = "bg-base00-90  m-4 p-4 rounded-lg border-base03-90 border-solid border-2"},
        Elements.Create(
            "scrollable",
            {hscrollbar_policy = Gtk.PolicyType.NEVER, vscrollbar_policy = Gtk.PolicyType.AUTOMATIC, className = "border-none"},
            Elements.Create(
                "div",
                {vertical = true, spacing = 9, className = "p-2"},
                Elements.Create("div", {vexpand = true}),
                Elements.Create(
                    "button",
                    {
                        width = 200,
                        halign = "CENTER",
                        onClick = fexe("bg.sh rand")
                    },
                    "Rand Bg"
                ),
                Elements.Create(
                    "button",
                    {onClick = fexe("bg.sh rand")},
                    "Rand Bg"
                ),
                Elements.Create(
                    "button",
                    {onClick = fexe("bg.sh rand")},
                    "Rand Bg"
                ),
                Elements.Create(
                    "button",
                    {onClick = fexe("bg.sh rand")},
                    "Rand Bg"
                ),
                Elements.Create(
                    "button",
                    {onClick = fexe("bg.sh rand")},
                    "Rand Bg"
                ),
                Elements.Create(
                    "button",
                    {onClick = fexe("bg.sh rand")},
                    "Rand Bg"
                ),
                Elements.Create(
                    "button",
                    {onClick = fexe("bg.sh rand")},
                    "Rand Bg"
                ),
                Elements.Create(
                    "button",
                    {onClick = fexe("bg.sh rand")},
                    "Rand Bg"
                ),
                Elements.Create(
                    "button",
                    {onClick = fexe("bg.sh rand")},
                    "Rand Bg"
                ),
                Elements.Create(
                    "button",
                    {onClick = fexe("bg.sh rand")},
                    "Rand Bg"
                ),
                Elements.Create(
                    "button",
                    {onClick = fexe("bg.sh rand")},
                    "Rand Bg"
                ),
                Elements.Create(
                    "button",
                    {onClick = fexe("bg.sh rand")},
                    "Rand Bg"
                ),
                Elements.Create(
                    "button",
                    {onClick = fexe("bg.sh rand")},
                    "Rand Bg"
                ),
                Elements.Create(
                    "button",
                    {onClick = fexe("bg.sh rand")},
                    "Rand Bg"
                ),
                Elements.Create(
                    "button",
                    {onClick = fexe("bg.sh rand")},
                    "Rand Bg"
                ),
                Elements.Create(
                    "button",
                    {onClick = fexe("bg.sh rand")},
                    "Rand Bg"
                ),
                Elements.Create(
                    "button",
                    {onClick = fexe("bg.sh rand")},
                    "Rand Bg"
                ),
                Elements.Create(
                    "button",
                    {onClick = fexe("bg.sh rand")},
                    "Rand Bg"
                ),
                Elements.Create(
                    "button",
                    {onClick = fexe("bg.sh rand")},
                    "Rand Bg"
                ),
                Elements.Create(
                    "button",
                    {onClick = fexe("bg.sh rand")},
                    "Rand Bg"
                ),
                Elements.Create(
                    "button",
                    {onClick = fexe("bg.sh rand")},
                    "Rand Bg"
                ),
                Elements.Create(
                    "button",
                    {onClick = fexe("bg.sh rand")},
                    "Rand Bg"
                ),
                Elements.Create(
                    "button",
                    {onClick = fexe("bg.sh rand")},
                    "Rand Bg"
                ),
                Elements.Create(
                    "button",
                    {onClick = fexe("bg.sh rand")},
                    "Rand Bg"
                ),
                Elements.Create(
                    "button",
                    {onClick = fexe("bg.sh rand")},
                    "Rand Bg"
                ),
                Elements.Create(
                    "button",
                    {onClick = fexe("bg.sh rand")},
                    "Rand Bg"
                ),
                Elements.Create(
                    "button",
                    {onClick = fexe("bg.sh rand")},
                    "Rand Bg"
                ),
                Elements.Create(
                    "button",
                    {onClick = fexe("bg.sh rand")},
                    "Rand Bg"
                ),
                Elements.Create(
                    "button",
                    {onClick = fexe("bg.sh rand")},
                    "Rand Bg"
                ),
                Elements.Create(
                    "button",
                    {onClick = fexe("bg.sh rand")},
                    "Rand Bg"
                ),
                Elements.Create(
                    "button",
                    {onClick = fexe("bg.sh last")},
                    "Last Bg"
                ),
                Elements.Create(
                    "button",
                    {onClick = fexe("bg.sh next")},
                    "Next Bg"
                ),
                Elements.Create(
                    "button",
                    {onClick = fexe("bg.sh prev")},
                    "Prev Bg"
                ),
                Elements.Create(
                    "button",
                    {onClick = fexe("bg.sh reset")},
                    "Reset Bg"
                )
            ),
            Elements.Create("hr", nil),
            Elements.Create(
                "button",
                {onClick = function() return astal.exec_async(
                    "theme.sh dark",
                    function() return ps.restart() end
                ) end},
                "Dark Mode"
            ),
            Elements.Create(
                "button",
                {onClick = function() return astal.exec_async(
                    "theme.sh light",
                    function() return ps.restart() end
                ) end},
                "Light Mode"
            )
        )
    )
end
____exports.default = mkPopupToggleAnim(Center, {title = "Center", anchor = Anchor.TOP + Anchor.RIGHT + Anchor.BOTTOM, class_name = "transparent"}, {transition_type = Gtk.RevealerTransitionType.SLIDE_RIGHT})
return ____exports
