local ____lualib = require("lualib_bundle")
local __TS__StringTrim = ____lualib.__TS__StringTrim
local __TS__ParseInt = ____lualib.__TS__ParseInt
local __TS__Number = ____lualib.__TS__Number
local __TS__NumberIsNaN = ____lualib.__TS__NumberIsNaN
local __TS__NumberToFixed = ____lualib.__TS__NumberToFixed
local __TS__ParseFloat = ____lualib.__TS__ParseFloat
local __TS__ArrayMap = ____lualib.__TS__ArrayMap
local __TS__StringSplit = ____lualib.__TS__StringSplit
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter
local ____exports = {}
local ____react = require("tslib.react")
local Elements = ____react.Elements
local useFile = ____react.useFile
local useCmd = ____react.useCmd
local function formatBytes(bytes, decimals)
    if decimals == nil then
        decimals = 2
    end
    local parsed = __TS__ParseInt(__TS__StringTrim(bytes))
    if __TS__NumberIsNaN(__TS__Number(parsed)) then
        return "0 B"
    end
    if parsed == 0 then
        return "0 B"
    end
    local k = 1024
    local sizes = {
        "B",
        "KB",
        "MB",
        "GB",
        "TB",
        "PB"
    }
    local i = math.floor(math.log(parsed) / math.log(k))
    return (tostring(__TS__ParseFloat(__TS__NumberToFixed(parsed / k ^ i, decimals))) .. " ") .. sizes[i + 1]
end
local function StatItem(____bindingPattern0)
    local value
    local label
    label = ____bindingPattern0.label
    value = ____bindingPattern0.value
    return Elements.Create(
        "div",
        nil,
        Elements.Create("p", {hexpand = true, halign = "START", className = "text-base0A"}, label),
        Elements.Create("p", {hexpand = true, halign = "END", className = "text-base04"}, value)
    )
end
local function CategorySection(____bindingPattern0)
    local stats
    local title
    title = ____bindingPattern0.title
    stats = ____bindingPattern0.stats
    return Elements.Create(
        "div",
        {vertical = true, className = "mb-2"},
        Elements.Create("p", {className = "text-base0D font-bold mb-1"}, title),
        Elements.Create(
            "div",
            {vertical = true, className = "ml-2"},
            __TS__ArrayMap(
                stats,
                function(____, ____bindingPattern0)
                    local v
                    local k
                    k = ____bindingPattern0[1]
                    v = ____bindingPattern0[2]
                    return Elements.Create(StatItem, {label = k, value = v})
                end
            )
        )
    )
