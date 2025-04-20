--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local ____react = require("tslib.react")
local astal = ____react.astal
local Gtk = ____react.Gtk
local Elements = ____react.Elements
local Astal = ____react.Astal
local ____Astal_WindowAnchor_0 = Astal.WindowAnchor
local TOP = ____Astal_WindowAnchor_0.TOP
local RIGHT = ____Astal_WindowAnchor_0.RIGHT
local ____require_result_1 = require("lua.utils.astal")
local mkPopupToggleAnim = ____require_result_1.mkPopupToggleAnim
local ____Gtk_2 = Gtk
local InfoBar = ____Gtk_2.InfoBar
local Calendar = ____Gtk_2.Calendar
local Scale = ____Gtk_2.Scale
local LevelBar = ____Gtk_2.LevelBar
local Spinner = ____Gtk_2.Spinner
local function win()
    return Elements.Create(
        "div",
        {vertical = true, className = "bg-base00 m-2 p-2 rounded-lg", css = {minWidth = "30em"}},
        Elements.Create(
            "button",
            {onClick = function() return astal.exec("swaync-client -t -sw") end},
            "Notification Center"
        ),
        Elements.Create(Calendar, nil),
        Elements.Create(InfoBar, {message_type = Gtk.MessageType.INFO})
    )
end
____exports.default = mkPopupToggleAnim(win, {title = "Time", anchor = TOP + RIGHT, class_name = "transparent"}, {transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN})
return ____exports
