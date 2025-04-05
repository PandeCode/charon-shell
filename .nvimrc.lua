local Job = require("plenary.job")
local augroup = vim.api.nvim_create_augroup("LuaAutoCmdGroup", { clear = true })

vim.api.nvim_create_autocmd("BufWritePost", {
	group = augroup,
	pattern = { "*.lua", "*.scss", "*.fnl", "*.ts", "*.tsx" },
	callback = function()
		Job:new({
			command = "bash",
			args = { "-c", "killall -9 lua ; lua init.lua >> /tmp/astal-stdout 2>> /tmp/astal-stderr & disown" },
			on_exit = function(j, return_val)
				if return_val == 0 then
					vim.notify("executed successfully.")
				else
					vim.notify("Error executing Lua script:", j:result())
				end
			end,
		}):start()
	end,
})

vim.keymap.set("n", "<leader>cc", function()
	vim.cmd([[
    !printf '\033[2J' > /tmp/astal-stdout > /tmp/astal-stderr > /tmp/charon-shell-log
    ]])
end)
