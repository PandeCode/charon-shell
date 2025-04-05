local M = {}

local json = require("dkjson")
local utils = require("lua.utils")
local astal = require("astal")
local Widget = require("astal.gtk3.widget")

local focus = function(id)
	astal.exec_async("niri msg action focus-workspace " .. id)
end

local clean_title = function(title)

    -- stylua: ignore start
	return title:gsub("Zellij %b() %- ", "")
        :gsub("Zen Twilight", "")
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
	for key, value in pairs(parsed) do
		if value.active_window_id ~= nil or value.is_focused or value.id == 1 or value.id == 2 or value.id == 3 then
			table.insert(final, value)
		end
	end
	return final or {}
end)

function M.FocusedClient()
	return Widget.Box({
		class_name = "Focused",
		focused(function(title)
			return title and Widget.Label({
				label = clean_title(title),
			})
		end),
	})
end

function M.Workspaces()
	return Widget.Box({
		class_name = "Workspaces",
		workspaces(function(wss)
			table.sort(wss, function(a, b)
				return a.id < b.id
			end)

			return utils.map(wss, function(ws)
				if not (ws.id >= -99 and ws.id <= -2) then -- filter out special workspaces
					return Widget.Button({

						class_name = ws.is_focused and "focused" or "",
						on_clicked = function()
							focus(ws.id)
						end,
						label = utils.number_to_japanese(ws.id),
					})
				end
			end)
		end),
	})
end

return M
