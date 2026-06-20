import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/server_status_widget.dart';
import '../../shared/services/server_connection_service.dart';

class _Tool {
  final String label;
  final String route;
  final IconData icon;
  final String description;
  final bool serverRequired;

  const _Tool({
    required this.label,
    required this.route,
    required this.icon,
    required this.description,
    this.serverRequired = false,
  });
}

const _tools = [
  _Tool(label: 'Network Scan', route: '/network', icon: Icons.radar, description: 'Discover hosts on LAN'),
  _Tool(label: 'Port Scanner', route: '/ports', icon: Icons.lan_outlined, description: 'Scan open ports'),
  _Tool(label: 'WiFi Analyzer', route: '/wifi', icon: Icons.wifi_find, description: 'Inspect nearby networks'),
  _Tool(label: 'Web Scanner', route: '/web', icon: Icons.language, description: 'Nikto web vuln scan', serverRequired: true),
  _Tool(label: 'DNS / OSINT', route: '/dns', icon: Icons.dns_outlined, description: 'DNS lookup & recon'),
  _Tool(label: 'Exploitation', route: '/exploit', icon: Icons.bug_report_outlined, description: 'Metasploit modules', serverRequired: true),
  _Tool(label: 'Password Tools', route: '/passwords', icon: Icons.lock_open_outlined, description: 'Hash cracking', serverRequired: true),
  _Tool(label: 'SSH Terminal', route: '/terminal', icon: Icons.terminal, description: 'Remote shell access'),
  _Tool(label: 'Packet Capture', route: '/capture', icon: Icons.network_check, description: 'tcpdump capture', serverRequired: true),
  _Tool(label: 'Browser Tunnel', route: '/browser', icon: Icons.public, description: 'Embedded web browser'),
  _Tool(label: 'Server Control', route: '/server', icon: Icons.dns, description: 'Manage HunterX server', serverRequired: true),
  _Tool(label: 'Settings', route: '/settings', icon: Icons.settings_outlined, description: 'Configure connection'),
];

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(serverConfigProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Text('Hunter', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
            Text('X', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700)),
          ],
        ),
        actions: const [
          ServerStatusWidget(),
          SizedBox(width: 12),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!config.isConnected)
            _buildOfflineBanner(context),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.1,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _tools.length,
              itemBuilder: (ctx, i) => _ToolCard(
                tool: _tools[i],
                index: i,
                serverConnected: config.isConnected,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineBanner(BuildContext context) => GestureDetector(
        onTap: () => context.go('/settings'),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: AppTheme.warning.withOpacity(0.15),
          child: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: AppTheme.warning, size: 16),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Not connected to HunterX server — some tools require a server. Tap to configure.',
                  style: TextStyle(color: AppTheme.warning, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      );
}

class _ToolCard extends StatelessWidget {
  final _Tool tool;
  final int index;
  final bool serverConnected;

  const _ToolCard({
    required this.tool,
    required this.index,
    required this.serverConnected,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = tool.serverRequired && !serverConnected;
    return Animate(
      effects: [
        FadeEffect(delay: Duration(milliseconds: 40 * index), duration: 300.ms),
        SlideEffect(
          begin: const Offset(0, 0.1),
          delay: Duration(milliseconds: 40 * index),
          duration: 300.ms,
        ),
      ],
      child: GestureDetector(
        onTap: disabled ? null : () => context.go(tool.route),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: disabled ? 0.4 : 1.0,
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: disabled ? null : () => context.go(tool.route),
                borderRadius: BorderRadius.circular(12),
                splashColor: AppTheme.primary.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(tool.icon, color: AppTheme.primary, size: 28),
                      const Spacer(),
                      Text(
                        tool.label,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tool.description,
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                      ),
                      if (tool.serverRequired)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Row(
                            children: [
                              Icon(
                                Icons.dns_outlined,
                                size: 10,
                                color: serverConnected ? AppTheme.primary : AppTheme.warning,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Server',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: serverConnected ? AppTheme.primary : AppTheme.warning,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
