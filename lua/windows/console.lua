local astal = require "astal"
local Widget = require "astal.gtk3.widget"
local Gdk = require("astal.gtk3").Gdk
local Anchor = astal.require("Astal").WindowAnchor
local bind = astal.bind
local utils = require "lua.utils"
local logger = require "lua.logger"

local e = require "lua.extras.elements"
local divv = e.divv
local div = e.div
local btn = e.btn

-- Environment for console execution
local consoleEnv = {
	astal = astal,
	Gdk = Gdk,

	logger = logger,
	utils = utils,

	-- Include standard libraries
	math = math,
	string = string,
	table = table,
	io = io,
	os = os,

	-- Include globals
	require = require,
	pairs = pairs,
	ipairs = ipairs,
	tostring = tostring,
	tonumber = tonumber,
	type = type,

	-- Storage for user-defined variables and functions
	_G = _G,

	-- Utility functions
	inspect = utils.pinspect,

	help = function()
		return [[
Console Help:
- Define variables: x = 10
- Define functions: function add(a,b) return a+b end
- Access globals: _G.myVar or simply myVar
- Use require: json = require("json")
- Inspect objects: inspect(myTable)
- Up/Down arrows: Navigate command history
- Escape: Close console
]]
	end,
}

-- Make consoleEnv use _G as its metatable to access globals
setmetatable(consoleEnv, { __index = _G })

local function ConsoleWindow()
	local history = astal.Variable {} -- Command history
	local historyIndex = astal.Variable(0)
	local displayLines = astal.Variable {}
	local code = astal.Variable ""

	consoleEnv.print = function(...)
		local args = { ... }
		local line = ""

		-- Concatenate all arguments with spaces
		for i, arg in ipairs(args) do
			if i > 1 then
				line = line .. " "
			end
			line = line .. tostring(arg)
		end

		-- Add to display lines
		local lines = displayLines:get()
		table.insert(lines, "print: " .. line)
		displayLines:set(lines)

		-- Also log using logger
		logger.info("Console print: " .. line)

		-- Call original print if needed
		return _G.print(...)
	end

	-- Function to execute code in the console environment
	local function executeCode(codeStr)
		logger.debug "staring execute"

		-- First try as an expression (with return)
		local fn, loadErr = load("return " .. codeStr, "console", "t", consoleEnv)

		-- If that fails, try as a statement
		if not fn then
			logger.debug "first try fail"
			fn, loadErr = load(codeStr, "console", "t", consoleEnv)
		end

		-- Execute and capture result
		if fn then
			local success, result = pcall(fn)
			if success then
				logger.debug "Pcall'ed function"
				-- Add command to history
				local historyItems = history:get()
				table.insert(historyItems, codeStr)
				history:set(historyItems)
				historyIndex:set(#historyItems + 1)

				logger.debug "Handled History"
				-- Display result
				local lines = displayLines:get()
				table.insert(lines, "> " .. codeStr)

				if result ~= nil then
					table.insert(lines, "=> " .. utils.inspect(result))
				end

				displayLines:set(lines)
				return result
			else
				logger.debug "Failed to pcall fn"
				-- Display error
				local lines = displayLines:get()
				table.insert(lines, "> " .. codeStr)
				table.insert(lines, "Error: " .. tostring(result))
				displayLines:set(lines)
				logger.error("Console error: " .. tostring(result))
			end
		else
			-- Display load error
			local lines = displayLines:get()
			table.insert(lines, "> " .. codeStr)
			table.insert(lines, "Syntax error: " .. tostring(loadErr))
			displayLines:set(lines)
			logger.error("Console syntax error: " .. tostring(loadErr))
		end
	end

	local scrollable = Widget.Scrollable {
		css = "min-height: 300px;  padding: 10px; border-radius: 5px;",
		Widget.Box {
			vertical = true,
			hexpand = true,
			vexpand = true,

			displayLines(function(v)
				local widgets = {}
				for i, line in ipairs(v) do
					local color = "#ddd"
					local prefix = ""

					if string.sub(line, 1, 1) == ">" then
						color = "#88f" -- Command color
					elseif string.sub(line, 1, 2) == "=>" then
						color = "#8f8" -- Result color
					elseif string.sub(line, 1, 5) == "Error" then
						color = "#f88" -- Error color
					end

					table.insert(
						widgets,
						Widget.Label {
							label = line,
							hexpand = true,
							css = "color: "
								.. color
								.. "; font-family: monospace; padding: 5px;"
								.. (i % 2 == 0 and "background: black" or ""),
							halign = "START",
							wrap = true,
						}
					)
				end

				return Widget.Box {
					vertical = true,
					table.unpack(widgets),
				}
			end),
			code(function() end), -- WARN: Do not remove things break if removed
		},
	}

	return Widget.Window {
		title = "Lua Console",
		anchor = Anchor.TOP + Anchor.LEFT,
		css = "min-width: 500px; min-height: 400px;",
		class_name = "rounded-lg",
		keymode = "ON_DEMAND",
		on_show = function()
			code:set ""
		end,
		on_key_press_event = function(self, event)
			if event.keyval == Gdk.KEY_Escape then
				self:hide()
				return true
			elseif event.keyval == Gdk.KEY_Up then
				-- Navigate history up
				local idx = historyIndex:get()
				local historyItems = history:get()
				if idx > 1 then
					idx = idx - 1
					historyIndex:set(idx)
					code:set(historyItems[idx])
				end
				return true
			elseif event.keyval == Gdk.KEY_Down then
				-- Navigate history down
				local idx = historyIndex:get()
				local historyItems = history:get()
				if idx < #historyItems then
					idx = idx + 1
					historyIndex:set(idx)
					code:set(historyItems[idx])
				elseif idx == #historyItems then
					idx = idx + 1
					historyIndex:set(idx)
					code:set ""
				end
				return true
			end
			return false
		end,
		divv({
			Widget.Label {
				label = "Lua Console",
				css = "font-weight: bold;  font-size: 16px; margin-bottom: 10px;",
			},
			scrollable,
			Widget.Box {
				css = "margin-top: 10px;",
				Widget.Entry {
					hexpand = true,
					placeholder_text = "Enter Lua code...",
					text = bind(code):as(function(text)
						return tostring(text)
					end),
					on_changed = function(self)
						code:set(self.text)
					end,
					css = "font-family: monospace; background: #222; color: #ddd; padding: 8px;",
					on_activate = function(self)
						local codeText = code:get()
						if codeText and codeText ~= "" then
							executeCode(codeText)
							code:set ""

							local adj = scrollable:get_vadjustment()
							adj.value = adj.upper - adj.page_size
						end
					end,
				},
				Widget.Button {
					label = "Run",
					css = "margin-left: 5px;",
					on_clicked = function()
						local codeText = code:get()
						if codeText and codeText ~= "" then
							executeCode(codeText)
							code:set ""
						end
					end,
				},
				Widget.Button {
					label = "Clear",
					css = "margin-left: 5px;",
					on_clicked = function()
						displayLines:set {}
					end,
				},
			},
		}, "bg-base00-90 rounded-lg m-2 p-2 border-solid border-base03-50 border-2", { css = "min-width: 480px;" }),
	}
end

local utils_a = require "lua.utils.astal"
return utils_a.mkPopupToggle(ConsoleWindow)
