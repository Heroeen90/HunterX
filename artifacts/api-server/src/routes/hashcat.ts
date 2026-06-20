import { Router } from "express";
import { spawn } from "child_process";
import fs from "fs";
import os from "os";
import path from "path";

const router = Router();

router.post("/hashcat/crack", (req, res) => {
  const {
    hash,
    hashType = 0,
    attackMode = 0,
    wordlist = "/usr/share/wordlists/rockyou.txt",
    mask,
    rules,
  } = req.body as {
    hash: string;
    hashType?: number;
    attackMode?: number;
    wordlist?: string;
    mask?: string;
    rules?: string;
  };

  if (!hash) {
    res.status(400).json({ error: "hash is required" });
    return;
  }

  const tmpFile = path.join(os.tmpdir(), `hx_hash_${Date.now()}.txt`);
  fs.writeFileSync(tmpFile, hash + "\n");

  const args = [
    "-m", String(hashType),
    "-a", String(attackMode),
    "--quiet",
    "--potfile-disable",
    "--force",
    tmpFile,
  ];

  if (attackMode === 0) {
    args.push(wordlist);
    if (rules) args.push("-r", rules);
  } else if (attackMode === 3 && mask) {
    args.push(mask);
  }

  const proc = spawn("hashcat", args, { timeout: 300000 });
  let stdout = "";
  let stderr = "";
  proc.stdout.on("data", (d) => { stdout += d.toString(); });
  proc.stderr.on("data", (d) => { stderr += d.toString(); });
  proc.on("close", (code) => {
    try { fs.unlinkSync(tmpFile); } catch {}
    const cracked = stdout.match(/(.+):(.+)/);
    res.json({
      exitCode: code,
      cracked: cracked ? cracked[2].trim() : null,
      output: stdout,
      stderr,
    });
  });
  proc.on("error", (err) => {
    try { fs.unlinkSync(tmpFile); } catch {}
    res.status(500).json({ error: err.message, hint: "hashcat may not be installed" });
  });
});

router.post("/hashcat/identify", (req, res) => {
  const { hash } = req.body as { hash: string };
  if (!hash) {
    res.status(400).json({ error: "hash is required" });
    return;
  }
  const proc = spawn("hashid", [hash], { timeout: 10000 });
  let stdout = "";
  proc.stdout.on("data", (d) => { stdout += d.toString(); });
  proc.on("close", (code) => {
    res.json({ exitCode: code, output: stdout });
  });
  proc.on("error", (err) => {
    res.status(500).json({ error: err.message, hint: "hashid may not be installed" });
  });
});

export default router;
