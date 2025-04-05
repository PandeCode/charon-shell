local astal = require("astal")
local logger = require("lua.logger")

local M = {}

function M.trim(s)
	return s:match("^%s*(.-)%s*$")
end

-- Truncates a string to max_length characters
-- If the string is longer than max_length, it will be truncated and the suffix will be appended
-- @param s The string to truncate
-- @param max_length The maximum length of the returned string (including suffix)
-- @param suffix The suffix to append if truncation occurs (default: "...")
-- @return The truncated string
function M.truncate(s, max_length, suffix)
	suffix = suffix or "..."

	if not s or type(s) ~= "string" then
		return s
	end

	if #s <= max_length then
		return s
	end

	-- If max_length is too small to fit even the suffix, just return the start of the string
	if max_length <= #suffix then
		return string.sub(s, 1, max_length)
	end

	-- Return the truncated string with the suffix
	return string.sub(s, 1, max_length - #suffix) .. suffix
end

function M.src(path)
	local str = debug.getinfo(2, "S").source:sub(2)
	local src = str:match("(.*/)") or str:match("(.*\\)") or "./"
	return src .. path
end

---@generic T, R
---@param array T[]
---@param func fun(T, i: integer): R
---@return R[]
function M.map(array, func)
	local new_arr = {}
	for i, v in ipairs(array) do
		new_arr[i] = func(v, i)
	end
	return new_arr
end

---@generic T
---@param array T[]
---@param start integer
---@param stop? integer
---@return T[]
function M.slice(array, start, stop)
	local new_arr = {}

	stop = stop or #array

	for i = start, stop do
		table.insert(new_arr, array[i])
	end

	return new_arr
end

local japanese_numbers = {
	[0] = "零",
	[1] = "一",
	[2] = "二",
	[3] = "三",
	[4] = "四",
	[5] = "五",
	[6] = "六",
	[7] = "七",
	[8] = "八",
	[9] = "九",
}

function M.number_to_japanese(num)
	local result = ""
	for digit in tostring(num):gmatch(".") do
		result = result .. japanese_numbers[tonumber(digit)]
	end
	return result
end

function IsImage(file)
	local extensions = { ".jpeg", ".webp", ".png", ".jpg", ".gif" }
	for _, ext in ipairs(extensions) do
		if file:sub(-#ext) == ext then
			return true
		end
	end
	return false
end
function M.Dump(o)
	if type(o) == "table" then
		local s = "{ "
		for k, v in pairs(o) do
			if type(k) ~= "number" then
				k = '"' .. k .. '"'
			end
			s = s .. "[" .. k .. "] = " .. M.Dump(v) .. ","
		end
		return s .. "} "
	else
		return tostring(o)
	end
end

function RandFrom(list)
	math.randomseed(os.time())
	return list[math.random(1, #list)]
end

function RandBool()
	math.randomseed(os.time())
	return math.random(0, 1) == 1
end

function RandStr(length)
	local res = ""
	for _ = 1, length do
		res = res .. string.char(math.random(97, 122))
	end
	return res
end

-- stylua: ignore start
SUPERSCRIPTS = {
	["0"] = "⁰", ["1"] = "¹", ["2"] = "²", ["3"] = "³",
	["4"] = "⁴", ["5"] = "⁵", ["6"] = "⁶", ["7"] = "⁷",
	["8"] = "⁸", ["9"] = "⁹",
	["a"] = "ᵃ", ["b"] = "ᵇ", ["c"] = "ᶜ", ["d"] = "ᵈ",
	["e"] = "ᵉ", ["f"] = "ᶠ", ["g"] = "ᶢ", ["h"] = "ʰ",
	["i"] = "ⁱ", ["j"] = "ʲ", ["k"] = "ᵏ", ["l"] = "ˡ",
	["m"] = "ᵐ", ["n"] = "ⁿ", ["o"] = "ᵒ", ["p"] = "ᵖ",
	["r"] = "ʳ", ["s"] = "ˢ", ["t"] = "ᵗ", ["u"] = "ᵘ",
	["v"] = "ᵛ", ["w"] = "ʷ", ["x"] = "ˣ", ["y"] = "ʸ",
	["z"] = "ᶻ",
	["A"] = "ᴬ", ["B"] = "ᴮ", ["D"] = "ᴰ", ["E"] = "ᴱ",
	["G"] = "ᴳ", ["H"] = "ᴴ", ["I"] = "ᴵ", ["J"] = "ᴶ",
	["K"] = "ᴷ", ["L"] = "ᴸ", ["M"] = "ᴹ", ["N"] = "ᴺ",
	["O"] = "ᴼ", ["P"] = "ᴾ", ["R"] = "ᴿ", ["T"] = "ᵀ",
	["U"] = "ᵁ", ["V"] = "ⱽ", ["W"] = "ᵂ",
	["+"] = "⁺", ["-"] = "⁻", ["="] = "⁼", ["("] = "⁽",
	[")"] = "⁾"
}

SUBSCRIPTS = {
	["0"] = "₀", ["1"] = "₁", ["2"] = "₂", ["3"] = "₃",
	["4"] = "₄", ["5"] = "₅", ["6"] = "₆", ["7"] = "₇",
	["8"] = "₈", ["9"] = "₉",
	["a"] = "ₐ", ["e"] = "ₑ", ["h"] = "ₕ", ["i"] = "ᵢ",
	["j"] = "ⱼ", ["k"] = "ₖ", ["l"] = "ₗ", ["m"] = "ₘ",
	["n"] = "ₙ", ["o"] = "ₒ", ["p"] = "ₚ", ["r"] = "ᵣ",
	["s"] = "ₛ", ["t"] = "ₜ", ["u"] = "ᵤ", ["v"] = "ᵥ",
	["x"] = "ₓ",
	["+"] = "₊", ["-"] = "₋", ["="] = "₌", ["("] = "₍",
	[")"] = "₎"
}
-- stylua: ignore end

local function applyMapping(s, map)
	local result = ""

	for i = 1, #s do
		local char = s:sub(i, i)
		if map[char] then
			result = result .. map[char]
		end
	end

	return result
end

function M.ToSuperscript(s)
	return applyMapping(s, SUPERSCRIPTS)
end

function M.ToSubscript(s)
	return applyMapping(s, SUBSCRIPTS)
end

-- https://github.com/rachartier/dotfiles/blob/main/.config/nvim/lua/utils.lua
--- Converts a value to a list
---@param value any # any value that will be converted to a list
---@return any[] # the listified version of the value
function M.ToList(value)
	if value == nil then
		return {}
	elseif type(value) == "table" then
		local list = {}
		for _, item in ipairs(value) do
			table.insert(list, item)
		end

		return list
	else
		return { value }
	end
end

function M.Eval(val)
	if type(val) == "function" then
		return val()
	end
	return val
end

function M.Info(msg)
	astal.exec_async("notify-send '" .. msg:gsub("'", "'\\''") .. "'")
end

function M.info(msg)
	print(msg)
end

function M.mkPopupToggle(Window)
	local window = nil
	local window_visible = astal.Variable(false)

	local function toggle()
		if window_visible:get() and window then
			window:hide()
			window_visible:set(false)
		else
			if not window then
				window = Window()
			end
			window:show_all()
			window_visible:set(true)
		end
	end

	return toggle
end
---
---@param length integer
function M.strlen(length)
	local min = math.floor(length / 60)
	local sec = math.floor(length % 60)

	return string.format("%d:%s%d", min, sec < 10 and "0" or "", sec)
end

function M.inspect(obj)
	return M.Dump(obj)
end

function M.serialize(obj, options)
	options = options or {}

	-- Options with defaults
	local depth = options.depth or math.huge
	local newline = options.newline or "\n"
	local indent = options.indent or "  "
	local process_item = options.process_item or function(item)
		return item
	end

	-- Track tables we've seen to handle recursive references
	local seen = {}

	-- Forward declaration for mutual recursion
	local _inspect

	-- Format simple values
	local function format_value(value)
		local value_type = type(value)
		if value_type == "string" then
			return string.format("%q", value)
		elseif value_type == "number" or value_type == "boolean" or value_type == "nil" then
			return tostring(value)
		elseif value_type == "function" then
			return "function() --[[ ... ]] end"
		else
			return tostring(value)
		end
	end

	-- Format table key for display
	local function format_key(key)
		if type(key) == "string" and key:match("^[%a_][%a%d_]*$") then
			return key
		else
			return "[" .. format_value(key) .. "]"
		end
	end

	-- Main inspection function
	_inspect = function(obj, current_depth)
		local value_type = type(obj)

		-- Handle non-table values
		if value_type ~= "table" then
			return format_value(obj)
		end

		-- Check if we've seen this table before (circular reference)
		if seen[obj] then
			return "<circular reference>"
		end

		-- Check depth limit
		if current_depth >= depth then
			return "{...}"
		end

		-- Mark this table as seen
		seen[obj] = true

		local result = {}
		local has_items = false

		-- Get sorted list of keys
		local keys = {}
		for k in pairs(obj) do
			table.insert(keys, k)
		end
		table.sort(keys, function(a, b)
			if type(a) == "number" and type(b) == "number" then
				return a < b
			else
				return tostring(a) < tostring(b)
			end
		end)

		-- Generate indentation string
		local indent_str = string.rep(indent, current_depth)
		local next_indent_str = string.rep(indent, current_depth + 1)

		-- Process each key-value pair
		for _, key in ipairs(keys) do
			local value = process_item(obj[key])
			local formatted_key = format_key(key)
			local formatted_value = _inspect(value, current_depth + 1)

			table.insert(result, next_indent_str .. formatted_key .. " = " .. formatted_value)
			has_items = true
		end

		-- Handle empty tables
		if not has_items then
			return "{}"
		end

		-- Format the result with proper indentation
		return "{" .. newline .. table.concat(result, "," .. newline) .. newline .. indent_str .. "}"
	end

	-- Start the inspection at depth 0
	return _inspect(obj, 0)
end

---A helper function to print a table's contents.
---@param tbl table @The table to print.
---@param depth number @The depth of sub-tables to traverse through and print.
---@param n number @Do NOT manually set this. This controls formatting through recursion.
function M.pinspect(tbl, depth, n)
	n = n or 0
	depth = depth or 5

	if depth == 0 then
		print(string.rep(" ", n) .. "...")
		return
	end

	if n == 0 then
		print(" ")
	end

	for key, value in pairs(tbl) do
		if key and type(key) == "number" or type(key) == "string" then
			key = string.format('["%s"]', key)

			if type(value) == "table" then
				if next(value) then
					print(string.rep(" ", n) .. key .. " = {")
					M.pinspect(value, depth - 1, n + 4)
					print(string.rep(" ", n) .. "},")
				else
					print(string.rep(" ", n) .. key .. " = {},")
				end
			else
				if type(value) == "string" then
					value = string.format('"%s"', value)
				else
					value = tostring(value)
				end

				print(string.rep(" ", n) .. key .. " = " .. value .. ",")
			end
		end
	end

	if n == 0 then
		print(" ")
	end
end

function M.getFile(url)
	if not url then
		return nil
	end

	local http = require("socket.http")
	local lfs = require("lfs")
	local ltn12 = require("ltn12")
	local os = require("os")

	-- Create cache directory if it doesn't exist
	local cache_dir = os.getenv("HOME") .. "/.cache/charon-shell/files/"
	local success = os.execute("mkdir -p " .. cache_dir)
	if not success then
		logger.error("Failed to create cache directory: " .. cache_dir)
		return nil
	end

	-- Generate MD5 hash of the URL using command line md5sum
	local md5_command = "echo -n '" .. url .. "' | md5sum | awk '{print $1}'"
	local md5_pipe = io.popen(md5_command)
	if not md5_pipe then
		logger.error("Failed to run md5sum command")
		return nil
	end

	local url_hash = md5_pipe:read("*l")
	md5_pipe:close()

	-- Extract file extension from URL if present
	local extension = url:match("%.([^%.]+)$") or ""
	if extension ~= "" then
		extension = "." .. extension
	end

	local filename = url_hash .. extension
	local filepath = cache_dir .. filename

	-- Check if file already exists
	if lfs.attributes(filepath) then
		logger.debug("Using cached file: " .. filepath)
		return filepath
	end

	-- Download the file
	logger.debug("Downloading: " .. url)
	local response_body = {}

	local res, code, headers = http.request({
		url = url,
		sink = ltn12.sink.table(response_body),
		redirect = true,
	})

	if code ~= 200 then
		logger.error("Failed to download file: " .. url .. " (Status code: " .. code .. ")")
		return nil
	end

	-- Save file to disk
	local file = io.open(filepath, "wb")
	if not file then
		logger.error("Failed to open file for writing: " .. filepath)
		return nil
	end

	file:write(table.concat(response_body))
	file:close()

	logger.debug("File saved to: " .. filepath)
	return filepath
end

--- Merges multiple tables into a new table
-- @param ... Any number of tables to be merged
-- @return A new table containing all key-value pairs from the input tables
function M.merge(...)
	local result = {}
	for _, t in ipairs({ ... }) do
		if type(t) == "table" then
			for k, v in pairs(t) do
				result[k] = v
			end
		end
	end
	return result
end

function M.fn_exe(cmd)
	return function()
		os.execute(cmd)
	end
end

return M
