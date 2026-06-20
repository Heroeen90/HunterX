import { Router } from "express";
import { execSync } from "child_process";
import os from "os";

const router = Router();

router.get("/system/info", (_req, res) => {
  try {
    res.json({
      hostname: os.hostname(),
      platform: os.platform(),
      arch: os.arch(),
      release: os.release(),
      uptime: os.uptime(),
      loadAvg: os.loadavg(),
      totalMem: os.totalmem(),
      freeMem: os.freemem(),
      cpus: os.cpus().length,
    });
  } catch (err) {
    res.status(500).json({ error: (err as Error).message });
  }
});

router.get("/system/network", (_req, res) => {
  try {
    const ifaces = os.networkInterfaces();
    const result: Record<string, { address: string; family: string; internal: boolean }[]> = {};
    for (const [name, addrs] of Object.entries(ifaces)) {
      if (!addrs) continue;
      result[name] = addrs.map((a) => ({
        address: a.address,
        family: a.family,
        internal: a.internal,
      }));
    }
    res.json({ interfaces: result });
  } catch (err) {
    res.status(500).json({ error: (err as Error).message });
  }
});

router.get("/system/tools", (_req, res) => {
  const tools = [
    "nmap", "nikto", "sqlmap", "aircrack-ng", "hashcat",
    "tcpdump", "subfinder", "whois", "hashid", "ssh", "curl", "wget",
  ];
  const status: Record<string, boolean> = {};
  for (const tool of tools) {
    try {
      execSync(`which ${tool}`, { stdio: "ignore" });
      status[tool] = true;
    } catch {
      status[tool] = false;
    }
  }
  res.json({ tools: status });
});

export default router;
