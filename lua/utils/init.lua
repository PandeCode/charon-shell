--[[
  Utility Module (M)

  A collection of helper functions for string manipulation, array operations,
  data transformation, and general utilities.
]]

local M = {}

--- Trims whitespace from both ends of a string
-- @param s (string) The string to trim
-- @return (string) The trimmed string
-- @usage local trimmed = M.trim("  hello world  ") -- Returns "hello world"
function M.trim(s)
	return s:match "^%s*(.-)%s*$"
end

--- Truncates a string to max_length characters
-- If the string is longer than max_length, it will be truncated and the suffix will be appended
-- @param s (string) The string to truncate
-- @param max_length (number) The maximum length of the returned string (including suffix)
-- @param suffix (string, optional) The suffix to append if truncation occurs (default: "...")
-- @return (string) The truncated string
-- @usage local shortened = M.truncate("Hello world", 7) -- Returns "Hell..."
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

--- Returns the directory path of the current source file combined with the provided path
-- @param path (string) The path to append to the source directory
-- @return (string) The combined path
-- @usage local config_path = M.src("config.json") -- Returns path relative to current file
function M.src(path)
	local str = debug.getinfo(2, "S").source:sub(2)
	local src = str:match "(.*/)" or str:match "(.*\\)" or "./"
	return src .. path
end

---@generic T, R
---@param array T[] Array to transform
---@param func fun(T, i: integer): R Function to apply to each element
---@return R[] New array with transformed elements
--- Maps a function over each element in an array
-- @param array (table) The array to map
-- @param func (function) The function to apply to each element (receives value and index)
-- @return (table) A new array with the mapped values
-- @usage local doubled = M.map({1, 2, 3}, function(v) return v * 2 end) -- Returns {2, 4, 6}
function M.map(array, func)
	local new_arr = {}
	for i, v in ipairs(array) do
		new_arr[i] = func(v, i)
	end
	return new_arr
end

---@generic T
---@param array T[] Source array
---@param start integer Starting index (inclusive)
---@param stop? integer Ending index (inclusive, defaults to end of array)
---@return T[] New array with sliced elements
--- Creates a new array with elements from start to stop (inclusive)
-- @param array (table) The source array
-- @param start (number) The starting index (inclusive)
-- @param stop (number, optional) The ending index (inclusive, defaults to end of array)
-- @return (table) A new array containing the sliced elements
-- @usage local middle = M.slice({1, 2, 3, 4, 5}, 2, 4) -- Returns {2, 3, 4}
function M.slice(array, start, stop)
	local new_arr = {}

	stop = stop or #array

	for i = start, stop do
		table.insert(new_arr, array[i])
	end

	return new_arr
end

-- Japanese number representations
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

--- Converts a number to Japanese numerals
-- @param num (number) The number to convert
-- @return (string) The Japanese representation of the number
-- @usage local jp_num = M.number_to_japanese(123) -- Returns "一二三"
function M.number_to_japanese(num)
	local result = ""
	for digit in tostring(num):gmatch "." do
		result = result .. japanese_numbers[tonumber(digit)]
	end
	return result
end

