local M = {}

-- Get the current process ID
function M.getPid()
	-- Try to read from /proc/self/stat
	local f = io.open("/proc/self/stat", "r")
	if f then
		local content = f:read "*a"
		f:close()
		local pid = content:match "^(%d+)"
		return tonumber(pid)
	end

	-- Fallback method using external command
	local handle = io.popen "echo $PPID"
	local result = handle:read("*a"):gsub("%s+$", "")
	handle:close()
	return tonumber(result)
end

-- Get the current process command line
function M.getCommand()
	-- Read from /proc/self/cmdline (most accurate)
	local f = io.open("/proc/self/cmdline", "r")
	if f then
		local cmdline = f:read "*a"
		f:close()

		-- cmdline contains arguments separated by null bytes
		-- Convert null bytes to spaces for a shell-compatible command
		local args = {}
		for arg in cmdline:gmatch "[^%z]+" do
			-- Quote arguments that contain spaces or special chars
			if arg:match "[ \"'\\%$%&%*%(%)%[%]%{%}%;%|%<%>%?%!%`]" then
				arg = "'" .. arg:gsub("'", "'\\''") .. "'"
			end
			table.insert(args, arg)
		end
		return table.concat(args, " ")
	end

	-- Fallback to ps command
	local pid = M.getPid()
	if pid then
		local handle = io.popen("ps -p " .. pid .. " -o args=")
		local result = handle:read("*a"):gsub("^%s*(.-)%s*$", "%1") -- Trim whitespace
		handle:close()
		return result
	end

	return nil
end

-- Restart the current process
function M.restart(delay)
	delay = type(delay) == "number" and tonumber(delay) or 3

	local cmd = M.getCommand()
	local pid = M.getPid()

	if cmd == nil or pid == nil then
		return nil
	end

	os.execute([[
    bash -c "sleep ]] .. delay .. [[ ; kill -9 ]] .. pid .. [[" ; ]] .. cmd .. [[ &
        ]])
end

function M.kill(delay)
	delay = type(delay) == "number" and tonumber(delay) or 3
	local pid = M.getPid()
	if pid == nil then
		return nil
	end
	os.execute([[ bash -c "sleep ]] .. delay .. [[ ; kill -9 ]] .. pid .. [[" &]])
end

return M
