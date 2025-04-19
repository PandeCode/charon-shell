local ____lualib = require("lualib_bundle")
local __TS__StringSplit = ____lualib.__TS__StringSplit
local __TS__StringPadStart = ____lualib.__TS__StringPadStart
local __TS__ArrayForEach = ____lualib.__TS__ArrayForEach
local __TS__ArrayMap = ____lualib.__TS__ArrayMap
local ____exports = {}
local ____react = require("tslib.react")
local Gtk = ____react.Gtk
local Elements = ____react.Elements
local Variable = ____react.Variable
local ____require_result_0 = require("lua.utils.init")
local ninspect = ____require_result_0.ninspect
local function createWatcher(script, sleepTime)
    if sleepTime == nil then
        sleepTime = 1
    end
    local variable = Variable("#000000 0")
    variable.watch(
        variable,
        ((("bash -c 'while true; do " .. script) .. "; echo; sleep ") .. tostring(sleepTime)) .. "; done'",
        function(e) return e end
    )
    return variable
end
local function color(prefix)
    return function(txt)
        local c, t = table.unpack(__TS__StringSplit(txt, " "))
        return Elements.Create(
            "p",
            {css = {color = c}},
            (prefix .. __TS__StringPadStart(t, 3, " ")) .. "%"
        )
    end
end
function ____exports.default()
    local cpu = createWatcher("usage.sh", 3)
    local mem = createWatcher("mem.sh", 3)
    local swap = createWatcher("swap.sh", 3)
    local refCpu = Variable(nil)
    local refMem = Variable(nil)
    local refSwap = Variable(nil)
    local r1Ref = Variable(nil)
    local r2Ref = Variable(nil)
    __TS__ArrayForEach(
        {{refCpu, cpu}, {refMem, mem}, {refSwap, swap}},
        function(____, ____bindingPattern0)
            local state
            local ref
            ref = ____bindingPattern0[1]
            state = ____bindingPattern0[2]
            state.subscribe(
                state,
                function(val)
                    local el = ref.get(ref)
                    if el then
                        local out = __TS__StringSplit(val, " ")
                        el.value = (tonumber(out[2]) or 0) / 100
                        el.parent.css = "color: " .. out[1]
                        el.parent.tooltip_markup = ((("<span foreground=\"" .. out[1]) .. "\" size=\"large\">") .. out[2]) .. " %</span>"
                    end
                end
            )
        end
    )
    return Elements.Create(
        "eventbox",
        {
            className = "px-2 ",
            on_destroy = function()
                cpu.drop(cpu)
                mem.drop(mem)
                swap.drop(swap)
            end,
            on_button_press_event = function()
                local r1 = r1Ref.get(r1Ref)
                local r2 = r1Ref.get(r2Ref)
                if r1 and r2 then
                    r1.reveal_child = not r1.reveal_child
                    r2.reveal_child = not r2.reveal_child
                end
            end
        },
        Elements.Create(
            Elements.Fragment,
            nil,
            Elements.Create(
                "revealer",
                {
                    reveal_child = true,
                    transition_type = Gtk.RevealerTransitionType.SLIDE_RIGHT,
                    transition_duration = 500,
                    ref = r1Ref,
                    className = "px-3 py-0 rounded-full bg-base01 "
                },
                __TS__ArrayMap(
                    {{"", refMem}, {"󰍛", refSwap}, {"", refCpu}},
                    function(____, ____bindingPattern0)
                        local icon
                        icon = ____bindingPattern0[1]
                        local ref = ____bindingPattern0[2]
                        return Elements.Create(
                            "overlay",
                            nil,
                            Elements.Create("p", {className = "text-2xl"}, icon)
                        )
                    end
                )
            ),
            Elements.Create(
                "revealer",
                {reveal_child = false, transition_type = Gtk.RevealerTransitionType.SLIDE_RIGHT, transition_duration = 500, ref = r2Ref},
                __TS__ArrayMap(
                    {{cpu, ""}, {swap, "󰍛"}, {mem, ""}},
                    function(____, ____bindingPattern0)
                        local icon
                        local v
                        v = ____bindingPattern0[1]
                        icon = ____bindingPattern0[2]
                        return Elements.Create(
                            "div",
                            {className = "px-3 py-0 rounded-full bg-base01"},
                            v(color(icon))
                        )
                    end
                )
            )
        )
    )
end
return ____exports
