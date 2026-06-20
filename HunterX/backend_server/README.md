# HunterX Backend Server

Node.js + Express + WebSocket backend for the HunterX mobile app.

## Quick Start

### Docker (recommended)

```bash
cp .env.example .env
# Edit HUNTERX_API_KEY in .env
docker-compose up -d
docker-compose logs -f
```

### Manual (Kali / Debian)

```bash
# Install tools
apt-get install nmap nikto sqlmap aircrack-ng hashcat tcpdump whois -y

# Optional
apt-get install metasploit-framework subfinder -y

# Start server
npm install
PORT=5000 node src/index.js
```

## Tool Requirements

The server wraps command-line tools. Install what you need:

| Tool | apt package | Required for |
|------|-------------|-------------|
| nmap | `nmap` | Network/port scanning |
| nikto | `nikto` | Web vulnerability scanning |
| sqlmap | `sqlmap` | SQL injection |
| aircrack-ng | `aircrack-ng` | WPA/WEP cracking |
| hashcat | `hashcat` | Hash cracking |
| tcpdump | `tcpdump` | Packet capture |
| whois | `whois` | Domain OSINT |
| subfinder | (go install) | Subdomain enumeration |
| msfconsole | `metasploit-framework` | Exploitation |

## Security

- Set `HUNTERX_API_KEY` in your environment to require authentication
- Run behind a VPN — never expose port 5000 to the public internet
- The server only allows whitelisted commands via WebSocket
- Use HTTPS in production (nginx/caddy as reverse proxy)

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PORT` | `5000` | Server port |
| `HUNTERX_API_KEY` | (empty) | API authentication key |
| `NODE_ENV` | `production` | Environment mode |
