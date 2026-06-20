import { Router } from "express";
import { spawn } from "child_process";
import dns from "dns/promises";

const router = Router();

router.post("/dns/lookup", async (req, res) => {
  const { domain, type = "A" } = req.body as { domain: string; type?: string };
  if (!domain) {
    res.status(400).json({ error: "domain is required" });
    return;
  }
  try {
    let records: unknown;
    switch (type.toUpperCase()) {
      case "A":   records = await dns.resolve4(domain); break;
      case "AAAA": records = await dns.resolve6(domain); break;
      case "MX":  records = await dns.resolveMx(domain); break;
      case "NS":  records = await dns.resolveNs(domain); break;
      case "TXT": records = await dns.resolveTxt(domain); break;
      case "CNAME": records = await dns.resolveCname(domain); break;
      case "SOA": records = await dns.resolveSoa(domain); break;
      default:    records = await dns.resolve(domain, type as Parameters<typeof dns.resolve>[1]);
    }
    res.json({ domain, type, records });
  } catch (err) {
    res.status(500).json({ error: (err as Error).message });
  }
});

router.post("/dns/whois", (req, res) => {
  const { domain } = req.body as { domain: string };
  if (!domain) {
    res.status(400).json({ error: "domain is required" });
    return;
  }
  const proc = spawn("whois", [domain], { timeout: 30000 });
  let stdout = "";
  let stderr = "";
  proc.stdout.on("data", (d) => { stdout += d.toString(); });
  proc.stderr.on("data", (d) => { stderr += d.toString(); });
  proc.on("close", (code) => {
    res.json({ exitCode: code, output: stdout, stderr });
  });
  proc.on("error", (err) => {
    res.status(500).json({ error: err.message });
  });
});

router.post("/dns/subfinder", (req, res) => {
  const { domain, passive = true } = req.body as { domain: string; passive?: boolean };
  if (!domain) {
    res.status(400).json({ error: "domain is required" });
    return;
  }
  const args = ["-d", domain, "-silent"];
  if (passive) args.push("-passive");

  const proc = spawn("subfinder", args, { timeout: 120000 });
  let stdout = "";
  let stderr = "";
  proc.stdout.on("data", (d) => { stdout += d.toString(); });
  proc.stderr.on("data", (d) => { stderr += d.toString(); });
  proc.on("close", (code) => {
    const subdomains = stdout.split("\n").filter(Boolean);
    res.json({ exitCode: code, domain, subdomains, stderr });
  });
  proc.on("error", (err) => {
    res.status(500).json({ error: err.message, hint: "subfinder may not be installed" });
  });
});

router.post("/dns/reverse", async (req, res) => {
  const { ip } = req.body as { ip: string };
  if (!ip) {
    res.status(400).json({ error: "ip is required" });
    return;
  }
  try {
    const hostnames = await dns.reverse(ip);
    res.json({ ip, hostnames });
  } catch (err) {
    res.status(500).json({ error: (err as Error).message });
  }
});

export default router;
