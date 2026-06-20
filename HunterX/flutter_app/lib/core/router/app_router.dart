import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/home_screen.dart';
import '../../features/network_scanner/network_scanner_screen.dart';
import '../../features/port_scanner/port_scanner_screen.dart';
import '../../features/wifi_analyzer/wifi_analyzer_screen.dart';
import '../../features/web_scanner/web_scanner_screen.dart';
import '../../features/dns_osint/dns_osint_screen.dart';
import '../../features/exploitation/exploitation_screen.dart';
import '../../features/password_tools/password_tools_screen.dart';
import '../../features/ssh_terminal/ssh_terminal_screen.dart';
import '../../features/packet_capture/packet_capture_screen.dart';
import '../../features/browser_tunnel/browser_tunnel_screen.dart';
import '../../features/server_control/server_control_screen.dart';
import '../../features/settings/settings_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
      GoRoute(path: '/network-scanner', builder: (_, __) => const NetworkScannerScreen()),
      GoRoute(path: '/port-scanner', builder: (_, __) => const PortScannerScreen()),
      GoRoute(path: '/wifi-analyzer', builder: (_, __) => const WifiAnalyzerScreen()),
      GoRoute(path: '/web-scanner', builder: (_, __) => const WebScannerScreen()),
      GoRoute(path: '/dns-osint', builder: (_, __) => const DnsOsintScreen()),
      GoRoute(path: '/exploitation', builder: (_, __) => const ExploitationScreen()),
      GoRoute(path: '/password-tools', builder: (_, __) => const PasswordToolsScreen()),
      GoRoute(path: '/ssh-terminal', builder: (_, __) => const SshTerminalScreen()),
      GoRoute(path: '/packet-capture', builder: (_, __) => const PacketCaptureScreen()),
      GoRoute(
        path: '/browser-tunnel',
        builder: (_, state) => BrowserTunnelScreen(
          url: state.uri.queryParameters['url'] ?? '',
        ),
      ),
      GoRoute(path: '/server-control', builder: (_, __) => const ServerControlScreen()),
      GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
    ],
  );
});
