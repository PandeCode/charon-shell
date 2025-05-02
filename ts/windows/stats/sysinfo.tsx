import { astal, Elements, useFile, useCmd } from "../../../tslib/react";

// Helper to format bytes to a human-readable format
function formatBytes(bytes: string, decimals = 2) {
  const parsed = parseInt(bytes.trim());
  if (isNaN(parsed)) return "0 B";
  if (parsed === 0) return "0 B";

  const k = 1024;
  const sizes = ["B", "KB", "MB", "GB", "TB", "PB"];
  const i = Math.floor(Math.log(parsed) / Math.log(k));

  return (
    parseFloat((parsed / Math.pow(k, i)).toFixed(decimals)) + " " + sizes[i]
  );
}

// Helper to render a single stat item
function StatItem({
  label,
  value,
}: {
  label: string;
  value: any | string | object;
}) {
  return (
    <div>
      <p hexpand halign="START" className="text-base0A">
        {label}
      </p>
      <eventbox
        on_button_press_event={(_obj: any, _evn: any) => {
          if (typeof value == "object") {
            let v: string = value.get(value);
            astal.exec_async(
              `bash -c 'notify-send "` + v + `"; echo "` + v + `" | cs'`,
            );
          }
        }}
      >
        <p hexpand halign="END" className="text-base04">
          {value}
        </p>
      </eventbox>
    </div>
  );
}

function CategorySection({
  title,
  stats,
}: {
  title: string;
  stats: [string, typeof astal.Variable][] | any[];
}) {
  return (
    <div vertical className="mb-2">
      <p className="text-base0D font-bold mb-1">{title}</p>
      <div vertical className="ml-2">
        {stats.map(([k, v]: [any, any]) => (
          <StatItem label={k} value={v} />
        ))}
      </div>
    </div>
  );
}

