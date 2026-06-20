# HunterX Flutter App

Mobile penetration testing application for Android.

## Features

| Screen | On-device | Server required |
|--------|-----------|----------------|
| Network Scanner | Yes (TCP connect sweep) | Optional (nmap) |
| Port Scanner | Yes (TCP connect) | No |
| WiFi Analyzer | Yes (wifi_scan) | No |
| Web Scanner (Nikto) | No | Yes |
| DNS / OSINT | Yes (dns lookup) | Yes (whois, subfinder) |
| Exploitation (Metasploit) | No | Yes |
| Password Tools (hashcat) | No | Yes |
| SSH Terminal | Yes (dartssh2) | No |
| Packet Capture | No | Yes |
| Browser Tunnel | Yes | No |
| Server Control | No | Yes |

## Project Structure

```
lib/
├── main.dart                   # App entry point
├── core/
│   ├── theme/app_theme.dart    # Dark hacker theme
│   ├── router/app_router.dart  # go_router navigation
│   └── constants/              # API URLs & config
├── features/                   # One folder per feature
│   ├── home/
│   ├── network_scanner/
│   ├── port_scanner/
│   ├── wifi_analyzer/
│   ├── web_scanner/
│   ├── dns_osint/
│   ├── exploitation/
│   ├── password_tools/
│   ├── ssh_terminal/
│   ├── packet_capture/
│   ├── browser_tunnel/
│   ├── server_control/
│   └── settings/
└── shared/
    ├── services/               # API, WebSocket, on-device scanner
    └── widgets/                # TerminalOutputWidget, ServerStatusWidget
```

## Build

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter build apk --release --split-per-abi
```

## Required Permissions (AndroidManifest.xml)

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE"/>
<uses-permission android:name="android.permission.CHANGE_WIFI_STATE"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
```
