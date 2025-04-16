local astal = require("astal")
local Gtk = require("astal.gtk3").Gtk
local Widget = require("astal.gtk3.widget")
local Gdk = require("astal.gtk3").Gdk
local Anchor = astal.require("Astal").WindowAnchor
local bind = astal.bind
local utils = require("lua.utils")
local utils_a = require("lua.utils.astal")
local ps = require("lua.utils.ps")
local logger = require("lua.logger")
local assets = require("lua.assets")

local elements = require("lua.extras.elements")
local div = elements.div
local divv = elements.divv
local p = elements.p
local btn = elements.btn
local btni = elements.btni
local vscroll = elements.vscroll
local fn_exe = utils.fn_exe

local function mkAniList(list)
	return utils.map(list, function(v)
		return div(
			{
				-- elements.img(v.coverImage),
				elements.imgv(
					astal.Variable(assets.default_image_path):poll(86400, "echo", function()
						return utils.getFile(v.coverImage) or assets.default_image_path
					end),
					2,
					3
				),
				divv({
					p(utils.truncate(v.title.english, 40)),
					p(utils.truncate(v.title.romaji, 40)),
					p(v.progress .. "/" .. (v.episodes or v.chapters or "0")),

					v.nextAiringEpisode and v.nextAiringEpisode.airingAt and p(
						"Airing At: " .. os.date("%c", v.nextAiringEpisode.airingAt)
					) or nil,

					v.nextAiringEpisode and v.nextAiringEpisode.episode and p(
						"Next Episode: " .. v.nextAiringEpisode.episode
					) or nil,

					v.tags and #v.tags > 0 and p("Tags: " .. table.concat(utils.slice(v.tags, 0, 4), ", ")) or nil,
				}, "p-2", { css = "", hexpand = true, halign = Gtk.Align.START }),
			},
			"card p-2 m-2 rounded-md shadow-lg",
			{
				hexpand = true,
				vexpand = true,
			}
		)
	end)
end

local function CenterWindow()
	local anilist = require("lua.extras.anime")()
	local anime_widgets = anilist ~= nil and mkAniList(anilist.anime) or p("No anime")
	local manga_widgets = anilist ~= nil and mkAniList(anilist.manga) or p("No anime")

	return Widget.Window({
		title = "Center",
		anchor = Anchor.TOP + Anchor.RIGHT + Anchor.BOTTOM,
		css = "margin: 20px; padding: 20px;",
		class_name = "transparent",
		Widget.Box({
			vertical = true,
			css = "min-width: 30rem;",
			class_name = "bg-base00",
			-- Gtk.Expander(
			div({
				label = "Anime",
				vscroll({
					div(divv(anime_widgets, "card"), "m-2 p-2", {
						css = "min-width: 25em;",
					}),
					"",
					{ css = "min-width: 30em;" },
				}),
			}), -- )
			-- Gtk.Expander(
			div({
				label = "Manga",
				vscroll({
					div(divv(manga_widgets, "card"), "m-2 p-2", {
						css = "min-width: 25em;",
					}),
					"",
					{ css = "min-width: 30em;" },
				}),
			}), -- )
		}),
	})
end

return utils_a.mkPopupToggle(CenterWindow)