end
function ____exports.default()
    local uptime = useCmd(
        "uptime",
        function(out) return __TS__StringSplit(out, " ")[1] end
    )
    local release = useFile(
        "/etc/os-release",
        function(out)
            for ____, line in ipairs(__TS__StringSplit(out, "\n")) do
                if __TS__StringStartsWith(line, "VERSION=\"") then
                    return string.sub(line, 10, -2)
                end
            end
            return "Error"
        end
    )
    local cpu = useFile(
        "/proc/cpuinfo",
        function(out)
            for ____, line in ipairs(__TS__StringSplit(out, "\n")) do
                if __TS__StringStartsWith(line, "model name") then
                    return string.sub(line, 14)
                end
            end
            return "Error"
        end
    )
    local function useGS(sub)
        return useCmd(
            "gsettings get org.gnome.desktop.interface " .. sub,
            function(out) return string.sub(out, 2, -2) end
        )
    end
    local memInfo = useFile(
        "/proc/meminfo",
        function(out)
            local total = ""
            local free = ""
            local available = ""
            for ____, line in ipairs(__TS__StringSplit(out, "\n")) do
                if __TS__StringStartsWith(line, "MemTotal:") then
                    local parts = __TS__ArrayFilter(
                        __TS__StringSplit(line, " "),
                        function(____, part) return #part > 0 end
                    )
                    if #parts >= 2 then
                        total = parts[2]
                    end
                end
                if __TS__StringStartsWith(line, "MemFree:") then
                    local parts = __TS__ArrayFilter(
                        __TS__StringSplit(line, " "),
                        function(____, part) return #part > 0 end
                    )
                    if #parts >= 2 then
                        free = parts[2]
                    end
                end
                if __TS__StringStartsWith(line, "MemAvailable:") then
                    local parts = __TS__ArrayFilter(
                        __TS__StringSplit(line, " "),
                        function(____, part) return #part > 0 end
                    )
                    if #parts >= 2 then
                        available = parts[2]
                    end
                end
            end
            if total and available then
                local totalMB = math.floor(__TS__ParseInt(total) / 1024 + 0.5)
                local availableMB = math.floor(__TS__ParseInt(available) / 1024 + 0.5)
                local usedMB = totalMB - availableMB
                local usagePercent = math.floor(usedMB / totalMB * 100 + 0.5)
                return ((((tostring(usedMB) .. " MB / ") .. tostring(totalMB)) .. " MB (") .. tostring(usagePercent)) .. "%)"
            end
            return "Error"
        end
    )
    local diskUsage = useCmd(
        "bash -c 'df -h / | tail -n 1 | tr -s \" \"'",
        function(out)
            local parts = __TS__StringSplit(
                __TS__StringTrim(out),
                " "
            )
            if #parts >= 5 then
                return ((((parts[4] .. " / ") .. parts[3]) .. " (") .. parts[5]) .. ")"
            end
            return "Error"
        end
    )
    local ipAddresses = useCmd(
        "bash -c 'ip -br addr | grep -v \"lo\"'",
        function(out)
            local lines = __TS__StringSplit(out, "\n")
            local results = {}
            for ____, line in ipairs(lines) do
                local parts = __TS__ArrayFilter(
                    __TS__StringSplit(
                        __TS__StringTrim(line),
                        " "
                    ),
                    function(____, part) return #part > 0 end
                )
                if #parts >= 3 then
                    local iface = parts[1]
                    local ipv4 = __TS__StringSplit(parts[3], "/")[1]
                    results[#results + 1] = (iface .. ": ") .. ipv4
                end
            end
            return table.concat(results, " | ")
        end
    )
    local swapInfo = useFile(
        "/proc/swaps",
        function(out)
            local lines = __TS__StringSplit(out, "\n")
            if #lines >= 2 then
                local parts = __TS__ArrayFilter(
                    __TS__StringSplit(
                        __TS__StringTrim(lines[2]),
                        " "
                    ),
                    function(____, part) return #part > 0 end
                )
                if #parts >= 5 then
                    local total = __TS__ParseInt(parts[3])
                    local used = __TS__ParseInt(parts[4])
                    local totalMB = math.floor(total / 1024 + 0.5)
                    local usedMB = math.floor(used / 1024 + 0.5)
                    local usagePercent = math.floor(usedMB / totalMB * 100 + 0.5) or 0
                    return ((((tostring(usedMB) .. " MB / ") .. tostring(totalMB)) .. " MB (") .. tostring(usagePercent)) .. "%)"
                end
            end
            return "Not available"
        end
    )
    local cpuLoad = useCmd("bash -c 'cat /proc/loadavg | cut -d\" \" -f1,2,3'")
    local gpuInfo = useCmd(
        "bash -c 'lspci | grep -i vga'",
        function(out)
            local lines = __TS__StringSplit(out, "\n")
            if #lines > 0 and #lines[1] > 0 then
                local parts = __TS__StringSplit(lines[1], ": ")
                if #parts > 1 then
                    return __TS__StringTrim(parts[2])
                end
            end
            return "Not detected"
        end
    )
    local externalIp = useCmd("bash -c 'curl -s --max-time 1 https://ipinfo.io/ip || echo \"Not available\"'")
    local processCount = useCmd(
        "bash -c 'ps aux | wc -l'",
        function(out)
            local count = __TS__ParseInt(__TS__StringTrim(out))
            return __TS__NumberIsNaN(__TS__Number(count)) and "Error" or tostring(count - 1)
        end
    )
    local temperature = useCmd("bash -c 'sensors | grep -i \"Core 0\" | cut -d \"+\" -f2 | cut -d \" \" -f1 || echo \"Not available\"'")
    local batteryInfo = useCmd(
        "bash -c '[ -d /sys/class/power_supply/BAT0 ] && cat /sys/class/power_supply/BAT0/capacity || echo \"No battery\"'",
        function(out)
            local level = __TS__StringTrim(out)
            if level ~= "No battery" then
                return level .. "%"
            end
            return level
        end
    )
    local systemStats = {
        {
            title = "System",
            items = {
                {"Release", release},
                {
                    "Kernel",
                    useCmd("uname -r")
                },
                {
                    "Arch",
                    useCmd("uname -m")
                },
                {
                    "Hostname",
                    useCmd("hostname")
                },
                {"Uptime", uptime},
                {"Processes", processCount},
                {
                    "Packages",
                    useCmd("bash -c 'command -v dpkg > /dev/null && dpkg --get-selections | wc -l || command -v rpm > /dev/null && rpm -qa | wc -l || echo \"Unknown\"'")
                }
            }
        },
        {
            title = "Hardware",
            items = {
                {"CPU", cpu},
                {
                    "Cores",
                    useCmd("grep -c processor /proc/cpuinfo")
                },
                {"CPU Load", cpuLoad},
                {"CPU Temp", temperature},
                {"Memory", memInfo},
                {"Swap", swapInfo},
                {"Disk Usage", diskUsage},
                {"GPU", gpuInfo},
                {"Battery", batteryInfo}
            }
        },
        {title = "Network", items = {{"Local IP", ipAddresses}, {"External IP", externalIp}}},
        {
            title = "User Environment",
            items = {
                {
                    "User",
                    useCmd("whoami")
                },
                {
                    "Shell",
                    string.sub(
                        os.getenv("SHELL") or "error",
                        -4
                    )
                },
                {
                    "LANG",
                    os.getenv("LANG") or "error"
                },
                {
                    "TERM",
                    os.getenv("TERM") or "error"
                },
                {
                    "Desktop",
                    os.getenv("XDG_CURRENT_DESKTOP") or "Unknown"
                },
                {
                    "Session",
                    os.getenv("$XDG_SESSION_TYPE") or "Unknown"
                }
            }
        },
        {
            title = "Theme",
            items = {
                {
                    "GTK Theme",
                    useGS("gtk-theme")
                },
                {
                    "Icons",
                    useGS("icon-theme")
                },
                {
                    "Font",
                    useGS("font-name")
                },
                {
                    "Cursor",
                    useGS("cursor-theme")
                }
            }
        }
    }
    return Elements.Create(
        "grid",
        nil,
        __TS__ArrayMap(
            systemStats,
            function(____, category, index)
                local size = 2
                local x = index % size
                local y = math.floor(index / size)
                return Elements.Create(
                    "griditem",
                    {
                        x = x,
                        y = y,
                        w = 1,
                        h = 1,
                        key = index,
                        className = "rounded-lg bg-base01 m-2 p-2"
                    },
                    Elements.Create(CategorySection, {title = category.title, stats = category.items})
                )
            end
        )
    )
end
return ____exports
