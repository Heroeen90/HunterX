import { Router } from "express";
import { spawn, type ChildProcess } from "child_process";
import path from "path";
import os from "os";
import fs from "fs";

const router = Router();
const activeCaptures = new Map<string, ChildProcess>();

router.get("/capture/interfaces", (_req, res) => {
  const proc = spawn("ip", ["link", "show"], { timeout: 5000 });
  let stdout = "";
  proc.stdout.on("data", (d) => { stdout += d.toString(); });
  proc.on("close", () => {
    const ifaces: string[] = [];
    for (const line of stdout.split("\n")) {
      const m = line.match(/^\d+:\s+(\w+):/);
      if (m && m[1] !== "lo") ifaces.push(m[1]);
    }
    res.json({ interfaces: ifaces });
  });
  proc.on("error", (err) => {
    res.status(500).json({ error: err.message });
  });
});

router.post("/capture/start", (req, res) => {
  const { iface = "eth0", filter, id } = req.body as {
    iface?: string;
    filter?: string;
    id: string;
  };
  if (!id) {
    res.status(400).json({ error: "id is required to track the capture session" });
    return;
  }
  if (activeCaptures.has(id)) {
    res.status(409).json({ error: "Capture session already active with this id" });
    return;
  }

  const outFile = path.join(os.tmpdir(), `hx_capture_${id}.pcap`);
  const args = ["-i", iface, "-w", outFile];
  if (filter) args.push(filter);

  const proc = spawn("tcpdump", args, { timeout: 0 });
  activeCaptures.set(id, proc);

  proc.on("error", () => { activeCaptures.delete(id); });
  proc.on("close", () => { activeCaptures.delete(id); });

  res.json({ status: "started", id, outFile });
});

router.post("/capture/stop", (req, res) => {
  const { id } = req.body as { id: string };
  if (!id || !activeCaptures.has(id)) {
    res.status(404).json({ error: "No active capture found for this id" });
    return;
  }
  const proc = activeCaptures.get(id)!;
  proc.kill("SIGTERM");
  activeCaptures.delete(id);

  const outFile = path.join(os.tmpdir(), `hx_capture_${id}.pcap`);
  res.json({ status: "stopped", id, outFile, exists: fs.existsSync(outFile) });
});

router.get("/capture/download/:id", (req, res) => {
  const { id } = req.params;
  const outFile = path.join(os.tmpdir(), `hx_capture_${id}.pcap`);
  if (!fs.existsSync(outFile)) {
    res.status(404).json({ error: "Capture file not found" });
    return;
  }
  res.download(outFile, `capture_${id}.pcap`);
});

export default router;
