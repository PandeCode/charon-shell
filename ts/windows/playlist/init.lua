local ____lualib = require("lualib_bundle")
local __TS__ArrayMap = ____lualib.__TS__ArrayMap
local ____exports = {}
local ____react = require("tslib.react")
local astal = ____react.astal
local Gtk = ____react.Gtk
local Elements = ____react.Elements
local useCmd = ____react.useCmd
local assets = require("lua.assets")
local json = require("dkjson")
local ____require_result_0 = require("lua.utils.astal")
local mkPopupToggleAnim = ____require_result_0.mkPopupToggleAnim
local ____require_result_1 = require("lua.utils")
local lastIndexOf = ____require_result_1.lastIndexOf
local ninspect = ____require_result_1.ninspect
local notify = ____require_result_1.notify
local ____astal_2 = astal
local exec_async = ____astal_2.exec_async
local function SpotifyDashboard()
    local user = useCmd("spotify.sh me", json.decode)
    local nowPlaying = useCmd("spotify.sh now_playing", json.decode)
    local playlists = useCmd("spotify.sh playlists 10 0", json.decode)
    local liked = useCmd("spotify.sh liked_songs 10 0", json.decode)
    local devices = useCmd("spotify.sh devices", json.decode)
    local topArtists = useCmd("spotify.sh top_artists 5 short_term", json.decode)
    local topTracks = useCmd("spotify.sh top_tracks 5 short_term", json.decode)
    return Elements.Create(
        "div",
        {vertical = true, className = "bg-base00-90 text-base05 p-6 rounded-lg", css = {minWidth = "1080px", minHeight = "720px", overflow = "auto"}},
        Elements.Create(
            "div",
            {className = "text-xl mb-4"},
            user._v(function(u)
                local ____u_3
                if u then
                    ____u_3 = Elements.Create(
                        "p",
                        nil,
                        "🎧 ",
                        u.display_name,
                        " (",
                        u.product,
                        ")"
                    )
                else
                    ____u_3 = Elements.Create(Gtk.Spinner, nil)
                end
                return ____u_3
            end)
        ),
        Elements.Create(
            "div",
            {spacing = 2, className = "my-4"},
            nowPlaying._v(function(np)
                local ____temp_4
                if np and np.item then
                    ____temp_4 = Elements.Create(
                        "div",
                        {vertical = true},
                        Elements.Create("p", {className = "text-base0D"}, "Now Playing:"),
                        Elements.Create(
                            "p",
                            nil,
                            np.item.name,
                            " —",
                            " ",
                            np.item.artists.map(function(a) return a.name end).join(", ")
                        ),
                        Elements.Create(
                            "div",
                            {spacing = 1, className = "mt-2"},
                            Elements.Create(
                                "button",
                                {
                                    className = "bg-base03 px-2 py-1 rounded",
                                    onClick = function() return exec_async("spotify.sh previous") end
                                },
                                "⏮"
                            ),
                            Elements.Create(
                                "button",
                                {
                                    className = "bg-base03 px-2 py-1 rounded",
                                    onClick = function() return exec_async("spotify.sh pause") end
                                },
                                "⏸"
                            ),
                            Elements.Create(
                                "button",
                                {
                                    className = "bg-base03 px-2 py-1 rounded",
                                    onClick = function() return exec_async("spotify.sh play") end
                                },
                                "▶️"
                            ),
                            Elements.Create(
                                "button",
                                {
                                    className = "bg-base03 px-2 py-1 rounded",
                                    onClick = function() return exec_async("spotify.sh next") end
                                },
                                "⏭"
                            )
                        )
                    )
                else
                    ____temp_4 = Elements.Create("p", nil, "No track playing")
                end
                return ____temp_4
            end)
        ),
        Elements.Create(
            "div",
            {className = "my-4"},
            Elements.Create("p", {className = "text-base0D mb-2"}, "Devices:"),
            devices._v(function(d) return d and d.devices and __TS__ArrayMap(
                d.devices,
                function(____, dev) return Elements.Create(
                    "p",
                    nil,
                    dev.name,
                    " (",
                    dev.type,
                    ") ",
                    dev.is_active and "✅" or ""
                ) end
            ) or Elements.Create("p", nil, "No devices") end)
        ),
        Elements.Create(
            "div",
            {vertical = true, className = "my-4", spacing = 10},
            Elements.Create("p", {className = "text-base0D"}, "Playlists:"),
            playlists._v(function(pl) return pl and pl.items and __TS__ArrayMap(
                pl.items,
                function(____, p) return Elements.Create(
                    "button",
                    {
                        onClick = function() return astal.exec("playerctl -p spotify_player open " .. tostring(p.id)) end,
                        className = "cursor-pointer hover:text-base0A"
                    },
                    p.name
                ) end
            ) or Elements.Create(Gtk.Spinner, nil) end)
        ),
        Elements.Create(
            "div",
            {vertical = true, className = "my-4"},
            Elements.Create("p", {className = "text-base0D"}, "Liked Songs:"),
            liked._v(function(lk) return lk and lk.items and __TS__ArrayMap(
                lk.items,
                function(____, t) return Elements.Create(
                    "p",
                    nil,
                    t.track.name,
                    " —",
                    " ",
                    t.track.artists.map(function(a) return a.name end).join(", ")
                ) end
            ) or Elements.Create(Gtk.Spinner, nil) end)
        ),
        Elements.Create(
            "div",
            {spacing = 2, vertical = true, className = "my-4"},
            Elements.Create(
                "div",
                nil,
                Elements.Create("p", {className = "text-base0D"}, "Top Artists:"),
                topArtists._v(function(ta) return ta and ta.items and __TS__ArrayMap(
                    ta.items,
                    function(____, a) return Elements.Create("p", nil, a.name) end
                ) or Elements.Create(Gtk.Spinner, nil) end)
            ),
            Elements.Create(
                "div",
                {className = "mt-2"},
                Elements.Create("p", {className = "text-base0D"}, "Top Tracks:"),
                topTracks._v(function(tt) return tt and tt.items and __TS__ArrayMap(
                    tt.items,
                    function(____, t) return Elements.Create("p", nil, t.name) end
                ) or Elements.Create(Gtk.Spinner, nil) end)
            )
        )
    )
end
____exports.default = mkPopupToggleAnim(SpotifyDashboard, {title = "Spotify CLI UI", class_name = "transparent", keymode = "ON_DEMAND"}, {transition_type = Gtk.RevealerTransitionType.SLIDE_RIGHT})
return ____exports
