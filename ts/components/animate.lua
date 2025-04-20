--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local ____react = require("tslib.react")
local astal = ____react.astal
local Elements = ____react.Elements
local Variable = ____react.Variable
function ____exports.default(props, children)
    if props == nil then
        props = {kind = "SLIDE_DOWN", duration = 500, delay = 500}
    end
    if children == nil then
        children = Elements.Create(Elements.Fragment, nil, "Empty Revealer")
    end
    local ref = Variable(nil)
    local ____props_0 = props
    local kind = ____props_0.kind
    local duration = ____props_0.duration
    local delay = ____props_0.delay
    astal.timeout(
        delay or 500,
        function()
            local el = ref.get(ref)
            if el ~= nil then
                el.reveal_child = true
                local parent = ref.parent
                local child = ref.reveal_child
                if child ~= nil and parent ~= nil then
                    ref.parent.add(ref.parent, child)
                    ref.destroy(ref)
                end
            end
        end
    )
    return Elements.Create("revealer", {ref = ref, transition_type = kind or "SLIDE_DOWN", transition_duration = duration or 500}, children)
end
return ____exports