export default function () {
  const uptime = useCmd("uptime", (out) => out.split(" ")[0]);
  const release = useFile("/etc/os-release", (out) => {
    for (const line of out.split("\n")) {
      if (line.startsWith('VERSION="')) {
        return line.slice(9, -1);
      }
    }
    return "Error";
  });
  const cpu = useFile("/proc/cpuinfo", (out) => {
    for (const line of out.split("\n")) {
      if (line.startsWith("model name")) {
        return line.slice(13);
      }
    }
    return "Error";
  });
  const useGS = (sub: string) =>
    useCmd("gsettings get org.gnome.desktop.interface " + sub, (out) =>
      out.slice(1, -1),
    );

  // Memory information
  const memInfo = useFile("/proc/meminfo", (out) => {
    let total = "",
      free = "",
      available = "";
    for (const line of out.split("\n")) {
      if (line.startsWith("MemTotal:")) {
        const parts = line.split(" ").filter((part) => part.length > 0);
        if (parts.length >= 2) total = parts[1];
      }
      if (line.startsWith("MemFree:")) {
        const parts = line.split(" ").filter((part) => part.length > 0);
        if (parts.length >= 2) free = parts[1];
      }
      if (line.startsWith("MemAvailable:")) {
        const parts = line.split(" ").filter((part) => part.length > 0);
        if (parts.length >= 2) available = parts[1];
      }
    }

    if (total != null && available != null) {
      const totalMB = Math.round(parseInt(total) / 1024);
      const availableMB = Math.round(parseInt(available) / 1024);
      const usedMB = totalMB - availableMB;
      const usagePercent = Math.round((usedMB / totalMB) * 100);
      return `${usedMB} MB / ${totalMB} MB (${usagePercent}%)`;
    }
    return "Error";
  });

  // Disk usage
  const diskUsage = useCmd(
    "bash -c 'df -h / | tail -n 1 | tr -s \" \"'",
    (out) => {
      const parts = out.trim().split(" ");
      if (parts.length >= 5) {
        return `${parts[3]} / ${parts[2]} (${parts[4]})`;
      }
      return "Error";
    },
  );

  // IP Addresses
  const ipAddresses = useCmd(
    `ip.sh`,
    (out) => {
      const lines = out.split("\n");
      const results: string[] = [];

      for (const line of lines) {
        const parts = line
          .trim()
          .split(" ")
          .filter((part) => part.length > 0);
        if (parts.length >= 3) {
          const iface = parts[0];
          const ipv4 = parts[2].split("/")[0];
          results.push(`${iface}: ${ipv4}`);
        }
      }

      return results.join(" | ");
    },
  );

  // Swap usage
  const swapInfo = useFile("/proc/swaps", (out) => {
    const lines = out.split("\n");
    if (lines.length >= 2) {
      const parts = lines[1]
        .trim()
        .split(" ")
        .filter((part) => part.length > 0);
      if (parts.length >= 5) {
        const total = parseInt(parts[2]);
        const used = parseInt(parts[3]);
        const totalMB = Math.round(total / 1024);
        const usedMB = Math.round(used / 1024);
        const usagePercent = Math.round((usedMB / totalMB) * 100) || 0;
        return `${usedMB} MB / ${totalMB} MB (${usagePercent}%)`;
      }
    }
    return "Not available";
  });

  // CPU load
  const cpuLoad = useCmd("bash -c 'cat /proc/loadavg | cut -d\" \" -f1,2,3'");

  // GPU info (if available)
  const gpuInfo = useCmd("bash -c 'lspci | grep -i vga'", (out) => {
    const lines = out.split("\n");
    if (lines.length > 0 && lines[0].length > 0) {
      const parts = lines[0].split(": ");
      if (parts.length > 1) {
        return parts[1].trim();
      }
    }
    return "Not detected";
  });

  // External IP (if network is available)
  const externalIp = useCmd(
    "bash -c 'curl ifconfig.me",
  );

  // Process count
  const processCount = useCmd("bash -c 'ps aux | wc -l'", (out) => {
    const count = parseInt(out.trim());
    return isNaN(count) ? "Error" : (count - 1).toString();
  });

  // Temperature information
  const temperature = useCmd(
    'bash -c \'sensors | grep -i "Core 0" | cut -d "+" -f2 | cut -d " " -f1 || echo "Not available"\'',
  );

  // Battery information (if available)
  const batteryInfo = useCmd(
    "bash -c '[ -d /sys/class/power_supply/BAT0 ] && cat /sys/class/power_supply/BAT0/capacity || echo \"No battery\"'",
    (out) => {
      const level = out.trim();
      if (level !== "No battery") {
        return `${level}%`;
      }
      return level;
    },
  );

  // Group stats by category
  const systemStats = [
    {
      title: "System",
      items: [
        ["Release", release],
        ["Kernel", useCmd("uname -r")],
        ["Arch", useCmd("uname -m")],
        ["Hostname", useCmd("hostname")],
        ["Uptime", uptime],
        ["Processes", processCount],
        [
          "Packages",
          useCmd(
            "bash -c 'command -v dpkg > /dev/null && dpkg --get-selections | wc -l || command -v rpm > /dev/null && rpm -qa | wc -l || echo \"Unknown\"'",
          ),
        ],
      ],
    },
    {
      title: "Hardware",
      items: [
        ["CPU", cpu],
        ["Cores", useCmd("grep -c processor /proc/cpuinfo")],
        ["CPU Load", cpuLoad],
        ["CPU Temp", temperature],
        ["Memory", memInfo],
        ["Swap", swapInfo],
        ["Disk Usage", diskUsage],
        ["GPU", gpuInfo],
        ["Battery", batteryInfo],
      ],
    },
    {
      title: "Network",
      items: [
        ["Local IP", ipAddresses],
        ["External IP", externalIp],
      ],
    },
    {
      title: "User Environment",
      items: [
        ["User", useCmd("whoami")],
        ["Shell", (os.getenv("SHELL") ?? "error").slice(-4)],
        ["LANG", os.getenv("LANG") ?? "error"],
        ["TERM", os.getenv("TERM") ?? "error"],
        ["Desktop", os.getenv("XDG_CURRENT_DESKTOP") ?? "Unknown"],
        ["Session", os.getenv("$XDG_SESSION_TYPE") ?? "Unknown"],
      ],
    },
    {
      title: "Theme",
      items: [
        ["GTK Theme", useGS("gtk-theme")],
        ["Icons", useGS("icon-theme")],
        ["Font", useGS("font-name")],
        ["Cursor", useGS("cursor-theme")],
      ],
    },
  ];

  return (
    <grid>
      {systemStats.map((category, index) => {
        const size = 2;
        const x = index % size;
        const y = Math.floor(index / size);
        return (
          <griditem
            x={x}
            y={y}
            w={1}
            h={1}
            key={index}
            className="rounded-lg bg-base01 m-2 p-2"
          >
            <CategorySection title={category.title} stats={category.items} />
          </griditem>
        );
      })}
    </grid>
  );
}

// <grid>
//   <griditem x={0} y={0} w={1} h={1} className="p-2 m-1 text-base00 bg-base0B">
//     hi
//   </griditem>
//   <griditem x={1} y={0} w={2} h={1} className="p-2 m-1 text-base00 bg-base0B">
//     there
//   </griditem>
//   <griditem x={0} y={1} w={1} h={2} className="p-2 m-1 text-base00 bg-base0B">
//     how
//   </griditem>
//   <griditem x={1} y={1} w={1} h={1} className="p-2 m-1 text-base00 bg-base0B">
//     are
//   </griditem>
//   <griditem x={2} y={1} w={1} h={1} className="p-2 m-1 text-base00 bg-base0B">
//     you
//   </griditem>
//   <griditem x={1} y={2} w={2} h={1} className="p-2 m-1 text-base00 bg-base0B">
//     doing?
//   </griditem>
// </grid
