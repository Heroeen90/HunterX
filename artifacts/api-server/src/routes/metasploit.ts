import { Router } from "express";
import { spawn } from "child_process";

const router = Router();

router.post("/metasploit/run", (req, res) => {
  const { module, options = {}, payload } = req.body as {
    module: string;
    options?: Record<string, string>;
    payload?: string;
  };
  if (!module) {
    res.status(400).json({ error: "module is required (e.g. auxiliary/scanner/portscan/tcp)" });
    return;
  }

  const rcLines = [`use ${module}`];
  for (const [key, val] of Object.entries(options)) {
    rcLines.push(`set ${key} ${val}`);
  }
  if (payload) rcLines.push(`set PAYLOAD ${payload}`);
  rcLines.push("run", "exit");

  const rcScript = rcLines.join("\n");

  const proc = spawn("msfconsole", ["-q", "-x", rcScript], { timeout: 300000 });
  let stdout = "";
  let stderr = "";
  proc.stdout.on("data", (d) => { stdout += d.toString(); });
  proc.stderr.on("data", (d) => { stderr += d.toString(); });
  proc.on("close", (code) => {
    res.json({ exitCode: code, output: stdout, stderr });
  });
  proc.on("error", (err) => {
    res.status(500).json({ error: err.message, hint: "Metasploit Framework (msfconsole) may not be installed" });
  });
});

router.get("/metasploit/modules", (req, res) => {
  const { search = "" } = req.query as { search?: string };
  const proc = spawn("msfconsole", ["-q", "-x", `search ${search}; exit`], { timeout: 60000 });
  let stdout = "";
  proc.stdout.on("data", (d) => { stdout += d.toString(); });
  proc.on("close", (code) => {
    res.json({ exitCode: code, output: stdout });
  });
  proc.on("error", (err) => {
    res.status(500).json({ error: err.message, hint: "Metasploit Framework may not be installed" });
  });
});

export default router;
