local ____lualib = require("lualib_bundle")
local __TS__ArrayForEach = ____lualib.__TS__ArrayForEach
local __TS__NumberToFixed = ____lualib.__TS__NumberToFixed
local __TS__NumberToString = ____lualib.__TS__NumberToString
local __TS__StringPadStart = ____lualib.__TS__StringPadStart
local __TS__ArrayFrom = ____lualib.__TS__ArrayFrom
local ____exports = {}
local ____react = require("tslib.react")
local astal = ____react.astal
local astalify = ____react.astalify
local Variable = ____react.Variable
local GdkPixbuf = ____react.GdkPixbuf
local Gtk = ____react.Gtk
local Elements = ____react.Elements
local Astal = ____react.Astal
local assets = require("lua.assets")
local ps = require("lua.utils.ps")
local ____Astal_WindowAnchor_0 = Astal.WindowAnchor
local TOP = ____Astal_WindowAnchor_0.TOP
local RIGHT = ____Astal_WindowAnchor_0.RIGHT
local BOTTOM = ____Astal_WindowAnchor_0.BOTTOM
local ____require_result_1 = require("lua.utils.astal")
local mkPopupToggleAnim = ____require_result_1.mkPopupToggleAnim
local ____require_result_2 = require("lua.utils")
local lastIndexOf = ____require_result_2.lastIndexOf
local ninspect = ____require_result_2.ninspect
local notify = ____require_result_2.notify
local function fexe(cmd)
    return function() return astal.exec_async(cmd) end
end
local function fbexe(cmd)
    return function() return astal.exec_async({"bash", "-c", cmd}) end
