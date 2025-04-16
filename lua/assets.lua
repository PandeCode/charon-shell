local json = require "dkjson" -- dkjson for JSON parsing
local config_path = os.getenv "HOME" .. "/.config/charon-shell/config.json"

return {
	default_image_path = "/home/shawn/dev/lua/charon-shell/media/nixos.png",

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

	-- Function to load and decode the config file
	config = (function()
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
	end)(),
}
