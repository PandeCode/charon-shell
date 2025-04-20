--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local astal
function ____exports.useReFetch(variable, url, preprocess)
    if preprocess == nil then
        preprocess = function(out) return out end
    end
    astal.exec_async(
        "curl -s " .. url,
        function(out)
            variable._v.set(
                variable._v,
                preprocess(out)
            )
        end
    )
end
local _astal = require("astal")
local stat = require("posix").stat
astal = _astal
____exports.astal = astal
local CACHE_DIR = "/home/shawn/.cache/charon-shell/fetch/"
local Elements = require("tslib.Elements")
local Gdk = astal.require("Gdk")
local Gtk = astal.require("Gtk")
local GdkPixbuf = astal.require("GdkPixbuf")
local GLib = astal.require("GLib")
local Astal = astal.require("Astal")
local Variable = astal.Variable
local utils = require("lua.utils")
local Widget = require("astal.gtk3.widget")
local toCSS = require("lua.extras.tailwind").toCSS
local function setInterval(c, t)
    return astal.interval(t, c)
end
local function setTimeout(c, t)
    return astal.timeout(t, c)
end
local astalify = require("astal.gtk3").astalify
____exports.astalify = astalify
____exports.GdkPixbuf = GdkPixbuf
____exports.Elements = Elements
____exports.Widget = Widget
____exports.Gdk = Gdk
____exports.Gtk = Gtk
____exports.GLib = GLib
____exports.Astal = Astal
____exports.Variable = Variable
____exports.setInterval = setInterval
____exports.setTimeout = setTimeout
____exports.toCSS = toCSS
____exports.utils = utils
local exec_async = astal.exec_async
local read_file_async = astal.read_file_async
function ____exports.sh(cmd)
    return {"bash", "-c", cmd}
end
function ____exports.useVariable(defaultValue, getter)
    if getter == nil then
        getter = function(s) return s end
    end
    local variable = Variable(defaultValue)
    local v = variable(getter)
    v._v = variable
    return {
        v,
        function(fn)
            local ____variable_set_1 = variable.set
            local ____temp_0
            if type(fn) == "function" then
                ____temp_0 = fn(variable.get(variable))
            else
                ____temp_0 = fn
            end
            return ____variable_set_1(variable, ____temp_0)
        end,
        variable
    }
end
function ____exports.useEffect(fn, vars)
    if vars == nil or #vars == 0 then
        fn()
    else
        for ____, v in ipairs(vars) do
            v._v.subscribe(v._v, fn)
        end
    end
end
function ____exports.useStack(...)
    local pages = {...}
    local stack = Gtk.Stack({transition_type = "SLIDE_LEFT_RIGHT", transition_duration = 500, visible = true})
    local switcher = Gtk.StackSwitcher({stack = stack})
    do
        local index = 0
        while index < #pages do
            local page = pages[index + 1]
            stack.add_titled(
                stack,
                page[1],
                page[3] or "page" .. tostring(index),
                page[2]
            )
            index = index + 1
        end
    end
    return {stack, switcher}
end
function ____exports.useStackSolo(...)
    local pages = {...}
    local stack = Gtk.Stack({transition_type = "SLIDE_LEFT_RIGHT", transition_duration = 500, visible = true})
    do
        local index = 0
        while index < #pages do
            local page = pages[index + 1]
            stack.add_titled(
                stack,
                page[1],
                page[3] or "page" .. tostring(index),
                page[2]
            )
            index = index + 1
        end
    end
    return stack
end
function ____exports.useCmd(cmd, preprocess)
    local state, setState = table.unpack(____exports.useVariable("Loading..."))
    exec_async(
        cmd,
        function(out)
            if out then
                if preprocess then
                    setState(preprocess(out))
                else
                    setState(out)
                end
            end
        end
    )
    return state
end
function ____exports.useFile(path, preprocess)
    local state, setState = table.unpack(____exports.useVariable("Loading..."))
    read_file_async(
        path,
        function(out)
            if out then
                if preprocess then
                    setState(preprocess(out))
                else
                    setState(out)
                end
            end
        end
    )
    return state
end
function ____exports.useFetch(url, preprocess)
    if preprocess == nil then
        preprocess = function(out) return out end
    end
    local variable, setVariable = table.unpack(____exports.useVariable())
    astal.exec_async(
        "curl -s " .. url,
        function(out)
            setVariable(preprocess(out))
        end
    )
    return variable
end
local function hash(str)
    return astal.exec(string.format("sh -c \"printf '%%s' '%s' | md5sum | cut -d' ' -f1\"", str))
end
function ____exports.removeCache(url)
    local path = CACHE_DIR .. hash(url)
    return os.remove(path)
end
function ____exports.useFetchCache(url, preprocess)
    if preprocess == nil then
        preprocess = function(out) return out end
    end
    local path = CACHE_DIR .. hash(url)
    if stat(path) ~= nil then
        local variable, setVariable = table.unpack(____exports.useVariable())
        astal.read_file_async(
            path,
            function(out) return setVariable(preprocess(out)) end
        )
        return variable
    else
        local function new_preprocess(out)
            astal.write_file_async(path, out)
            return preprocess(out)
        end
        return ____exports.useFetch(url, new_preprocess)
    end
end
function ____exports.useReFetchCache(variable, url, preprocess)
    if preprocess == nil then
        preprocess = function(out) return out end
    end
    local path = CACHE_DIR .. hash(url)
    if stat(path) ~= nil then
        astal.read_file_async(
            path,
            function(out) return variable._v.set(
                variable._v,
                preprocess(out)
            ) end
        )
    else
        local function new_preprocess(out)
            astal.write_file_async(path, out)
            return preprocess(out)
        end
        ____exports.useReFetch(variable, url, new_preprocess)
    end
end
return ____exports
