import { Router } from "express";
import { spawn } from "child_process";

const router = Router();

router.post("/nikto/scan", (req, res) => {
  const { target, port = 80, ssl = false } = req.body as {
    target: string;
    port?: number;
    ssl?: boolean;
  };
  if (!target) {
    res.status(400).json({ error: "target is required" });
    return;
  }
  const args = ["-h", target, "-p", String(port), "-Format", "txt", "-nointeractive"];
  if (ssl) args.push("-ssl");

  const proc = spawn("nikto", args, { timeout: 180000 });
  let stdout = "";
  let stderr = "";
  proc.stdout.on("data", (d) => { stdout += d.toString(); });
  proc.stderr.on("data", (d) => { stderr += d.toString(); });
  proc.on("close", (code) => {
    res.json({ exitCode: code, output: stdout, stderr });
  });
  proc.on("error", (err) => {
    res.status(500).json({ error: err.message, hint: "nikto may not be installed" });
  });
});

export default router;
