import { Router } from "express";
import { spawn } from "child_process";
import fs from "fs";
import path from "path";

const router = Router();

router.get("/aircrack/interfaces", (_req, res) => {
  const proc = spawn("iwconfig", [], { timeout: 5000 });
  let stdout = "";
  proc.stdout.on("data", (d) => { stdout += d.toString(); });
  proc.on("close", () => {
    const ifaces: string[] = [];
    const lines = stdout.split("\n");
    for (const line of lines) {
      const m = line.match(/^(\w+)\s+IEEE/);
      if (m) ifaces.push(m[1]);
    }
    res.json({ interfaces: ifaces, raw: stdout });
  });
  proc.on("error", (err) => {
    res.status(500).json({ error: err.message });
  });
});

router.post("/aircrack/crack", (req, res) => {
  const { capFile, wordlist = "/usr/share/wordlists/rockyou.txt", bssid } = req.body as {
    capFile: string;
    wordlist?: string;
    bssid?: string;
  };
  if (!capFile || !fs.existsSync(capFile)) {
    res.status(400).json({ error: "capFile path is required and must exist on server" });
    return;
  }
  const args = [capFile, "-w", wordlist];
  if (bssid) { args.push("-b", bssid); }

  const proc = spawn("aircrack-ng", args, { timeout: 600000 });
  let stdout = "";
  let stderr = "";
  proc.stdout.on("data", (d) => { stdout += d.toString(); });
  proc.stderr.on("data", (d) => { stderr += d.toString(); });
  proc.on("close", (code) => {
    const keyMatch = stdout.match(/KEY FOUND!\s*\[\s*(.+?)\s*\]/);
    res.json({ exitCode: code, keyFound: keyMatch ? keyMatch[1] : null, output: stdout, stderr });
  });
  proc.on("error", (err) => {
    res.status(500).json({ error: err.message, hint: "aircrack-ng may not be installed" });
  });
});

export default router;
