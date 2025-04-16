local utils = require "lua.utils"
local mapping = require("lua.extras.tailwind.data").mapping

local M = {}

function M.toCSS(tbl)
	tbl = tbl or {}
	local css = ""
	for property, value in pairs(tbl) do
		if mapping[property] ~= nil then
			property = mapping[property]
		end
		css = css .. "  " .. property .. ": " .. value .. ";\n"
	end
	return css
end

function M.tcss(tbl)
	return { css = M.toCSS(tbl) }
end

return M
