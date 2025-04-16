#!/usr/bin/env lua
local argparse = require("argparse")

local astal = require("astal")
local App = require("astal.gtk3.app")

local windows = require("lua.windows")
local utils = require("lua.utils")
local logger = require("lua.logger")

local parser = argparse("main", "Charon Shell entrypoint")
parser:option("-l --log-file", "Path to log file", "/tmp/charon-shell-log")
parser:option("--log-level", "Logging level", "DEBUG")
parser:flag("--no-log-color", "Disable colored log output")
parser:option("--scss", "Path to SCSS file", "style/style.scss")
parser:option("-c --command", "Send command to shell"):args("*")

local args = parser:parse()

local port = args.port
local log_file = args["log_file"]
local log_level = args["log_level"]
local log_color = not args["no_log_color"]
local scss_file = args.scss

local ipc = require("lua.extras.ipc")

if args.command and #args.command > 0 then
	local cmd = table.concat(args.command, " ")
	ipc.send(cmd)
	return
end

ipc.start()

logger.configure({
	level = log_level,
	colored = log_color,
	outputs = { "console", "file" },
	file_path = log_file,
})

local scss = utils.src(scss_file)
local css = "/tmp/style.css"
os.execute("sass -q --no-source-map " .. scss .. " " .. css)

logger.global.debug("App starting")

App:start({
	instance_name = "main",
	css = css,
	request_handler = function(msg, res)
		utils.info(msg)
		res("ok")
	end,
	main = function()
		for _, mon in pairs(App.monitors) do
			windows.Bar(mon)
		end
	end,
})

logger.global.debug("App ended")
