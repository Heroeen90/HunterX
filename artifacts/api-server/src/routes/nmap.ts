import { Router } from "express";
import { spawn } from "child_process";

const router = Router();

router.post("/nmap/scan", (req, res) => {
  const { target, flags = "-sV -T4" } = req.body as { target: string; flags?: string };
  if (!target) {
    res.status(400).json({ error: "target is required" });
    return;
  }
  const args = [...flags.trim().split(/\s+/), target];
  const proc = spawn("nmap", args, { timeout: 120000 });
  let stdout = "";
  let stderr = "";
  proc.stdout.on("data", (d) => { stdout += d.toString(); });
  proc.stderr.on("data", (d) => { stderr += d.toString(); });
  proc.on("close", (code) => {
    res.json({ exitCode: code, stdout, stderr });
  });
  proc.on("error", (err) => {
    res.status(500).json({ error: err.message, hint: "nmap may not be installed on this system" });
  });
});

router.post("/nmap/ping-sweep", (req, res) => {
  const { subnet } = req.body as { subnet: string };
  if (!subnet) {
    res.status(400).json({ error: "subnet is required (e.g. 192.168.1.0/24)" });
    return;
  }
  const proc = spawn("nmap", ["-sn", subnet], { timeout: 60000 });
  let stdout = "";
  let stderr = "";
  proc.stdout.on("data", (d) => { stdout += d.toString(); });
  proc.stderr.on("data", (d) => { stderr += d.toString(); });
  proc.on("close", (code) => {
    const hosts: string[] = [];
    const lines = stdout.split("\n");
    for (const line of lines) {
      const m = line.match(/Nmap scan report for (.+)/);
      if (m) hosts.push(m[1].trim());
    }
    res.json({ exitCode: code, hosts, raw: stdout, stderr });
  });
  proc.on("error", (err) => {
    res.status(500).json({ error: err.message });
  });
});

export default router;
