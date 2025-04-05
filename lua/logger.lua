-- logger.lua - A flexible logging library for Lua projects
-- Usage: local logger = require("logger")

local logger = {}

-- Log levels with numeric values for comparison
logger.LEVELS = {
	DEBUG = 10,
	INFO = 20,
	WARNING = 30,
	ERROR = 40,
	CRITICAL = 50,
}

-- Default configuration
local config = {
	level = logger.LEVELS.INFO, -- Default log level threshold
	format = "[%level%] %time% - %message%", -- Default format
	timestamp_format = "%Y-%m-%d %H:%M:%S",
	colored = true, -- Use ANSI colors in console output
	outputs = { "console" }, -- Default outputs: console, file(s)
	file_path = "application.log",
	max_file_size = 1024 * 1024, -- 1MB
	backup_count = 5, -- Number of backup files to keep
}

-- Colors for different log levels (ANSI escape codes)
local colors = {
	DEBUG = "\27[36m", -- Cyan
	INFO = "\27[32m", -- Green
	WARNING = "\27[33m", -- Yellow
	ERROR = "\27[31m", -- Red
	CRITICAL = "\27[35m", -- Magenta
	RESET = "\27[0m",
}

-- Get level name from value
local function getLevelName(level_value)
	for name, value in pairs(logger.LEVELS) do
		if value == level_value then
			return name
		end
	end
	return "UNKNOWN"
end

-- Format a log message according to the format string
local function formatLogMessage(level, message, format_str)
	local level_name = getLevelName(level)
	local time_str = os.date(config.timestamp_format)

	return (format_str or config.format)
		:gsub("%%level%%", level_name)
		:gsub("%%time%%", time_str)
		:gsub("%%message%%", message)
end

-- Output handlers
local output_handlers = {
	-- Console output
	console = function(level, formatted_message)
		local message = formatted_message
		if config.colored then
			local level_name = getLevelName(level)
			message = colors[level_name] .. formatted_message .. colors.RESET
		end
		print(message)
	end,

	-- File output
	file = function(_, formatted_message)
		local file = io.open(config.file_path, "a")
		if file then
			file:write(formatted_message .. "\n")
			file:close()

			-- Check file size and rotate if necessary
			local info = io.open(config.file_path, "r")
			if info then
				local size = info:seek("end")
				info:close()

				if size > config.max_file_size then
					rotateLogFiles()
				end
			end
		end
	end,
}

-- Rotate log files
function rotateLogFiles()
	-- Remove oldest backup if it exists
	os.remove(config.file_path .. "." .. config.backup_count)

	-- Shift existing backups
	for i = config.backup_count - 1, 1, -1 do
		local old_name = config.file_path .. "." .. i
		local new_name = config.file_path .. "." .. (i + 1)
		os.rename(old_name, new_name)
	end

	-- Rename current log file to .1
	os.rename(config.file_path, config.file_path .. ".1")
end

-- Log a message with the specified level
local function log(level, message, ...)
	-- Check if we should log at this level
	if level < config.level then
		return
	end

	-- Format arguments if provided
	if select("#", ...) > 0 then
		message = string.format(message, ...)
	end

	-- Format the message according to the configuration
	local formatted_message = formatLogMessage(level, message)

	-- Send to all configured outputs
	for _, output_name in ipairs(config.outputs) do
		if output_handlers[output_name] then
			output_handlers[output_name](level, formatted_message)
		end
	end
end

-- Configure the logger
function logger.configure(options)
	for k, v in pairs(options or {}) do
		if k == "level" and type(v) == "string" then
			-- Convert string level to numeric
			config.level = logger.LEVELS[v:upper()] or config.level
		else
			config[k] = v
		end
	end
	return logger -- For chaining
end

-- Add a custom output handler
function logger.addOutputHandler(name, handler)
	if type(handler) == "function" then
		output_handlers[name] = handler
	end
	return logger -- For chaining
end

-- Add a specific output to the active outputs
function logger.addOutput(output_name)
	if not table.concat(config.outputs, ","):find(output_name) then
		table.insert(config.outputs, output_name)
	end
	return logger -- For chaining
end

-- Remove a specific output from the active outputs
function logger.removeOutput(output_name)
	for i, name in ipairs(config.outputs) do
		if name == output_name then
			table.remove(config.outputs, i)
			break
		end
	end
	return logger -- For chaining
end

-- Create a logger with a fixed category/module name
function logger.getLogger(module_name)
	local instance = {}

	-- Create methods for each log level
	for level_name, level_value in pairs(logger.LEVELS) do
		instance[level_name:lower()] = function(message, ...)
			local msg = module_name and ("[" .. module_name .. "] " .. message) or message
			return log(level_value, msg, ...)
		end
	end

	-- Convenience function to log at any level
	instance.log = function(level, message, ...)
		local level_value = logger.LEVELS[level:upper()] or logger.LEVELS.INFO
		return instance[getLevelName(level_value):lower()](message, ...)
	end

	return instance
end

-- Create methods for each log level in the main logger
for level_name, level_value in pairs(logger.LEVELS) do
	logger[level_name:lower()] = function(message, ...)
		return log(level_value, message, ...)
	end
end

-- Set up a global logger instance that can be required once and used everywhere
local _G_LOGGER = logger.getLogger("GLOBAL")
logger.global = _G_LOGGER

return logger
