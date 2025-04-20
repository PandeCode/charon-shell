local log = require("lua.logger").getLogger "ipc"
local utils = require "lua.utils"
local ps = require "lua.utils.ps"
local astal = require "astal"
local tmp_file_default = "/tmp/charon-shell-ipc"

local function handle(cmd)
	local main, sub, sub_2 = table.unpack(utils.split(cmd, " "))

	if main == "restart" then
		ps.restart(3)
	elseif main == "kill" then
		ps.kill(0)
	elseif main == "toggle" then
		local toggle_map = {
			center   = "ts.windows.center",
			playlist = "ts.windows.playlist",
			start    = "ts.windows.start",
			network  = "ts.windows.network",
			niriview = "ts.windows.niriview",
			player   = "lua.windows.player",
		}

		local mod = toggle_map[sub]
		if mod then
			local r = require(mod)
            if r.default == nil then
                r()
            else
                r.default()
            end
		else
			log.error("Unknown toggle cmd " .. (sub or "") .. " " .. (sub_2 or ""))
		end
	else
		log.error("Unknown cmd " .. utils.inspect(main) .. " " .. (sub or "") .. " " .. (sub_2 or ""))
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
