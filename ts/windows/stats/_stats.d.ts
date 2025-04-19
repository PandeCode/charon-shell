declare interface OSInfo {
  os: string;
  architecture: string;
  host: string;
  kernel: string;
  uptime: string;
  packages: string;
  shell: string;
  locale: string;
}

declare interface DisplayInfo {
  desktop_env: string;
  wm: string;
  theme: string;
  icons: string;
  font: string;
  cursor: string;
  terminal: string;
  displays: Array<{
    name: string;
    resolution: string;
  }>;
}

declare interface CPUInfo {
  model: string;
  cores: number;
  temperature: string;
  usage: string;
}

declare interface GPUInfo {
  model: string;
  memory: string;
  temperature: string;
}

declare interface MemoryInfo {
  memory: {
    total: string;
    used: string;
    free: string;
    percent_used: string;
  };
  swap: {
    total: string;
    used: string;
    free: string;
    percent_used: string;
  };
}

declare interface DiskInfo {
  device: string;
  mount: string;
  total: string;
  used: string;
  free: string;
  percent_used: string;
}

declare interface NetworkInfo {
  name: string;
  ip: string;
  type: string;
}

declare interface BatteryInfo {
  name: string;
  capacity: string;
  status: string;
}

declare interface SystemData {
  os: OSInfo;
  display: DisplayInfo;
  cpu: CPUInfo;
  gpus: GPUInfo[];
  memory: MemoryInfo;
  disks: DiskInfo[];
  network: NetworkInfo[];
  batteries: BatteryInfo[];
}

declare interface SystemInfoProps {
  data?: SystemData;
}
