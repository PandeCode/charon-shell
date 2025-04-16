local M = {}

local json = require "dkjson"
local astal = require "astal"

local utils = require "lua.utils"
local number_to_japanese = utils.number_to_japanese

local el = require "lua.extras.elements"
local p = el.p
local btn = el.btn
local div = el.div

local focus = function(id)
	astal.exec_async("niri msg action focus-workspace " .. id)
end

local clean_title = function(title)
    -- stylua: ignore start
	return title :gsub(" %— Zen Twilight", "")
                    :gsub(" %- Nvim", "")
                    :gsub("Zellij %b() %- ", "")
                    :match("^%s*(.-)%s*$")
	-- stylua: ignore end
end

local focused = astal.Variable('{"title": "None"}'):poll(500, "niri msg --json focused-window", function(out)
	local parsed, _, err = json.decode(out, 1, nil)
	if err then
		print("Error parsing JSON:", err)
		return ""
	end
	if parsed ~= nil then
		return parsed.title
	end
	return nil
end)
local workspaces = astal.Variable({}):poll(500, "niri msg --json workspaces", function(out)
	local parsed, _, err = json.decode(out, 1, nil)
	if err then
		print("Error parsing JSON:", err)
	end
	local final = {}
	for _, value in pairs(parsed) do
		if value.active_window_id ~= nil or value.is_focused or value.id == 1 or value.id == 2 or value.id == 3 then
			table.insert(final, value)
		end
	end
	return final or {}
end)

function M.FocusedClient()
	return div({
		focused(function(title)
			if type(title) == "string" then
				local ret = p(clean_title(title))

				return ret
			end
			return nil
		end),
	}, "p-1 font-bold")
end

local toCSS = require("lua.extras.tailwind").toCSS

function M.Workspaces()
	return div {
		css = toCSS(),
		workspaces(function(wss)
			table.sort(wss, function(a, b)
				return a.id < b.id
			end)
			return utils.map(wss, function(ws)
				if not (ws.id >= -99 and ws.id <= -2) then -- filter out special workspaces
					return btn(
						number_to_japanese(ws.id),
						-- "",
						(ws.is_focused and "bg-base01" or "hover-bg-base01-25") .. " w-1 h-1 m-1 rounded-full",
						function()
							focus(ws.id)
						end,
						{
							css = toCSS { fontSize = "6px" },
							tooltip_text = number_to_japanese(ws.id),
							valign = "CENTER",
						}
					)
				end
				return p {
					"Error with Niri workspaces",
				}
			end)
		end),
	}
end

return M
