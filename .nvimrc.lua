-- local Job = require("plenary.job")
-- local augroup = vim.api.nvim_create_augroup("LuaAutoCmdGroup", { clear = true })

-- vim.api.nvim_create_autocmd("BufWritePost", {
-- 	group = augroup,
-- 	pattern = { "*.lua", "*.scss", "*.fnl", "*.ts", "*.tsx" },
-- 	callback = function()
-- 		Job:new({
-- 			command = "bash",
-- 			args = { "-c", "killall -9 lua ; lua init.lua >> /tmp/astal-stdout 2>> /tmp/astal-stderr & disown" },
-- 			on_exit = function(j, return_val)
-- 				if return_val == 0 then
-- 					vim.notify("executed successfully.")
-- 				else
-- 					vim.notify("Error executing Lua script:", j:result())
-- 				end
-- 			end,
-- 		}):start()
-- 	end,
-- })
vim.cmd [[
nnoremap <leader>de :!touch /tmp/debug<cr>
nnoremap <leader>cc :!touch /tmp/clear-log<cr>
nnoremap <leader>wb :normal ys%(<cr>
nnoremap <leader>rb :normal ds(<cr>
]]

vim.keymap.set("n", "<leader>tl", function()
	local current_file = vim.fn.expand "%:p"
	local lua_pattern = "shell/lua/(.*)%.lua$"
	local fennel_pattern = "shell/fennel/(.*)%.fnl$"

	if string.match(current_file, lua_pattern) then
		local fennel_file = current_file:gsub("shell/lua/(.*)%.lua$", "shell/fennel/%1.fnl")
		vim.cmd("edit " .. fennel_file)
	elseif string.match(current_file, fennel_pattern) then
		local lua_file = current_file:gsub("shell/fennel/(.*)%.fnl$", "shell/lua/%1.lua")
		vim.cmd("edit " .. lua_file)
	else
		print "Current file is not in a recognized path"
	end
end)

local ls = require "luasnip"
local fmt = require("luasnip.extras.fmt").fmt

local s = ls.snippet

ls.add_snippets(
	{ "lua", "fennel" },
	s(
		"ele",
		fmt(
			[[
local el = require "lua.extras.elements"
local img = el.img
local p = el.p
local div = el.div
local divv = el.divv
local img = el.img
]],
			{}
		)
	)
)
