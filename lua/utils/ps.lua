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

local lfs = require "lfs" -- LuaFileSystem, if you have it
function M.getResourceUse()
	local result = {}

	-- Read memory and threads
	local f = io.open("/proc/self/status", "r")
	if f then
		for line in f:lines() do
			local key, value = line:match "^(%S+):%s+(%d+)"
			if key == "VmRSS" then
				result.memory_rss_kb = tonumber(value)
			elseif key == "VmSize" then
				result.memory_vmsize_kb = tonumber(value)
			elseif key == "Threads" then
				result.threads = tonumber(value)
			end
		end
		f:close()
	end

	-- Read CPU times
	local f2 = io.open("/proc/self/stat", "r")
	if f2 then
		local stat = f2:read "*a"
		local fields = {}
		for field in stat:gmatch "%S+" do
			table.insert(fields, field)
		end
		-- fields[14] = utime, fields[15] = stime
		local utime = tonumber(fields[14] or 0)
		local stime = tonumber(fields[15] or 0)
		-- On Linux, clock ticks per second (sysconf) is usually 100
		local clock_ticks = 100
		result.cpu_time_seconds = (utime + stime) / clock_ticks
		f2:close()
	end

	-- Count open file descriptors
	if lfs then
		local count = 0
		for _ in lfs.dir "/proc/self/fd" do
			count = count + 1
		end
		-- subtract 2 for "." and ".."
		result.open_fds = count - 2
	end

	return result
end

return M