end
local function Center()
    local Image = astalify(Gtk.Image)
    local SpinButton = astalify(Gtk.SpinButton)
    local prevImgRef = Variable(nil)
    local currImgRef = Variable(nil)
    local nextImgRef = Variable(nil)
    local invertRef = Variable(nil)
    local goWallRef = Variable(nil)
    local pixelateRef = Variable(nil)
    local borderRef = Variable(nil)
    local gridRef = Variable(nil)
    local flipRef = Variable(nil)
    local grayscaleRef = Variable(nil)
    local mirrorRef = Variable(nil)
    local function getEnv()
        local goWall = goWallRef.get(goWallRef)
        local invert = goWallRef.get(invertRef)
        local pixelate = goWallRef.get(pixelateRef)
        local border = borderRef.get(borderRef)
        local grid = gridRef.get(gridRef)
        local flip = flipRef.get(flipRef)
        local grayscale = grayscaleRef.get(grayscaleRef)
        local mirror = mirrorRef.get(mirrorRef)
        if goWall ~= nil and invert ~= nil and pixelate ~= nil and border ~= nil and grid ~= nil and flip ~= nil and mirror ~= nil and grayscale ~= nil then
            local env = "SILENT=1 "
            if goWall.active then
                env = env .. " GO_WALL=nix "
            end
            if invert.active then
                env = env .. " GO_WALL_INVERT=1 "
            end
            if pixelate.value ~= 0 then
                env = env .. (" GO_WALL_PIXELATE='" .. tostring(pixelate.value)) .. "' "
            end
            local effects = {}
            if border.active then
                effects[#effects + 1] = "draw border"
            end
            if grid.active then
                effects[#effects + 1] = "draw grid"
            end
            if flip.active then
                effects[#effects + 1] = "effects flip"
            end
            if mirror.active then
                effects[#effects + 1] = "effects mirror"
            end
            if grayscale.active then
                effects[#effects + 1] = "effects grayscale"
            end
            if #effects > 0 then
                env = env .. (" GO_WALL_EFFECT='" .. table.concat(effects, "|")) .. "'"
            end
            return env
        end
        return ""
    end
    local function loadImg()
        local prevImg = prevImgRef.get(prevImgRef)
        local currImg = currImgRef.get(currImgRef)
        local nextImg = nextImgRef.get(nextImgRef)
        if prevImg ~= nil and currImg ~= nil and nextImg ~= nil then
            __TS__ArrayForEach(
                {{"prev", prevImg}, {"last", currImg}, {"next", nextImg}},
                function(____, ____bindingPattern0)
                    local r
                    local c
                    c = ____bindingPattern0[1]
                    r = ____bindingPattern0[2]
                    astal.exec_async(
                        ((("bash -c \"" .. getEnv()) .. " bg.sh get-") .. tostring(c)) .. "\"",
                        function(s, _out)
                            local pixbuf = GdkPixbuf.Pixbuf.new_from_file(s)
                            if pixbuf == nil then
                                pixbuf = GdkPixbuf.Pixbuf.new_from_file(assets.default_image_path)
                            end
                            r.pixbuf = pixbuf.scale_simple(pixbuf, 192 * 1.2, 108 * 1.2, "BILINEAR")
                        end
                    )
                end
            )
        end
    end
    local function bgfn(fn)
        return function() return astal.exec_async(
            ((("bash -c '" .. getEnv()) .. " bg.sh ") .. fn) .. "'",
            loadImg
        ) end
    end
    astal.timeout(500, loadImg)
    local usage = Variable({})
    usage.poll(usage, 5000, ps.getResourceUse)
    return Elements.Create(
        "scrollable",
        {
            expand = true,
            hscroll = "NEVER",
            on_destroy = function()
                usage.drop(usage)
            end
        },
        Elements.Create(
            "div",
            {vertical = true, css = {minWidth = "30em"}, spacing = 10, className = "bg-base00-90  m-4 p-4 rounded-lg border-base03-90 border-solid border-2"},
            Elements.Create("button", {onClick = ps.restart}, "Restart Shell"),
            Elements.Create("button", {onClick = ps.kill}, "Kill Shell"),
            usage(function(v)
                local ____TS__NumberToFixed_result_5 = __TS__NumberToFixed((v.memory_rss_kb or 0) / 1000, 2)
                local ____TS__NumberToFixed_result_6 = __TS__NumberToFixed((v.memory_vmsize_kb or 0) / 1000, 2)
                local ____temp_7 = v.threads or 0
                local ____opt_3 = v.cpu_time_seconds
                return ((((((((("\n    RAM (RSS): " .. ____TS__NumberToFixed_result_5) .. " MB\n    RAM (Virtual): ") .. ____TS__NumberToFixed_result_6) .. " MB\n    Threads: ") .. tostring(____temp_7)) .. "\n    CPU Time: ") .. (____opt_3 and __TS__NumberToFixed(v.cpu_time_seconds, 2) or 0)) .. " s\n    Open FDs: ") .. tostring(v.open_fds or 0)) .. "\n  "
            end),
            Elements.Create("hr", nil),
            Elements.Create(Image, {ref = currImgRef}),
            Elements.Create(
                Elements.Fragment,
                nil,
                Elements.Create("p", nil, "Pixelate"),
                Elements.Create(
                    Gtk.SpinButton,
                    {
                        halign = "END",
                        adjustment = Gtk.Adjustment({
                            lower = 0,
                            upper = 100,
                            step_increment = 0.1,
                            page_increment = 1,
                            value = 0
                        }),
                        digits = 1,
                        value = 0,
                        ref = pixelateRef
                    }
                )
            ),
            Elements.Create(
                Gtk.FlowBox,
                {
                    max_children_per_line = 6,
                    selection_mode = "NONE",
                    margin = 20,
                    ref = function(ref)
                        local els = {
                            Elements.Create("p", nil, "Go Wall"),
                            Elements.Create(Gtk.Switch, {ref = goWallRef, halign = "END"}),
                            Elements.Create("p", nil, "Invert"),
                            Elements.Create(Gtk.Switch, {ref = invertRef, halign = "END"}),
                            Elements.Create("p", nil, "Border"),
                            Elements.Create(Gtk.Switch, {ref = borderRef, halign = "END"}),
                            Elements.Create("p", nil, "Grid"),
                            Elements.Create(Gtk.Switch, {ref = gridRef, halign = "END"}),
                            Elements.Create("p", nil, "Flip"),
                            Elements.Create(Gtk.Switch, {ref = flipRef, halign = "END"}),
                            Elements.Create("p", nil, "Grayscale"),
                            Elements.Create(Gtk.Switch, {ref = grayscaleRef, halign = "END"}),
                            Elements.Create("p", nil, "Mirror"),
                            Elements.Create(Gtk.Switch, {ref = mirrorRef, halign = "END"})
                        }
                        for ____, el in ipairs(els) do
                            ref.add(ref, el)
                        end
                    end
                }
            ),
            Elements.Create(
                "div",
                {spacing = 10, hexpand = true},
                Elements.Create(
                    "button",
                    {
                        hexpand = true,
                        onClick = bgfn("reset")
                    },
                    "Apply"
                ),
                Elements.Create(
                    "button",
                    {
                        hexpand = true,
                        onClick = bgfn("rand")
                    },
                    "Rand Bg"
                ),
                Elements.Create(
                    "button",
                    {
                        hexpand = true,
                        onClick = function()
                            astal.exec_async("bash -c 'rm -fr ~/.local/state/wallpaper-manager/* ~/Pictures/gowall' ", loadImg)
                        end
                    },
                    "Clean Image Cache"
                )
            ),
            Elements.Create(
                "div",
                {spacing = 9, className = "p-2"},
                Elements.Create(
                    "div",
                    {spacing = 10, vertical = true},
                    Elements.Create(Image, {ref = nextImgRef}),
                    Elements.Create(
                        "button",
                        {onClick = bgfn("next")},
                        "Next Bg"
                    )
                ),
                Elements.Create(
                    "div",
                    {spacing = 10, vertical = true},
                    Elements.Create(Image, {ref = prevImgRef}),
                    Elements.Create(
                        "button",
                        {onClick = bgfn("prev")},
                        "Prev Bg"
                    )
                )
            ),
            Elements.Create("hr", nil),
            Elements.Create(
                "button",
                {onClick = function() return astal.exec_async(
                    "bash - c 'theme.sh dark & niri msg action do-screen-transition  --delay-ms 500'",
                    function() return ps.restart() end
                ) end},
                "Dark Mode"
            ),
            Elements.Create(
                "button",
                {onClick = function() return astal.exec_async(
                    "bash - c 'theme.sh light & niri msg action do-screen-transition  --delay-ms 500'",
                    function() return ps.restart() end
                ) end},
                "Light Mode"
            ),
            Elements.Create(
                Gtk.FlowBox,
                {
                    max_children_per_line = 7,
                    selection_mode = "NONE",
                    margin = 20,
                    ref = function(ref)
                        __TS__ArrayForEach(
                            __TS__ArrayFrom(
                                {length = 16},
                                function(____, _, i)
                                    local className = "base" .. __TS__StringPadStart(
                                        string.upper(__TS__NumberToString(i, 16)),
                                        2,
                                        "0"
                                    )
                                    return className
                                end
                            ),
                            function(____, className)
                                ref.add(
                                    ref,
                                    Elements.Create(
                                        "eventbox",
                                        {on_button_press_event = function()
                                            astal.exec_async(((("bash -c 'echo \"" .. tostring(assets.colors[className])) .. "\" | cs; notify-send \"Copied Color: ") .. tostring(assets.colors[className])) .. "\"'")
                                        end},
                                        Elements.Create("div", {
                                            expand = true,
                                            className = "rounded-lg bg-" .. className,
                                            width = 50,
                                            height = 50,
                                            valign = "CENTER",
                                            halign = "CENTER"
                                        }, className)
                                    )
                                )
                            end
                        )
                    end
                }
            )
        )
    )
end
____exports.default = mkPopupToggleAnim(Center, {title = "Center", anchor = TOP + RIGHT + BOTTOM, class_name = "transparent", keymode = "ON_DEMAND"}, {transition_type = Gtk.RevealerTransitionType.SLIDE_RIGHT})
return ____exports
