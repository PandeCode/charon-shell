local astal = require("astal")
local Anchor = astal.require("Astal").WindowAnchor
local Astal = astal.require("Astal")

local bind = astal.bind
local Widget = require("astal.gtk3.widget")
local lookup_icon = Astal.Icon.lookup_icon

local utils = require("lua.utils")
local map = utils.map

local Mpris = astal.require("AstalMpris")

local function MediaPlayer(player)
	local title = bind(player, "title"):as(function(t)
		return t or "Unknown Track"
	end)

	local artist = bind(player, "artist"):as(function(a)
		return a or "Unknown Artist"
	end)

	local art = astal.Variable(""):poll(5000, "album_art.sh", function(out)
		return out
	end)
	local cover_art = art(function(c)
		return string.format("background-image: url('%s');", c)
	end)

	local player_icon = bind(player, "entry"):as(function(e)
		return lookup_icon(e) and e or "audio-x-generic-symbolic"
	end)

	local position = bind(player, "position"):as(function(p)
		return player.length > 0 and p / player.length or 0
	end)

	local play_icon = bind(player, "playback-status"):as(function(s)
		return s == "PLAYING" and "media-playback-pause-symbolic" or "media-playback-start-symbolic"
	end)

	return Widget.Box({
		class_name = "MediaPlayer",
		Widget.Box({
			class_name = "cover-art",
			css = cover_art,

			on_destroy = function()
				art:drop()
			end,
		}),
		Widget.Box({
			vertical = true,
			Widget.Box({
				class_name = "title",
				Widget.Label({
					ellipsize = "END",
					hexpand = true,
					halign = "START",
					label = title,
				}),
				Widget.Icon({
					icon = player_icon,
				}),
			}),
			Widget.Label({
				halign = "START",
				valign = "START",
				vexpand = true,
				wrap = true,
				label = artist,
			}),
			Widget.Slider({
				visible = bind(player, "length"):as(function(l)
					return l > 0
				end),
				on_dragged = function(event)
					player.position = event.value * player.length
				end,
				value = position,
			}),
			Widget.CenterBox({
				class_name = "actions",
				Widget.Label({
					hexpand = true,
					class_name = "position",
					halign = "START",
					visible = bind(player, "length"):as(function(l)
						return l > 0
					end),
					label = bind(player, "position"):as(utils.strlen),
				}),
				Widget.Box({
					Widget.Button({
						on_clicked = function()
							player:previous()
						end,
						visible = bind(player, "can-go-previous"),
						Widget.Icon({
							icon = "media-skip-backward-symbolic",
						}),
					}),
					Widget.Button({
						on_clicked = function()
							player:play_pause()
						end,
						visible = bind(player, "can-control"),
						Widget.Icon({
							icon = play_icon,
						}),
					}),
					Widget.Button({
						on_clicked = function()
							player:next()
						end,
						visible = bind(player, "can-go-next"),
						Widget.Icon({
							icon = "media-skip-forward-symbolic",
						}),
					}),
				}),
				Widget.Label({
					class_name = "length",
					hexpand = true,
					halign = "END",
					visible = bind(player, "length"):as(function(l)
						return l > 0
					end),
					label = bind(player, "length"):as(function(l)
						return l > 0 and utils.strlen(l) or "0:00"
					end),
				}),
			}),
		}),
	})
end

local function Players()
	local mpris = Mpris.get_default()

	return Widget.Box({
		vertical = true,
		bind(mpris, "players"):as(function(players)
			utils.pinspect(players)
			return map(players, MediaPlayer)
		end),
	})
end

return utils.mkPopupToggle(Players)
