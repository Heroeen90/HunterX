# HunterX

A mobile penetration testing suite consisting of a **Flutter Android app** and a **Node.js backend server**.

## Architecture

```
HunterX/
├── flutter_app/          # Flutter Android app (Dart)
└── backend_server/       # Node.js + Express + WebSocket server
```

The Flutter app can work in two modes:
- **On-device** — network scanning and port scanning run directly on the Android device (no server needed)
- **Server mode** — connects to the HunterX backend to run nmap, nikto, sqlmap, hashcat, metasploit, tcpdump, and other tools that require root/raw sockets

## Backend Server

The backend is a **Node.js/Express/WebSocket** server. It is built as a TypeScript module inside this monorepo at `artifacts/api-server/`.

### Endpoints

| Method | Path | Tool |
|--------|------|------|
| POST | `/api/nmap/scan` | nmap (full scan) |
| POST | `/api/nmap/ping-sweep` | nmap -sn |
| POST | `/api/nikto/scan` | nikto |
| POST | `/api/sqlmap/scan` | sqlmap |
| GET  | `/api/aircrack/interfaces` | wireless interfaces |
| POST | `/api/aircrack/crack` | aircrack-ng |
| POST | `/api/dns/lookup` | Node dns module |
| POST | `/api/dns/whois` | whois |
| POST | `/api/dns/subfinder` | subfinder |
| POST | `/api/dns/reverse` | reverse DNS |
| POST | `/api/hashcat/crack` | hashcat |
| POST | `/api/hashcat/identify` | hashid |
| GET  | `/api/capture/interfaces` | network interfaces |
| POST | `/api/capture/start` | tcpdump |
| POST | `/api/capture/stop` | stop capture |
| GET  | `/api/capture/download/:id` | download .pcap |
| POST | `/api/metasploit/run` | msfconsole |
| GET  | `/api/metasploit/modules` | search modules |
| GET  | `/api/system/info` | system info |
| GET  | `/api/system/tools` | check installed tools |
| GET  | `/api/system/network` | network interfaces |
| WS   | `/ws/terminal` | real-time terminal streaming |

### WebSocket Protocol (`/ws/terminal`)

Send JSON messages:

```json
{ "action": "start", "command": "nmap", "args": ["-sV", "192.168.1.0/24"] }
{ "action": "input", "data": "some input\n" }
{ "action": "stop" }
```

Receive JSON messages: `{ "type": "output"|"stderr"|"exit"|"error", "data": "..." }`

### Authentication

Set `HUNTERX_API_KEY` environment variable on the server. All requests must include:
```
X-API-Key: your-key-here
```
Leave unset to disable auth (development only).

### Running with Docker

```bash
cd HunterX/backend_server
cp .env.example .env
# Edit .env and set HUNTERX_API_KEY
docker-compose up -d
```

### Running the dev server (this monorepo)

```bash
pnpm --filter @workspace/api-server run dev
```

## Flutter App

### Requirements

- Flutter 3.22+ SDK
- Android Studio / VS Code with Flutter extension
- Android device or emulator (API 23+)

### Setup

```bash
cd HunterX/flutter_app
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Build APK

```bash
flutter build apk --release --split-per-abi
# Output: build/app/outputs/flutter-apk/
```

### CI/CD

- **`build-apk.yml`** — Automatically builds and uploads the APK on every push to `main` that touches `flutter_app/`
- **`docker-deploy.yml`** — Builds Docker image and optionally deploys to your server via SSH

## Disclaimer

This tool is for authorized security testing only. Never use against systems you don't own or have explicit written permission to test.
