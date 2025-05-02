local json = require "dkjson" -- dkjson for JSON parsing
local config_path = os.getenv "HOME" .. "/.config/charon-shell/config.json"
local audio_path = os.getenv "HOME" .. "/dev/lua/Media/"

local logger = require "lua.logger"
logger.global.debug "Loading assets"

local loadconfig = function()
	local file = io.open(config_path, "r")
	if not file then
		print("Error: Configuration file missing: " .. config_path)
		return nil
	end

	local content = file:read "*a"
	file:close()

	local config, _, err = json.decode(content, 1, nil)
	if err then
		print("Error parsing config file: " .. err)
		return nil
	end

	return config
end

return {
	default_image_path = os.getenv "HOME" .. "/dev/lua/charon-shell/media/nix.svg",

	config_path = config_path,

	audio = {
		alarm_01 = audio_path .. "Alarm01.wav",
		alarm_02 = audio_path .. "Alarm02.wav",
		alarm_03 = audio_path .. "Alarm03.wav",
		chimes = audio_path .. "chimes.wav",
		chord = audio_path .. "chord.wav",
		ding = audio_path .. "ding.wav",
		notify = audio_path .. "notify.wav",
		recycle = audio_path .. "recycle.wav",
		ringout = audio_path .. "ringout.wav",
		tada = audio_path .. "tada.wav",
		windows_logon = audio_path .. "Windows Logon.wav",
		windows_notify = audio_path .. "Windows Notify.wav",
		windows_ding = audio_path .. "Windows Ding.wav",
		windows_error = audio_path .. "Windows Error.wav",
		windows_exclamation = audio_path .. "Windows Exclamation.wav",
		windows_shutdown = audio_path .. "Windows Shutdown.wav",
		windows_startup = audio_path .. "Windows Startup.wav",
	},

	icons = {
		youtube = os.getenv "HOME" .. "/dev/lua/charon-shell/media/youtube.svg",
		disconnect = os.getenv "HOME" .. "/dev/lua/charon-shell/media/disconnect.svg",
		connect = os.getenv "HOME" .. "/dev/lua/charon-shell/media/connect.svg",
	},

	colors = (function()
		local s, colors = pcall(require, os.getenv "HOME" .. "/.config/stylix/nvim.lua")
		if s then
			return colors
		end
		return {
			base00 = "#1a1b26",
			base01 = "#16161e",
			base02 = "#2f3549",
			base03 = "#444b6a",
			base04 = "#787c99",
			base05 = "#a9b1d6",
			base06 = "#cbccd1",
			base07 = "#d5d6db",
			base08 = "#c0caf5",
			base09 = "#a9b1d6",
			base0A = "#0db9d7",
			base0B = "#9ece6a",
			base0C = "#b4f9f8",
			base0D = "#2ac3de",
			base0E = "#bb9af7",
			base0F = "#f7768e",
		}
	end)(),

	loadconfig = loadconfig,
	-- Function to load and decode the config file
	config = loadconfig(),
}
