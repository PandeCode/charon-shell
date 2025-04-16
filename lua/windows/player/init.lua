local astal = require "astal"
local Anchor = astal.require("Astal").WindowAnchor
local Astal = astal.require "Astal"

local bind = astal.bind
local Widget = require "astal.gtk3.widget"
local lookup_icon = Astal.Icon.lookup_icon

local el = require "lua.extras.elements"
local p = el.p
local img = el.img
local btni = el.btni
local div = el.div
local divv = el.divv

local utils = require "lua.utils"
local utils_a = require "lua.utils.astal"
local map = utils.map
local css = require("lua.extras.tailwind").toCSS

local Mpris = astal.require "AstalMpris"

local ensure_icon = utils_a.ensure_icon

local function MediaPlayer(player)
	local title = bind(player, "title"):as(function(t)
		return t or "Unknown Track"
	end)

	local artist = bind(player, "artist"):as(function(a)
		return a or "Unknown Artist"
	end)

	local cover_art = bind(player, "cover-art"):as(function(c)
		return img(c, 6, 6, "rounded-lg", {})
	end)

	-- Ensure player icon exists
	local player_icon = bind(player, "entry"):as(function(e)
		return ensure_icon(e, "audio-x-generic-symbolic")
	end)

	local position = bind(player, "position"):as(function(p)
		return player.length > 0 and p / player.length or 0
	end)

	-- Fixed playback status icon handling
	local play_icon = bind(player, "playback-status"):as(function(s)
		if s == "PLAYING" then
			return ensure_icon("media-playback-pause-symbolic", "gtk-media-pause")
		else
			return ensure_icon("media-playback-start-symbolic", "gtk-media-play")
		end
	end)

	return Widget.Box {
		class_name = "MediaPlayer",
		cover_art,
		Widget.Box {
			vertical = true,
			class_name = "p-2",
			div({
				p(title, nil, {
					hexpand = true,
					ellipsize = "END",
					halign = "START",
				}),
				btni(player_icon, nil, function()
					player:raise()
				end, { sensitive = bind(player, "can-raise") }),
			}, "font-bold text-xl"),
			Widget.Label {
				halign = "START",
				valign = "START",
				vexpand = true,
				wrap = true,
				label = artist,
			},
			Widget.Slider {
				visible = bind(player, "length"):as(function(l)
					return l > 0
				end),
				on_dragged = function(event)
					player.position = event.value * player.length
				end,
				value = position,
			},
			Widget.CenterBox {
				p(bind(player, "position"):as(utils.strlen), nil, {
					hexpand = true,
					halign = "START",
					visible = bind(player, "length"):as(function(l)
						return l > 0
					end),
				}),
				div {
					-- Improved loop status icon handling
					bind(player, "loop-status"):as(function(v)
						if v == nil or v == "UNSUPPORTED" then
							return nil
						end

						local icon_name
						local c = ""
						if v == "NONE" or v == "OFF" then
							icon_name = ensure_icon("media-playlist-repeat-symbolic", "gtk-media-repeat")
						elseif v == "TRACK" then
							icon_name = ensure_icon("media-playlist-repeat-song-symbolic", "gtk-media-repeat")
							c = "bg-base01"
						elseif v == "PLAYLIST" then
							icon_name = ensure_icon("media-playlist-repeat-symbolic", "gtk-media-repeat")
							c = "bg-base01"
						else
							utils.notify("Unknown loop status: " .. tostring(v))
							icon_name = "dialog-error-symbolic"
						end

						return btni(icon_name, "m-1 h-0 w-0 " .. c, function()
							player:loop()
						end, { visible = true })
					end),

					-- Previous button with fallback icon
					btni(ensure_icon("media-skip-backward-symbolic", "gtk-media-previous"), "m-1 h-0 w-0", function()
						player:previous()
					end, { visible = bind(player, "can-go-previous") }),

					-- Play/pause button with fallback icon
					btni(play_icon, "m-1 h-0 w-0", function()
						player:play_pause()
					end, { visible = bind(player, "can-control") }),

					-- Next button with fallback icon
					btni(ensure_icon("media-skip-forward-symbolic", "gtk-media-next"), "m-1 h-0 w-0", function()
						player:next()
					end, { visible = bind(player, "can-go-next") }),

					-- Improved shuffle status icon handling
					bind(player, "shuffle-status"):as(function(s)
						if s == nil or s == "UNSUPPORTED" then
							return nil
						end

						return btni(
							ensure_icon("media-playlist-shuffle-symbolic", "gtk-media-shuffle"),
							"m-1 h-0 w-0",
							function()
								player:shuffle()
							end,
							{
								visible = true,
								-- Apply visual indication of shuffle state
								class_name = (s == "ON") and "bg-base01" or "",
							}
						)
					end),
				},
				p(
					bind(player, "length"):as(function(l)
						return l > 0 and utils.strlen(l) or "0:00"
					end),
					nil,
					{
						hexpand = true,
						halign = "END",
						visible = bind(player, "length"):as(function(l)
							return l > 0
						end),
					}
				),
			},
		},
	}
end

local function Players()
	local mpris = Mpris.get_default()

	return Widget.Box {
		vertical = true,
		css = css { minWidth = "500px" },
		class_name = "rounded-lg bg-base00-90 m-2 p-2 border-solid border-base02 border-2 shadow",
		bind(mpris, "players"):as(function(players)
			return map(players, MediaPlayer)
		end),
	}
end

local utils_a = require "lua.utils.astal"
return utils_a.mkPopupToggleAnim(Players, {
	anchor = Anchor.TOP,
	class_name = "transparent",
})
