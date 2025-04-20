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
local AstalBluetooth = astal.require("AstalBluetooth")
function ____exports.default()
    local bluetooth = AstalBluetooth.get_default()
    local devices = bind(bluetooth, "devices")
    local isPowered = bind(bluetooth, "is-powered")
    local isConnected = bind(bluetooth, "is-connected")
    return Elements.Create(
        "div",
        {vertical = true, expand = true},
        Elements.Create(
            "centerbox",
            {className = "m-2"},
            Elements.Create("p", {hexpand = true, halign = "START"}, "Bluetooth"),
            Elements.Create(
                "p",
                {halign = "END", className = "px-2 m-2"},
                isConnected.as(
                    isConnected,
                    function(isConnected) return isConnected and "Connected" or "None Connected" end
                )
            ),
            Elements.Create(
                Elements.Fragment,
                nil,
                isPowered.as(
                    isPowered,
                    function(isPowered)
                        local ____isPowered_3
                        if isPowered then
                            ____isPowered_3 = Elements.Create(
                                "button",
                                {onClick = function() return bluetooth.toggle(bluetooth) end},
                                "Turn Off"
                            )
                        else
                            ____isPowered_3 = Elements.Create(
                                "button",
                                {onClick = function() return bluetooth.toggle(bluetooth) end},
                                "Turn On"
                            )
                        end
                        return ____isPowered_3
                    end
                )
            )
        ),
        isPowered.as(
            isPowered,
            function(isPowered)
                local ____temp_8
                if not isPowered then
                    ____temp_8 = Elements.Create("p", nil, "Not Powered")
                else
                    ____temp_8 = Elements.Create(
                        "scrollable",
                        {hscroll = "NEVER"},
                        Elements.Create(
                            "div",
                            {vertical = true, vexpand = true, spacing = 10},
                            devices.as(
                                devices,
                                function(devices)
                                    return __TS__ArrayMap(
                                        devices,
                                        function(____, device)
                                            local per = device["battery-percentage"]
                                            local connected = bind(device, "connected")
                                            return Elements.Create(
                                                "centerbox",
                                                {hexpand = true},
                                                Elements.Create(
                                                    "div",
                                                    {halign = "START", spacing = 10},
                                                    Elements.Create("icon", {icon = device.icon}),
                                                    per > 0 and Elements.Create(
                                                        "p",
                                                        {className = "text-base0B"},
                                                        tostring(per * 100) .. "%"
                                                    ) or nil,
                                                    Elements.Create("p", {className = "text-xl"}, device.trusted and "" or "")
                                                ),
                                                Elements.Create("p", {hexpand = true}, device.name),
                                                Elements.Create(
                                                    Elements.Fragment,
                                                    nil,
                                                    connected.as(
                                                        connected,
                                                        function(connected)
                                                            local connecting = bind(device, "connecting")
                                                            local ____Elements_Create_7 = Elements.Create
                                                            local ____temp_6 = {halign = "END"}
                                                            local ____connected_5
                                                            if connected then
                                                                ____connected_5 = Elements.Create(
                                                                    "button",
                                                                    {onClick = function() return device.disconnect_device(device) end},
                                                                    "Disconnect"
                                                                )
                                                            else
                                                                ____connected_5 = connecting.as(
                                                                    connecting,
                                                                    function(connecting)
                                                                        local ____connecting_4
                                                                        if connecting then
                                                                            ____connecting_4 = Elements.Create("p", nil, "Connecting...")
                                                                        else
                                                                            ____connecting_4 = Elements.Create(
                                                                                "button",
                                                                                {onClick = function() return device.connect_device(device) end},
                                                                                "Connect"
                                                                            )
                                                                        end
                                                                        return ____connecting_4
                                                                    end
                                                                )
                                                            end
                                                            return ____Elements_Create_7("div", ____temp_6, ____connected_5)
                                                        end
                                                    )
                                                )
                                            )
                                        end
                                    )
                                end
                            )
                        )
                    )
                end
                return ____temp_8
            end
        )
    )
end
return ____exports
