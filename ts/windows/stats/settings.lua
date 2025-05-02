local ____lualib = require("lualib_bundle")
local __TS__TypeOf = ____lualib.__TS__TypeOf
local __TS__ArrayMap = ____lualib.__TS__ArrayMap
local ____exports = {}
local ____react = require("tslib.react")
local astal = ____react.astal
local Gtk = ____react.Gtk
local Variable = ____react.Variable
local Widget = ____react.Widget
local Elements = ____react.Elements
local assets = require("lua.assets")
local ____require_result_0 = require("lua.utils")
local ninspect = ____require_result_0.ninspect
local inspect = ____require_result_0.inspect
local ____require_result_1 = require("dkjson")
local encode = ____require_result_1.encode
local decode = ____require_result_1.decode
local ____astal_2 = astal
local write_file = ____astal_2.write_file
local read_file_async = ____astal_2.read_file_async
local write_file_async = ____astal_2.write_file_async
function ____exports.default()
    local entry_refs = {}
    local keys = Variable({})
    read_file_async(
        assets.config_path,
        function(out)
            if out ~= nil then
                local json = decode(out)
                if json ~= nil then
                    local ret = {}
                    for k, v in pairs(json) do
                        ret[#ret + 1] = {k, v}
                    end
                    keys.set(keys, ret)
                end
            end
        end
    )
    local function save()
        read_file_async(
            assets.config_path,
            function(out)
                if out ~= nil then
                    local json = decode(out)
                    if json ~= nil then
                        local changed = false
                        for ____, r in ipairs(entry_refs) do
                            local id, el, typ = table.unpack(r)
                            if el ~= nil then
                                if typ == "string" and el.text ~= nil and el.text ~= "" then
                                    json[id] = el.text
                                    changed = true
                                elseif typ == "number" and el.value ~= nil then
                                    json[id] = el.value
                                    changed = true
                                elseif typ == "boolean" and el.state ~= nil then
                                    json[id] = el.state
                                    changed = true
                                else
                                    print("ERROR with settings")
                                end
                            end
                        end
                        if changed then
                            local encoded = encode(json)
                            if encoded ~= nil then
                                write_file_async(
                                    assets.config_path,
                                    encoded,
                                    function()
                                        local ____assets_loadconfig_result_3 = assets.loadconfig()
                                        assets.config = ____assets_loadconfig_result_3
                                        return ____assets_loadconfig_result_3
                                    end
                                )
                            else
                                print(
                                    "Encoded null: ",
                                    inspect(encoded)
                                )
                            end
                        end
                    end
                end
            end
        )
    end
    return Elements.Create(
        "div",
        {vertical = true, spacing = 10},
        keys(function(k) return __TS__ArrayMap(
            k,
            function(____, id)
                local ____Elements_Create_6 = Elements.Create
                local ____id__1_5 = id[1]
                local ____assets_config_id__1_4 = assets.config[id[1]]
                if ____assets_config_id__1_4 == nil then
                    ____assets_config_id__1_4 = "NULL"
                end
                return ____Elements_Create_6(
                    "div",
                    nil,
                    (____id__1_5 .. ": ") .. tostring(____assets_config_id__1_4),
                    (function()
                        if type(id[2]) == "boolean" then
                            return Elements.Create(
                                Gtk.Switch,
                                {
                                    halign = "END",
                                    state = id[2],
                                    ref = function(____self)
                                        entry_refs[#entry_refs + 1] = {
                                            id[1],
                                            ____self,
                                            __TS__TypeOf(id[2])
                                        }
                                    end
                                }
                            )
                        elseif type(id[2]) == "number" then
                            return Elements.Create(
                                Gtk.SpinButton,
                                {
                                    value = id[2],
                                    ref = function(____self)
                                        entry_refs[#entry_refs + 1] = {
                                            id[1],
                                            ____self,
                                            __TS__TypeOf(id[2])
                                        }
                                    end,
                                    halign = "END",
                                    hexpand = true,
                                    adjustment = Gtk.Adjustment({
                                        lower = 0,
                                        upper = 64,
                                        step_increment = 1,
                                        page_increment = 1,
                                        value = id[2]
                                    })
                                }
                            )
                        else
                            return Elements.Create(
                                Widget.Entry,
                                {
                                    halign = "END",
                                    hexpand = true,
                                    text = id[2],
                                    ref = function(____self)
                                        entry_refs[#entry_refs + 1] = {
                                            id[1],
                                            ____self,
                                            __TS__TypeOf(id[2])
                                        }
                                    end
                                }
                            )
                        end
                    end)()
                )
            end
        ) end),
        Elements.Create("button", {onClick = save}, "Save")
    )
end
return ____exports
