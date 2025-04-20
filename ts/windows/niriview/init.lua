--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local ____react = require("tslib.react")
local astal = ____react.astal
local Elements = ____react.Elements
local ____require_result_0 = require("lua.utils.init")
local inspect = ____require_result_0.inspect
local notify = ____require_result_0.notify
local ____astal_1 = astal
local exec_async = ____astal_1.exec_async
local bind = ____astal_1.bind
local function Network()
    return Elements.Create("div", {vertical = true, css = {minWidth = "1080px", minHeight = "720px"}, spacing = 10, className = "bg-base00-90 m-4 p-4 rounded-lg border-base03-90 border-solid border-2"}, "hi")
end
local ____require_result_2 = require("lua.utils.astal")
local mkPopupToggleAnim = ____require_result_2.mkPopupToggleAnim
____exports.default = mkPopupToggleAnim(Network, {title = "Stats", keymode = "ON_DEMAND"})
return ____exports
