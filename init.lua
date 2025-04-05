local logger = require("lua.logger")

logger.configure({
	level = "DEBUG",
	colored = true,
	outputs = { "console", "file" },
	file_path = "/tmp/charon-shell-log",
})

local astal = require("astal")
local App = require("astal.gtk3.app")

local windows = require("lua.windows")
local utils = require("lua.utils")

local scss = utils.src("style/style.scss")
local css = "/tmp/style.css"
astal.exec("sass " .. scss .. " " .. css)

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
