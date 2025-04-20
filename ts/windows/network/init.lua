--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local ____react = require("tslib.react")
local astal = ____react.astal
local Astal = ____react.Astal
local Elements = ____react.Elements
local useStack = ____react.useStack
local ____bluetooth = require("ts.windows.network.bluetooth")
local Bluetooth = ____bluetooth.default
local ____internet = require("ts.windows.network.internet")
local Internet = ____internet.default
local ____require_result_0 = require("lua.utils.init")
local inspect = ____require_result_0.inspect
local notify = ____require_result_0.notify
local ____astal_1 = astal
local exec_async = ____astal_1.exec_async
local bind = ____astal_1.bind
local function Network()
    local stack, switcher = table.unpack(useStack(
        {
            Elements.Create(Internet, nil),
            "internet",
            "page1"
        },
        {
            Elements.Create(Bluetooth, nil),
            "bluetooth",
            "page2"
        }
    ))
    switcher.halign = "CENTER"
    return Elements.Create(
        "div",
        {vertical = true, css = {minWidth = "360px", minHeight = "720px"}, spacing = 10, className = "bg-base00-90 m-4 p-4 rounded-lg border-base03-90 border-solid border-2"},
        switcher,
        stack,
        Elements.Create(
            "div",
            {spacing = 10},
            Elements.Create(
                "button",
                {
                    hexpand = true,
                    onClick = function() return exec_async("nm-connection-editor") end
                },
                "Connection Editor"
            ),
            Elements.Create(
                "button",
                {
                    hexpand = true,
                    onClick = function() return exec_async("blueman-services") end
                },
                "Blueman Services"
            )
        )
    )
end
local ____require_result_2 = require("lua.utils.astal")
local mkPopupToggleAnim = ____require_result_2.mkPopupToggleAnim
local ____Astal_WindowAnchor_3 = Astal.WindowAnchor
local TOP = ____Astal_WindowAnchor_3.TOP
local RIGHT = ____Astal_WindowAnchor_3.RIGHT
____exports.default = mkPopupToggleAnim(Network, {title = "Stats", keymode = "ON_DEMAND", anchor = TOP + RIGHT})
return ____exports
