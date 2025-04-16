local log = require("lua.logger").getLogger "ipc"
local utils = require "lua.utils"
local ps = require "lua.utils.ps"
local astal = require "astal"
local tmp_file_default = "/tmp/charon-shell-ipc"

local function handle(cmd)
	local main, sub, sub_2 = utils.split(cmd, " ")

	if main == "restart" then
		ps.restart(3)
	elseif main == "kill" then
		ps.kill(0)
	elseif main == "toggle" then
		if sub == "center" then
			require "lua.windows.center"()
		elseif sub == "console" then
			require "lua.windows.console"()
		elseif sub == "player" then
			require "lua.windows.player"()
		else
			log.error("Unknown toggle cmd " .. sub .. " " .. sub_2)
		end
	else
		log.error("Unknown  cmd " .. main " " .. sub .. " " .. sub_2)
	end
end

return {
	start = function(tmp_file)
		tmp_file = tmp_file or tmp_file_default

		astal.write_file(tmp_file, "")

		astal.monitor_file(tmp_file, function()
			handle(astal.read_file(tmp_file))
			log.info "Read IPC File"
		end)

		log.info "IPC init"
	end,

	send = function(cmd, tmp_file)
		tmp_file = tmp_file or tmp_file_default

		astal.write_file(tmp_file, cmd)

		log.info "Write IPC File"
	end,
}
