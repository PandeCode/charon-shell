local M = {}

local json = require "dkjson"
local astal = require "astal"
local bind = astal.bind
local Hyprland = require("lgi").require "AstalHyprland"

local hyprland = Hyprland.get_default()

local toCSS = require("lua.extras.tailwind").toCSS
local utils = require "lua.utils"
local number_to_japanese = utils.number_to_japanese

local el = require "lua.extras.elements"
local p = el.p
local btn = el.btn
local div = el.div

local clean_title = function(title)
	return title:gsub(" %— Zen Twilight", ""):gsub(" %- Nvim", ""):gsub("Zellij %b() %- ", ""):match "^%s*(.-)%s*$"
end

function M.FocusedClient()
	return div({
		bind(hyprland, "focused-client"):as(function(client)
			if client then
				if type(client.title) == "string" then
					local ret = p(clean_title(client.title))
					return ret
				end
			end
			return nil
		end),
	}, "p-1 font-bold")
end

function M.Workspaces()
	local workspaces = bind(hyprland, "workspaces")

	print(utils.inspect(wss))

	return div {
		css = toCSS(),
		bind(hyprland, "focused-workspace"):as(function(focused)
			return div {
				workspaces:as(function(wss)
					table.sort(wss, function(a, b)
						return a.id < b.id
					end)

					return utils.map(wss, function(ws)
						return btn(
							number_to_japanese(ws.id),
							-- "",
							(ws.id == focused.id and "bg-base01" or "hover-bg-base01-25")
								.. " w-1 h-1 m-1 rounded-full",
							function()
								ws:focus()
							end,
							{
								css = toCSS { fontSize = "6px" },
								tooltip_text = number_to_japanese(ws.id),
								valign = "CENTER",
							}
						)
					end)
				end),
			}
		end),
	}
end

return M
