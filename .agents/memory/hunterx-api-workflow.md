---
name: HunterX API workflow workaround
description: Replit artifact-managed workflow port detection is broken for api-server on port 8080; workaround and root causes documented here.
---

# HunterX API — Workflow Port Detection Workaround

## The rule
Do NOT use `restart_workflow` on "artifacts/api-server: API Server" to keep the server running. Use the "HunterX API" standalone workflow instead.

**Why:** Replit's port-detection mechanism cannot see port 8080 opened by the artifact-managed workflow's process chain. It sends SIGKILL after its timeout, the process dies, and `restart_workflow` returns `DIDNT_OPEN_A_PORT` indefinitely — even though the server works correctly in bash.

**How to apply:** After any `pnpm --filter @workspace/api-server run build`, restart via:
```javascript
await restartWorkflow({ workflowName: "HunterX API", timeout: 10 });
```
Or in bash: `cd artifacts/api-server && PORT=8080 node --enable-source-maps dist/index.mjs`

## Root causes found

1. **pino-pretty transport**: The original logger used `pino-pretty` as a transport (worker thread via `thread-stream`). In the workflow's piped stdout context, this worker crashes silently and exits the process. Fixed by removing the transport — logger now uses plain JSON pino.

2. **Artifact workflow port detection**: Replit's health check for the artifact-managed "API Server" workflow cannot detect port 8080 even when the server binds successfully (curl returns 200 OK from bash). All restart attempts end in SIGKILL + DIDNT_OPEN_A_PORT. Root cause unknown (possibly process hierarchy: Replit runner → pnpm → bash → node).

3. **artifact.toml dev path**: The `[services.development] run` command executes from the *artifact directory* (`artifacts/api-server/`), not the workspace root. Use relative paths like `dist/index.mjs`, not `artifacts/api-server/dist/index.mjs`.

## Current working setup
- **Workflow**: "HunterX API" (standalone, no `waitForPort`)
- **Command**: `cd /home/runner/workspace/artifacts/api-server && PORT=8080 node --enable-source-maps dist/index.mjs`
- **Dev script** (`package.json`): `export NODE_ENV=development && node --enable-source-maps ./dist/index.mjs`
- **Logger**: plain pino (no pino-pretty transport)
- **Port**: 8080, bound to 0.0.0.0
- Proxy routes `/api` → port 8080 via `artifact.toml` `localPort = 8080`
