local astal = require("astal")
local Gtk = require("astal.gtk3").Gtk
local Widget = require("astal.gtk3.widget")
local Gdk = require("astal.gtk3").Gdk
local Anchor = astal.require("Astal").WindowAnchor
local bind = astal.bind
local utils = require("lua.utils")
local logger = require("lua.logger")

local elements = require("lua.extras.elements")
local div = elements.div
local divv = elements.divv
local p = elements.p
local btn = elements.btn
local btni = elements.btni
local vscroll = elements.vscroll

local fn_exe = utils.fn_exe

local function CenterWindow()
	local toggle_anime = astal.Variable(false)
	local show_manga = astal.Variable(false)

	local anime = require("lua.extras.anime")()
	local anime_widgets = utils.map(anime.anime, function(v)
		return div(
			{
				elements.img(utils.getFile(v.coverImage), 2, 3),
				divv({
					p(utils.truncate(v.title.english, 40)),
					p(utils.truncate(v.title.romaji, 40)),
					p(v.progress .. "/" .. (v.episodes or "0")),
				}, "p-2", { css = "", hexpand = true, halign = Gtk.Align.START }),
			},
			"card p-2 m-2 rounded-md shadow-lg",
			{
				hexpand = true,
				vexpand = true,
			}
		)
	end)
	---nextAiringEpisode.airingAt number|nil Unix timestamp of when the next episode airs
	---nextAiringEpisode.episode number|nil The episode number that will air next
	---tags string[] List of tags associated with the anime
	-- print(utils.inspect(anime:get().anime))

	local manga_widgets = utils.map(anime.manga, function(v)
		return div(
			{
				elements.img(utils.getFile(v.coverImage), 2, 3),
				divv({
					p(utils.truncate(v.title.english, 40)),
					p(utils.truncate(v.title.romaji, 40)),
					div({
						astal.Variable(v.progress)(function(k)
							if k ~= nil then
								return p(k .. "/" .. (v.chapters or "0"))
							end
						end),
						astal.Variable(v.volumes)(function(k)
							if k ~= nil then
								return p("(" .. v.progressVolumes .. "/" .. k .. ")")
							end
						end),
					}),
				}, "p-2", { css = "", hexpand = true, halign = Gtk.Align.START }),
			},
			"card p-2 m-2 rounded-md shadow-lg",
			{
				hexpand = true,
				vexpand = true,
			}
		)
	end)

	return Widget.Window({
		title = "Center",
		anchor = Anchor.TOP + Anchor.RIGHT + Anchor.BOTTOM,
		Widget.Box({
			vertical = true,
			css = "min-width: 30rem;",
			Gtk.Expander({
				label = "Theme and Background",
				div({
					Gtk.Grid({
						btn("Dark Mode", "Btn", fn_exe("theme.sh dark")),
						btn("Light Mode", "Btn", fn_exe("theme.sh light")),
					}),
					Gtk.Grid({
						btn("Rand Bg", "Btn", fn_exe("bg.sh rand")),
						btn("Last Bg", "Btn", fn_exe("bg.sh last")),
						btn("Next Bg", "Btn", fn_exe("bg.sh next")),
						btn("Prev Bg", "Btn", fn_exe("bg.sh prev")),
						btn("Reset Bg", "Btn", fn_exe("bg.sh reset")),
					}),
				}),
			}),
			Gtk.Expander({
				label = "Anime",
				vscroll({
					div(divv(anime_widgets, "card"), "m-2 p-2", {
						css = "min-width: 25em;",
					}),
					"",
					{ css = "min-width: 30em;" },
				}),
			}),
			Gtk.Expander({
				label = "Manga",
				vscroll({
					div(divv(manga_widgets, "card"), "m-2 p-2", {
						css = "min-width: 25em;",
					}),
					"",
					{ css = "min-width: 30em;" },
				}),
			}),
		}),
	})
end

return utils.mkPopupToggle(CenterWindow)
