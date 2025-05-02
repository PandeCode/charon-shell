--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local ____react = require("tslib.react")
local Elements = ____react.Elements
local useStack = ____react.useStack
local ____sysinfo = require("ts.windows.stats.sysinfo")
local Sysinfo = ____sysinfo.default
local ____weather = require("ts.windows.stats.weather")
local Weather = ____weather.default
local ____settings = require("ts.windows.stats.settings")
local Settings = ____settings.default
local ____require_result_0 = require("lua.utils.astal")
local mkPopupToggleAnim = ____require_result_0.mkPopupToggleAnim
local ____require_result_1 = require("lua.utils.init")
local inspect = ____require_result_1.inspect
local notify = ____require_result_1.notify
local Console = require("lua.windows.console")
local function Stats()
    local stack, switcher = table.unpack(useStack(
        {
            Elements.Create(
                Elements.Fragment,
                nil,
                Weather()
            ),
            "Weather"
        },
        {
            Elements.Create(
                Elements.Fragment,
                nil,
                Sysinfo()
            ),
            "Sysinfo"
        },
        {
            Elements.Create(
                Elements.Fragment,
                nil,
                Console()
            ),
            "Console"
        },
        {
            Elements.Create(
                Elements.Fragment,
                nil,
                Settings()
            ),
            "Settings"
        }
    ))
    return Elements.Create("div", {vertical = true, css = {minWidth = "1080px", minHeight = "720px"}, spacing = 10, className = "bg-base00-90 m-4 p-4 rounded-lg border-base03-90 border-solid border-2"}, switcher, stack)
end
____exports.default = mkPopupToggleAnim(Stats, {title = "Stats", keymode = "ON_DEMAND"})
return ____exports
