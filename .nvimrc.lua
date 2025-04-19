vim.cmd [[
nnoremap <leader>de :!touch /tmp/debug<cr>
nnoremap <leader>cc :!touch /tmp/clear-log<cr>
nnoremap <leader>rs :!bash -c "touch _.lua; rm _.lua"<cr>
nnoremap <leader>wb :normal ys%(<cr>
nnoremap <leader>rb :normal ds(<cr>
]]

vim.keymap.set("n", "<leader>tl", function()
	local current_file = vim.fn.expand "%:p"
	if current_file:sub(-3) == "tsx" then
		vim.cmd("edit " .. current_file:sub(1, #current_file - 3) .. "lua")
		return
	elseif current_file:sub(-2) == "ts" then
		vim.cmd("edit " .. current_file:sub(1, #current_file - 2) .. "lua")
		return
	end

	local ts_pattern = "shell/ts/(.*)%.lua$"
	local lua_pattern = "shell/lua/(.*)%.lua$"
	local fennel_pattern = "shell/fennel/(.*)%.fnl$"

	if string.match(current_file, lua_pattern) then
		local fennel_file = current_file:gsub("shell/lua/(.*)%.lua$", "shell/fennel/%1.fnl")
		vim.cmd("edit " .. fennel_file)
	elseif string.match(current_file, fennel_pattern) then
		local lua_file = current_file:gsub("shell/fennel/(.*)%.fnl$", "shell/lua/%1.lua")
		vim.cmd("edit " .. lua_file)
	elseif string.match(current_file, ts_pattern) then
		local ts_file = current_file:gsub("shell/ts/(.*)%.lua$", "shell/ts/%1.tsx")
		vim.cmd("edit " .. ts_file)
		if vim.fn.filereadable(ts_file) then
			vim.cmd("edit " .. ts_file)
			return
		end
		ts_file = current_file:gsub("shell/ts/(.*)%.lua$", "shell/ts/%1.ts")
		if vim.fn.filereadable(ts_file) then
			vim.cmd("edit " .. ts_file)
			return
		end

		print "No ts or tsx file"
	else
		print "Current file is not in a recognized path"
	end
end)

local ls = require "luasnip"
local fmt = require("luasnip.extras.fmt").fmt
local s = ls.snippet
local i = ls.insert_node
local t = ls.text_node
local f = ls.function_node
local d = ls.dynamic_node
local sn = ls.snippet_node
local c = ls.choice_node

-- Color definitions (Base16 Tokyo Night theme)
local default_colors = {
	base00 = { hex = "#1a1b26", desc = "Dark background" },
	base01 = { hex = "#16161e", desc = "Darker background" },
	base02 = { hex = "#2f3549", desc = "Selection background" },
	base03 = { hex = "#444b6a", desc = "Comments, invisibles" },
	base04 = { hex = "#787c99", desc = "Dark foreground" },
	base05 = { hex = "#a9b1d6", desc = "Default foreground" },
	base06 = { hex = "#cbccd1", desc = "Light foreground" },
	base07 = { hex = "#d5d6db", desc = "Light background" },
	base08 = { hex = "#c0caf5", desc = "Variables" },
	base09 = { hex = "#a9b1d6", desc = "Integers, booleans" },
	base0A = { hex = "#0db9d7", desc = "Classes, HTML tags" },
	base0B = { hex = "#9ece6a", desc = "Strings" },
	base0C = { hex = "#b4f9f8", desc = "Support, regex" },
	base0D = { hex = "#2ac3de", desc = "Functions, methods" },
	base0E = { hex = "#bb9af7", desc = "Keywords" },
	base0F = { hex = "#f7768e", desc = "Deprecated" },
}

-- Function to get colors from MiniBase16 or fallback to defaults
local function get_colors()
	if pcall(require, "mini.base16") and MiniBase16 and MiniBase16.config and MiniBase16.config.palette then
		local palette = MiniBase16.config.palette
		local mini_colors = {}

		-- Convert MiniBase16 palette to our format
		for i = 0, 15 do
			local base_key = string.format("base%02X", i)
			if palette[base_key] then
				mini_colors[base_key] = {
					hex = palette[base_key],
					desc = default_colors[base_key].desc, -- Keep the descriptions from defaults
				}
			end
		end

		-- Return MiniBase16 colors if we have at least one valid entry
		if next(mini_colors) then
			return mini_colors
		end
	end

	-- Fallback to default colors
	return default_colors
end

-- Get current color palette
local colors = get_colors()

-- Function to create color box for documentation
local function create_color_box(hex)
	-- Create a small colored box using Unicode characters
	return string.format(" %s ", hex)
end

-- Function to generate documentation for a base color
local function generate_color_doc(base_num)
	local key = string.format("base%02X", base_num)
	local color = colors[key]
	if color then
		return string.format("%s%s - %s", create_color_box(color.hex), color.hex, color.desc)
	end
	return ""
end

-- Function to create color snippet
local function create_color_snippet(prefix, filetypes)
	local snippets = {}

	-- Create snippet for each base color
	for i = 0, 15 do
		local base_num = string.format("%02X", i)
		local key = string.format("base%s", base_num)
		local color = colors[key]

		if color then
			-- Generate trigger and snippet text
			local trigger = string.format("%s%s", prefix, base_num)
			local snippet_text = string.format("%s-%s", prefix, key)

			-- Generate documentation
			local doc = string.format("%s%s - %s", create_color_box(color.hex), color.hex, color.desc)

			-- Create the snippet
			local snip = s(trigger, t(snippet_text), {
				desc = doc,
				dscr = doc, -- Some LuaSnip versions use dscr instead of desc
				docstring = doc, -- For compatibility with different documentation display methods
			})

			table.insert(snippets, snip)
		end
	end

	return snippets
end

-- Function to create choice node for all color options
local function color_choice_node(prefix)
	local choices = {}

	for i = 0, 15 do
		local base_num = string.format("%02X", i)
		local key = string.format("base%s", base_num)
		local snippet_text = string.format("%s%s", prefix, key)
		table.insert(choices, t(snippet_text))
	end

	return c(1, choices)
end

-- Create general color snippets with choice nodes
local function create_dynamic_snippets(filetypes)
	local snippets = {}

	-- Background color snippet with choices
	table.insert(
		snippets,
		s({
			trig = "bg",
			dscr = "Background color utility class",
			desc = "Background color with base16 palette",
		}, {
			color_choice_node "bg-",
		})
	)

	-- Text color snippet with choices
	table.insert(
		snippets,
		s({
			trig = "text",
			dscr = "Text color utility class",
			desc = "Text color with base16 palette",
		}, {
			color_choice_node "text-",
		})
	)

	-- Border color snippet with choices
	table.insert(
		snippets,
		s({
			trig = "border",
			dscr = "Border color utility class",
			desc = "Border color with base16 palette",
		}, {
			color_choice_node "border-",
		})
	)

	return snippets
end

-- Create snippets for each file type
local tsx_snippets = {}
local lua_snippets = {}
local fennel_snippets = {}

-- Add background color snippets
vim.list_extend(tsx_snippets, create_color_snippet("bg", { "tsx", "jsx", "javascript", "typescript" }))
vim.list_extend(lua_snippets, create_color_snippet("bg", { "lua" }))
vim.list_extend(fennel_snippets, create_color_snippet("bg", { "fennel" }))

-- Add text color snippets
vim.list_extend(tsx_snippets, create_color_snippet("text", { "tsx", "jsx", "javascript", "typescript" }))
vim.list_extend(lua_snippets, create_color_snippet("text", { "lua" }))
vim.list_extend(fennel_snippets, create_color_snippet("text", { "fennel" }))

-- Add border color snippets
vim.list_extend(tsx_snippets, create_color_snippet("border", { "tsx", "jsx", "javascript", "typescript" }))
vim.list_extend(lua_snippets, create_color_snippet("border", { "lua" }))
vim.list_extend(fennel_snippets, create_color_snippet("border", { "fennel" }))

-- Add dynamic snippets (with choice nodes)
vim.list_extend(tsx_snippets, create_dynamic_snippets { "tsx", "jsx", "javascript", "typescript" })
vim.list_extend(lua_snippets, create_dynamic_snippets { "lua" })
vim.list_extend(fennel_snippets, create_dynamic_snippets { "fennel" })

-- Register snippets with LuaSnip
ls.add_snippets("typescript", tsx_snippets)
ls.add_snippets("typescriptreact", tsx_snippets)
ls.add_snippets("javascript", tsx_snippets)
ls.add_snippets("javascriptreact", tsx_snippets)
ls.add_snippets("lua", lua_snippets)
ls.add_snippets("fennel", fennel_snippets)

-- Optional: Create visual help command to display all colors
vim.api.nvim_create_user_command("ShowBase16Colors", function()
	local colors = get_colors()
	local lines = { "Base16 Color Palette:" }

	for i = 0, 15 do
		local key = string.format("base%02X", i)
		local color = colors[key]
		if color then
			table.insert(lines, string.format("%s: %s - %s", key, color.hex, color.desc))
		end
	end

	-- Create a new buffer to display colors
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
	vim.api.nvim_buf_set_option(buf, "modifiable", false)
	vim.api.nvim_buf_set_option(buf, "filetype", "base16colors")

	-- Open in a split window
	vim.cmd "split"
	vim.api.nvim_win_set_buf(0, buf)
end, {})

-- Return a module with useful functions
return {
	get_colors = get_colors,
	create_color_snippet = create_color_snippet,
	create_dynamic_snippets = create_dynamic_snippets,
	colors = colors,
}
