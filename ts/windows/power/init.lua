local ____lualib = require("lualib_bundle")
local __TS__NumberToFixed = ____lualib.__TS__NumberToFixed
local __TS__ArrayMap = ____lualib.__TS__ArrayMap
local ____exports = {}
local ____react = require("tslib.react")
local astal = ____react.astal
local Gtk = ____react.Gtk
local Astal = ____react.Astal
local Elements = ____react.Elements
local bindAs = ____react.bindAs
local ____require_result_0 = require("lua.utils.init")
local inspect = ____require_result_0.inspect
local notify = ____require_result_0.notify
local ____astal_1 = astal
local exec_async = ____astal_1.exec_async
local bind = ____astal_1.bind
local Battery = astal.require("AstalBattery")
local PowerProfiles = astal.require("AstalPowerProfiles")
local ____require_result_2 = require("lua.utils.astal")
local update_icon_pixbuf = ____require_result_2.update_icon_pixbuf
local mkPopupToggleAnim = ____require_result_2.mkPopupToggleAnim
local function parseDegradation(v)
    repeat
        local ____switch3 = v
        local ____cond3 = ____switch3 == "lap detected"
        if ____cond3 then
            return Elements.Create("p", {className = "text-base0A"}, "Sitting on the your lap")
        end
        ____cond3 = ____cond3 or ____switch3 == "high operating temperature"
        if ____cond3 then
            return Elements.Create("p", {className = "text-base0F"}, "Close to overheating")
        end
        ____cond3 = ____cond3 or ____switch3 == ""
        if ____cond3 then
            return "Performance is not degraded"
        end
        do
            return Elements.Create("p", {className = "text-base0F"}, v)
        end
    until true
end
local function Network()
    local bat = Battery.get_default()
    local powerprofiles = PowerProfiles.get_default()
    local active = bind(powerprofiles, "active-profile")
    local icon = bind(powerprofiles, "icon-name")
    local profiles = {{"power-saver", "battery saving profile"}, {"balanced", "the default profile"}, {"performance", "does not care about noise or battery consumption"}}
    return Elements.Create(
        "div",
        {vertical = true, css = {minWidth = "360px", minHeight = "160px"}, spacing = 10, className = "bg-base00-90 m-4 p-4 rounded-lg border-base03-90 border-solid border-2"},
        bindAs(
            bat,
            "percentage",
            function(p) return Elements.Create(
                Elements.Fragment,
                nil,
                Elements.Create("p", {halign = "START", className = "font-bold text-xl"}, "Percentage:"),
                Elements.Create(
                    "p",
                    {hexpand = true, halign = "END"},
                    __TS__NumberToFixed(p * 100, 1) .. "%"
                )
            ) end
        ),
        bindAs(
            bat,
            "state",
            function(state) return Elements.Create(
                Elements.Fragment,
                nil,
                Elements.Create("p", {halign = "START", className = "font-bold text-xl"}, "State:"),
                Elements.Create("p", {hexpand = true, halign = "END"}, state)
            ) end
        ),
        bindAs(
            bat,
            "time_to_empty",
            function(secs)
                local value = secs > 0 and ((tostring(math.floor(secs / 3600)) .. "h ") .. tostring(math.floor(secs % 3600 / 60))) .. "m" or "N/A"
                return Elements.Create(
                    Elements.Fragment,
                    nil,
                    Elements.Create("p", {halign = "START", className = "font-bold text-xl"}, "Time to Empty:"),
                    Elements.Create("p", {hexpand = true, halign = "END"}, value)
                )
            end
        ),
        bindAs(
            bat,
            "time_to_full",
            function(secs)
                local value = secs > 0 and ((tostring(math.floor(secs / 3600)) .. "h ") .. tostring(math.floor(secs % 3600 / 60))) .. "m" or "N/A"
                return Elements.Create(
                    Elements.Fragment,
                    nil,
                    Elements.Create("p", {halign = "START", className = "font-bold text-xl"}, "Time to Full:"),
                    Elements.Create("p", {hexpand = true, halign = "END"}, value)
                )
            end
        ),
        bindAs(
            bat,
            "energy",
            function(energy) return Elements.Create(
                Elements.Fragment,
                nil,
                Elements.Create("p", {halign = "START", className = "font-bold text-xl"}, "Energy Now:"),
                Elements.Create(
                    "p",
                    {hexpand = true, halign = "END"},
                    __TS__NumberToFixed(energy, 2) .. "Wh"
                )
            ) end
        ),
        bindAs(
            bat,
            "energy_full",
            function(energyFull) return Elements.Create(
                Elements.Fragment,
                nil,
                Elements.Create("p", {halign = "START", className = "font-bold text-xl"}, "Energy Full:"),
                Elements.Create(
                    "p",
                    {hexpand = true, halign = "END"},
                    __TS__NumberToFixed(energyFull, 2) .. "Wh"
                )
            ) end
        ),
        Elements.Create("hr", nil),
        Elements.Create(
            "div",
            {spacing = 10},
            icon.as(
                icon,
                function(i) return Elements.Create(
                    Gtk.Image,
                    {ref = function(r)
                        update_icon_pixbuf(r, i or "dialog-error-symbolic", 50, 50)
                        return r
                    end}
                ) end
            ),
            Elements.Create(
                Elements.Fragment,
                nil,
                Elements.Create("p", {className = "font-bold text-xl"}, active),
                ":",
                " ",
                parseDegradation(powerprofiles["performance-degraded"])
            )
        ),
        __TS__ArrayMap(
            profiles,
            function(____, ____bindingPattern0)
                local d
                local p
                p = ____bindingPattern0[1]
                d = ____bindingPattern0[2]
                return Elements.Create(
                    "div",
                    {vertical = true, expand = true, className = "rounded-lg bg-base01 shadow-xl p-2 m-2"},
                    Elements.Create(
                        Elements.Fragment,
                        nil,
                        Elements.Create("p", {expand = true, className = "text-lg font-bold"}, p),
                        Elements.Create(
                            "button",
                            {
                                halign = "END",
                                onClick = function() return powerprofiles.set_active_profile(powerprofiles, p) end
                            },
                            "Set"
                        )
                    ),
                    d
                )
            end
        )
    )
end
local ____Astal_WindowAnchor_3 = Astal.WindowAnchor
local TOP = ____Astal_WindowAnchor_3.TOP
local RIGHT = ____Astal_WindowAnchor_3.RIGHT
____exports.default = mkPopupToggleAnim(Network, {title = "Stats", keymode = "ON_DEMAND", anchor = TOP + RIGHT})
return ____exports
