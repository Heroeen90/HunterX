import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
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

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
      GoRoute(path: '/network', builder: (_, __) => const NetworkScannerScreen()),
      GoRoute(path: '/ports', builder: (_, __) => const PortScannerScreen()),
      GoRoute(path: '/wifi', builder: (_, __) => const WifiAnalyzerScreen()),
      GoRoute(path: '/web', builder: (_, __) => const WebScannerScreen()),
      GoRoute(path: '/dns', builder: (_, __) => const DnsOsintScreen()),
      GoRoute(path: '/exploit', builder: (_, __) => const ExploitationScreen()),
      GoRoute(path: '/passwords', builder: (_, __) => const PasswordToolsScreen()),
      GoRoute(
        path: '/terminal',
        builder: (_, state) {
          final host = state.uri.queryParameters['host'];
          final port = int.tryParse(state.uri.queryParameters['port'] ?? '22');
          return SshTerminalScreen(host: host, port: port ?? 22);
        },
      ),
      GoRoute(path: '/capture', builder: (_, __) => const PacketCaptureScreen()),
      GoRoute(path: '/browser', builder: (_, __) => const BrowserTunnelScreen()),
      GoRoute(path: '/server', builder: (_, __) => const ServerControlScreen()),
      GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
    ],
  );
}
