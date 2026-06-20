import { Router } from "express";
import { spawn } from "child_process";

const router = Router();

router.post("/sqlmap/scan", (req, res) => {
  const { url, method = "GET", data, level = 1, risk = 1, dbs = false } = req.body as {
    url: string;
    method?: string;
    data?: string;
    level?: number;
    risk?: number;
    dbs?: boolean;
  };
  if (!url) {
    res.status(400).json({ error: "url is required" });
    return;
  }
  const args = ["-u", url, "--batch", `--level=${level}`, `--risk=${risk}`];
  if (method === "POST" && data) { args.push("--data", data); }
  if (dbs) args.push("--dbs");

  const proc = spawn("sqlmap", args, { timeout: 300000 });
  let stdout = "";
  let stderr = "";
  proc.stdout.on("data", (d) => { stdout += d.toString(); });
  proc.stderr.on("data", (d) => { stderr += d.toString(); });
  proc.on("close", (code) => {
    res.json({ exitCode: code, output: stdout, stderr });
  });
  proc.on("error", (err) => {
    res.status(500).json({ error: err.message, hint: "sqlmap may not be installed" });
  });
});

export default router;
