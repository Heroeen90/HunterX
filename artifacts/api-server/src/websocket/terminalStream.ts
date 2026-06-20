import { WebSocket, WebSocketServer } from "ws";
import { spawn, type ChildProcess } from "child_process";
import type { IncomingMessage } from "http";
import type { Server } from "http";
import type { RawData } from "ws";

interface SessionMessage {
  action: "start" | "input" | "resize" | "stop";
  command?: string;
  args?: string[];
  data?: string;
  cols?: number;
  rows?: number;
}

const activeSessions = new Map<string, ChildProcess>();

export function attachWebSocketServer(server: Server): void {
  const wss = new WebSocketServer({ server, path: "/ws/terminal" });

  wss.on("connection", (ws: WebSocket, _req: IncomingMessage) => {
    const sessionId = Math.random().toString(36).slice(2);
    let childProc: ChildProcess | null = null;

    ws.send(JSON.stringify({ type: "connected", sessionId }));

    ws.on("message", (raw: RawData) => {
      let msg: SessionMessage;
      try {
        msg = JSON.parse(raw.toString()) as SessionMessage;
      } catch {
        ws.send(JSON.stringify({ type: "error", data: "Invalid JSON message" }));
        return;
      }

      switch (msg.action) {
        case "start": {
          if (childProc) {
            ws.send(JSON.stringify({ type: "error", data: "Session already running" }));
            return;
          }
          const cmd = msg.command ?? "sh";
          const args = msg.args ?? [];

          const allowedCommands = [
            "sh", "bash", "nmap", "nikto", "sqlmap", "aircrack-ng",
            "hashcat", "tcpdump", "ssh", "curl", "wget", "ping",
            "traceroute", "dig", "nslookup", "whois", "subfinder",
            "hydra", "john", "gobuster", "ffuf", "dirb",
          ];

          if (!allowedCommands.includes(cmd.split("/").pop() ?? "")) {
            ws.send(JSON.stringify({ type: "error", data: `Command '${cmd}' not in allowlist` }));
            return;
          }

          childProc = spawn(cmd, args, {
            shell: false,
            env: { ...process.env, TERM: "xterm-256color" },
          });

          activeSessions.set(sessionId, childProc);

          childProc.stdout?.on("data", (data: Buffer) => {
            if (ws.readyState === WebSocket.OPEN) {
              ws.send(JSON.stringify({ type: "output", data: data.toString("utf8") }));
            }
          });

          childProc.stderr?.on("data", (data: Buffer) => {
            if (ws.readyState === WebSocket.OPEN) {
              ws.send(JSON.stringify({ type: "stderr", data: data.toString("utf8") }));
            }
          });

          childProc.on("close", (code) => {
            activeSessions.delete(sessionId);
            childProc = null;
            if (ws.readyState === WebSocket.OPEN) {
              ws.send(JSON.stringify({ type: "exit", code }));
            }
          });

          childProc.on("error", (err) => {
            if (ws.readyState === WebSocket.OPEN) {
              ws.send(JSON.stringify({ type: "error", data: err.message }));
            }
          });

          ws.send(JSON.stringify({ type: "started", command: cmd, args }));
          break;
        }

        case "input": {
          if (!childProc || !childProc.stdin) {
            ws.send(JSON.stringify({ type: "error", data: "No running process" }));
            return;
          }
          childProc.stdin.write(msg.data ?? "");
          break;
        }

        case "stop": {
          if (childProc) {
            childProc.kill("SIGTERM");
            setTimeout(() => { childProc?.kill("SIGKILL"); }, 3000);
            childProc = null;
          }
          ws.send(JSON.stringify({ type: "stopped" }));
          break;
        }
      }
    });

    ws.on("close", () => {
      if (childProc) {
        childProc.kill("SIGTERM");
        activeSessions.delete(sessionId);
      }
    });

    ws.on("error", () => {
      if (childProc) {
        childProc.kill("SIGTERM");
        activeSessions.delete(sessionId);
      }
    });
  });
}