--- Determines if a file is an image based on its extension
-- @param file (string) The file path or name to check
-- @return (boolean) true if the file has an image extension, false otherwise
-- @usage local is_img = IsImage("photo.jpg") -- Returns true
function IsImage(file)
	local extensions = { ".jpeg", ".webp", ".png", ".jpg", ".gif" }
	for _, ext in ipairs(extensions) do
		if file:sub(-#ext) == ext then
			return true
		end
	end
	return false
end

--- Creates a string representation of any Lua object
-- @param o (any) The object to dump
-- @return (string) String representation of the object
-- @usage local obj_str = M.Dump({a = 1, b = "test"}) -- Returns "{ ["a"] = 1,["b"] = "test",} "
function M.inspect(o)
	if type(o) == "table" then
		local s = "{ "
		for k, v in pairs(o) do
			if type(k) ~= "number" then
				k = '"' .. k .. '"'
			end
			s = s .. "[" .. k .. "] = " .. M.inspect(v) .. ","
		end
		return s .. "} "
	else
		return tostring(o)
	end
end

function M.pinspect(obj)
	return print(M.inspect(obj))
end

--- Returns a random element from a list
-- @param list (table) The list to select from
-- @return (any) A random element from the list
-- @usage local color = RandFrom({"red", "green", "blue"}) -- Returns one of the colors randomly
function RandFrom(list)
	math.randomseed(os.time())
	return list[math.random(1, #list)]
end

--- Returns a random boolean value (true or false)
-- @return (boolean) true or false with equal probability
-- @usage local heads = RandBool() -- Returns true or false randomly
function RandBool()
	math.randomseed(os.time())
	return math.random(0, 1) == 1
end

--- Generates a random string of lowercase letters
-- @param length (number) The length of the string to generate
-- @return (string) A random string of the specified length
-- @usage local id = RandStr(8) -- Returns something like "abcdefgh"
function RandStr(length)
	local res = ""
	for _ = 1, length do
		res = res .. string.char(math.random(97, 122))
	end
	return res
end

-- Mappings for superscript characters
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

-- Mappings for subscript characters
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

--- Helper function to apply character mapping
-- @param s (string) The string to transform
-- @param map (table) The character mapping table
-- @return (string) The transformed string
-- @private
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

--- Converts a string to superscript characters
-- @param s (string) The string to convert
-- @return (string) The string with superscript characters
-- @usage local sup = M.ToSuperscript("123") -- Returns "¹²³"
function M.ToSuperscript(s)
	return applyMapping(s, SUPERSCRIPTS)
end

--- Converts a string to subscript characters
-- @param s (string) The string to convert
-- @return (string) The string with subscript characters
-- @usage local sub = M.ToSubscript("123") -- Returns "₁₂₃"
function M.ToSubscript(s)
	return applyMapping(s, SUBSCRIPTS)
end

-- Source: https://github.com/rachartier/dotfiles/blob/main/.config/nvim/lua/utils.lua
--- Converts a value to a list
-- @param value (any) Any value that will be converted to a list
-- @return (table) The listified version of the value
-- @usage local list = M.ToList("item") -- Returns {"item"}
-- @usage local list = M.ToList({1, 2}) -- Returns {1, 2}
-- @usage local list = M.ToList(nil) -- Returns {}
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

--- Evaluates a value or function
-- If the input is a function, calls it and returns the result
-- Otherwise, returns the input value unchanged
-- @param val (any) Value or function to evaluate
-- @return (any) The evaluated result
-- @usage local result = M.Eval(function() return "test" end) -- Returns "test"
-- @usage local result = M.Eval("test") -- Returns "test"
function M.Eval(val)
	if type(val) == "function" then
		return val()
	end
	return val
end

--- Formats a length in seconds to "minutes:seconds" format
-- @param length (number) Length in seconds
-- @return (string) Formatted time string (MM:SS)
-- @usage local time = M.strlen(125) -- Returns "2:05"
function M.strlen(length)
	local min = math.floor(length / 60)
	local sec = math.floor(length % 60)

	return string.format("%d:%s%d", min, sec < 10 and "0" or "", sec)
end

--- Serializes a Lua object to a string with formatting options
-- @param obj (any) The object to serialize
-- @param options (table, optional) Serialization options:
--   - depth (number): Maximum depth to traverse (default: infinity)
--   - newline (string): Newline character(s) (default: "\n")
--   - indent (string): Indentation string (default: "  ")
--   - process_item (function): Function to process each item before serialization
-- @return (string) The serialized object
-- @usage local json_like = M.serialize({a = 1, b = {c = 2}})
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
		if type(key) == "string" and key:match "^[%a_][%a%d_]*$" then
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

--- Downloads a file from a URL and caches it locally
-- @param url (string) The URL of the file to download
-- @return (string|nil) The local filepath if successful, nil otherwise
-- @usage local filepath = M.getFile("https://example.com/image.jpg")
function M.getFile(url)
	if not url then
		return nil
	end

	local http = require "socket.http"
	local lfs = require "lfs"
	local ltn12 = require "ltn12"
	local os = require "os"

	-- Create cache directory if it doesn't exist
	local cache_dir = os.getenv "HOME" .. "/.cache/charon-shell/files/"
	local success = os.execute("mkdir -p " .. cache_dir)
	if not success then
		return nil
	end

	-- Generate MD5 hash of the URL using command line md5sum
	local md5_command = "echo -n '" .. url .. "' | md5sum | awk '{print $1}'"
	local md5_pipe = io.popen(md5_command)
	if not md5_pipe then
		return nil
	end

	local url_hash = md5_pipe:read "*l"
	md5_pipe:close()

	local extension = url:match "%.([^%.]+)$" or ""
	if extension ~= "" then
		extension = "." .. extension
	end

	local filename = url_hash .. extension
	local filepath = cache_dir .. filename

	if lfs.attributes(filepath) then
		return filepath
	end

	local response_body = {}

	local res, code, headers = http.request {
		url = url,
		sink = ltn12.sink.table(response_body),
		redirect = true,
	}

	if code ~= 200 then
		return nil
	end

	local file = io.open(filepath, "wb")
	if not file then
		return nil
	end

	file:write(table.concat(response_body))
	file:close()

	return filepath
end

--- Merges multiple tables into a new table
-- @param ... (tables) Any number of tables to be merged
-- @return (table) A new table containing all key-value pairs from the input tables
-- @usage local combined = M.merge({a = 1}, {b = 2}) -- Returns {a = 1, b = 2}
function M.merge(...)
	local result = {}
	for _, t in ipairs { ... } do
		if type(t) == "table" then
			for k, v in pairs(t) do
				result[k] = v
			end
		end
	end
	return result
end

--- Creates a function that executes a shell command when called
-- @param cmd (string) The shell command to execute
-- @return (function) A function that will execute the command when called
-- @usage local ls = M.fn_exe("ls -la") -- Returns a function that will execute "ls -la" when called
function M.fn_exe(cmd)
	return function()
		os.execute(cmd)
	end
end

--- Splits a string into a table of substrings based on a separator
-- @param inputstr (string) The string to split
-- @param sep (string, optional) The separator pattern (default: whitespace)
-- @return (table) Table of substrings
-- @usage local parts = M.split("hello,world", ",") -- Returns {"hello", "world"}
function M.split(inputstr, sep)
	if sep == nil or sep == "" then
		local t = {}
		for i = 1, #inputstr do
			t[i] = inputstr:sub(i, i)
		end
		return t
	end
	local t = {}
	for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
		table.insert(t, str)
	end
	return t
end

--- Creates a sequence of numbers within a specified range
-- @param start (number) The start of the range, or stop if only one argument is provided
-- @param stop (number, optional) The end of the range (exclusive)
-- @param step (number, optional) The step size (default: 1)
-- @return (table) A table containing the sequence of numbers
-- @usage local seq = M.range(1, 5) -- Returns {1, 2, 3, 4}
-- @usage local seq = M.range(5) -- Returns {1, 2, 3, 4}
-- @usage local seq = M.range(1, 10, 2) -- Returns {1, 3, 5, 7, 9}
function M.range(start, stop, step)
	local result = {}
	step = step or 1
	if not stop then
		stop = start
		start = 1
	end
	if step > 0 then
		for i = start, stop - 1, step do
			table.insert(result, i)
		end
	else
		for i = start, stop + 1, step do
			table.insert(result, i)
		end
	end
	return result
end

function M.notify(msg)
	os.execute("notify-send '" .. msg:gsub("'", "'\\''") .. "'")
end

return M
