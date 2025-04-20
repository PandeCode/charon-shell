local ____lualib = require("lualib_bundle")
local __TS__Iterator = ____lualib.__TS__Iterator
local __TS__ArrayForEach = ____lualib.__TS__ArrayForEach
local __TS__ArrayMap = ____lualib.__TS__ArrayMap
local __TS__StringSplit = ____lualib.__TS__StringSplit
local ____exports = {}
local ____react = require("tslib.react")
local astal = ____react.astal
local Widget = ____react.Widget
local Gtk = ____react.Gtk
local Variable = ____react.Variable
local Astal = ____react.Astal
local Elements = ____react.Elements
local ____require_result_0 = require("lua.utils.init")
local truncate = ____require_result_0.truncate
local inspect = ____require_result_0.inspect
local notify = ____require_result_0.notify
local ____astal_1 = astal
local bind = ____astal_1.bind
local Apps = astal.require("AstalApps")
local ____require_result_2 = require("lua.utils.astal")
local mkPopupToggleAnim = ____require_result_2.mkPopupToggleAnim
local update_icon_pixbuf = ____require_result_2.update_icon_pixbuf
local function Start()
    local apps = Apps.Apps({name_multiplier = 2, entry_multiplier = 0, executable_multiplier = 2})
    local text = Variable("")
    local btext = bind(text)
    local ref = Variable(nil)
    text.subscribe(
        text,
        function(t)
            local flowbox = ref.get(ref)
            if flowbox ~= nil then
                for ____, child in __TS__Iterator(flowbox.get_children(flowbox)) do
                    flowbox.remove(flowbox, child)
                    child.destroy(child)
                end
                __TS__ArrayForEach(
                    apps.fuzzy_query(apps, t),
                    function(____, a)
                        flowbox.add(
                            flowbox,
                            Elements.Create(
                                "eventbox",
                                {onClick = function()
                                    a.launch(a)
                                end},
                                Elements.Create(
                                    "div",
                                    {vertical = true, width = 30, height = 30, className = "bg-base01 shadow rounded-lg p-2 m-2"},
                                    Elements.Create(
                                        Gtk.Image,
                                        {ref = function(r)
                                            local ____update_icon_pixbuf_5 = update_icon_pixbuf
                                            local ____r_4 = r
                                            local ____a_icon_2Dname_3 = a["icon-name"]
                                            if ____a_icon_2Dname_3 == nil then
                                                ____a_icon_2Dname_3 = "dialog-error-symbolic"
                                            end
                                            ____update_icon_pixbuf_5(____r_4, ____a_icon_2Dname_3, 50, 50)
                                            return r
                                        end}
                                    ),
                                    Elements.Create(
                                        "p",
                                        {wrap = true, justify = "CENTER"},
                                        truncate(a.name, 20)
                                    )
                                )
                            )
                        )
                    end
                )
            end
        end
    )
    return Elements.Create(
        "div",
        {vertical = true, css = {minWidth = "480px", minHeight = "720px"}, spacing = 10, className = "bg-base00-90 m-4 p-4 rounded-lg border-base03-90 border-solid border-2"},
        Elements.Create(
            Widget.Entry,
            {
                hexpand = true,
                placeholder_text = "Search for an app",
                text = btext.as(
                    btext,
                    function(t) return tostring(t) end
                ),
                on_changed = function(____self) return text.set(text, ____self.text) end
            }
        ),
        Elements.Create(
            "scrollable",
            {expand = true, hscroll = "NEVER"},
            Elements.Create(
                "div",
                {vertical = true},
                Elements.Create(Gtk.FlowBox, {max_children_per_line = 3, selection_mode = "NONE", ref = ref})
            ),
            Elements.Create("div", {expand = true})
        ),
        Elements.Create("hr", nil),
        Elements.Create(
            "div",
            {vertical = true, spacing = 10},
            __TS__ArrayMap(
                {"~/Downloads", "~/Documents", "~/dev"},
                function(____, path) return Elements.Create(
                    "button",
                    {onClick = function() return astal.exec_async(("bash -c 'nautilus " .. path) .. "'") end},
                    path
                ) end
            )
        ),
        Elements.Create("hr", nil),
        Elements.Create(
            "div",
            {vertical = true, spacing = 4},
            Elements.Create("p", {className = "text-base05 font-bold"}, "Manuals"),
            __TS__ArrayMap(
                {"~/.config/stylix/palette.html"},
                function(____, path) return Elements.Create(
                    "button",
                    {onClick = function() return astal.exec_async(("bash -c 'xdg-open " .. path) .. "'") end},
                    table.remove(__TS__StringSplit(path, "/"))
                ) end
            )
        ),
        Elements.Create("hr", nil),
        Elements.Create(
            "button",
            {onClick = function() return astal.exec_async("poweroff") end},
            "Power Off"
        ),
        Elements.Create(
            "button",
            {onClick = function() return astal.exec_async("reboot") end},
            "Reboot"
        )
    )
end
local ____Astal_WindowAnchor_6 = Astal.WindowAnchor
local TOP = ____Astal_WindowAnchor_6.TOP
local LEFT = ____Astal_WindowAnchor_6.LEFT
____exports.default = mkPopupToggleAnim(Start, {title = "Stats", keymode = "ON_DEMAND", anchor = TOP + LEFT})
return ____exports
