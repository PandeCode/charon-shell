local ____lualib = require("lualib_bundle")
local __TS__ArrayMap = ____lualib.__TS__ArrayMap
local ____exports = {}
local ____react = require("tslib.react")
local astal = ____react.astal
local Elements = ____react.Elements
local ____require_result_0 = require("lua.utils.astal")
local mkPopupToggleAnim = ____require_result_0.mkPopupToggleAnim
local ____require_result_1 = require("lua.utils.init")
local inspect = ____require_result_1.inspect
local notify = ____require_result_1.notify
local ____astal_2 = astal
local exec_async = ____astal_2.exec_async
local bind = ____astal_2.bind
local Network = astal.require("AstalNetwork")
local AstalBluetooth = astal.require("AstalBluetooth")
function ____exports.default()
    local network = Network.get_default()
    local connectivity = bind(network, "connectivity")
    local state = bind(network, "state")
    local wired = bind(network, "wired")
    local wifi = bind(network, "wifi")
    local scanning = bind(network.wifi, "scanning")
    local enabled = bind(network.wifi, "enabled")
    local iconName = bind(network.wifi, "icon-name")
    local aps = bind(network.wifi, "access-points")
    return Elements.Create(
        "div",
        {vertical = true},
        "Network",
        connectivity,
        state,
        wired.as(
            wired,
            function(wired)
                local iconName = bind(wired, "icon-name")
                if wired.state == "UNAVAILABLE" then
                    return nil
                else
                    return Elements.Create(
                        "div",
                        {vertical = true, expand = true},
                        Elements.Create("hr", nil),
                        "WIRED",
                        Elements.Create(
                            "div",
                            {vertical = true},
                            iconName.as(
                                iconName,
                                function(iconName) return Elements.Create("icon", {icon = iconName}) end
                            ),
                            wired.device,
                            wired.speed,
                            wired.state,
                            wired.internet
                        )
                    )
                end
            end
        ),
        Elements.Create("hr", nil),
        Elements.Create(
            Elements.Fragment,
            nil,
            iconName.as(
                iconName,
                function(iconName) return Elements.Create("icon", {icon = iconName}) end
            ),
            Elements.Create("p", {className = "text-2xl p-2", justify = "CENTER", hexpand = true}, "WIFI")
        ),
        scanning.as(
            scanning,
            function(scanning)
                local ____scanning_3
                if scanning then
                    ____scanning_3 = Elements.Create("p", nil, "Scanning...")
                else
                    ____scanning_3 = Elements.Create(
                        "button",
                        {onClick = function() return wifi.scan(wifi) end},
                        "Scan"
                    )
                end
                return ____scanning_3
            end
        ),
        enabled.as(
            enabled,
            function(enabled)
                if not enabled then
                    return Elements.Create("p", nil, "Disabled")
                else
                    return Elements.Create(
                        "scrollable",
                        {expand = true, hscroll = "NEVER"},
                        Elements.Create(
                            "div",
                            {vertical = true},
                            aps.as(
                                aps,
                                function(_aps)
                                    return __TS__ArrayMap(
                                        _aps,
                                        function(____, ap)
                                            local _iconName = bind(ap, "icon-name")
                                            return Elements.Create(
                                                "div",
                                                {spacing = 10, className = "bg-base01 m-2 p-2 rounded-lg shadow"},
                                                _iconName.as(
                                                    _iconName,
                                                    function(__iconName) return Elements.Create("icon", {icon = __iconName}) end
                                                ),
                                                ap.ssid
                                            )
                                        end
                                    )
                                end
                            )
                        )
                    )
                end
            end
        )
    )
end
return ____exports
