import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import 'server_control_provider.dart';

class ServerControlScreen extends ConsumerWidget {
  const ServerControlScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(serverControlProvider);
    final notifier = ref.read(serverControlProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new), onPressed: () => context.go('/')),
        title: const Text('Server Control'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: state.loading ? null : notifier.refresh,
          ),
        ],
      ),
      body: state.loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : state.error != null
              ? Center(child: Text(state.error!, style: const TextStyle(color: AppTheme.accent)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (state.systemInfo != null) _buildSystemCard(state.systemInfo!),
                      const SizedBox(height: 16),
                      _buildToolsCard(state.tools),
                      if (state.networkInfo != null) ...[
                        const SizedBox(height: 16),
                        _buildNetworkCard(state.networkInfo!),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _buildSystemCard(Map<String, dynamic> info) {
    final freeMb = ((info['freeMem'] as num? ?? 0) / 1024 / 1024).toStringAsFixed(0);
    final totalMb = ((info['totalMem'] as num? ?? 0) / 1024 / 1024).toStringAsFixed(0);
    return _card('System Info', [
      _row('Hostname', info['hostname']?.toString() ?? '-'),
      _row('Platform', '${info['platform']} (${info['arch']})'),
      _row('Kernel', info['release']?.toString() ?? '-'),
      _row('Uptime', _formatUptime((info['uptime'] as num? ?? 0).toInt())),
      _row('CPU Cores', info['cpus']?.toString() ?? '-'),
      _row('Memory', '$freeMb MB free / $totalMb MB'),
    ]);
  }

  Widget _buildToolsCard(Map<String, bool> tools) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Installed Tools', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tools.entries.map((e) => Chip(
                avatar: Icon(e.value ? Icons.check : Icons.close, size: 14, color: e.value ? AppTheme.primary : AppTheme.accent),
                label: Text(e.key, style: TextStyle(fontSize: 12, color: e.value ? AppTheme.textPrimary : AppTheme.textSecondary)),
                backgroundColor: AppTheme.surfaceVariant,
                side: BorderSide(color: e.value ? AppTheme.primary.withOpacity(0.3) : AppTheme.border),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkCard(Map<String, dynamic> info) {
    final ifaces = info['interfaces'] as Map<String, dynamic>? ?? {};
    return _card('Network Interfaces', [
      for (final entry in ifaces.entries)
        for (final addr in (entry.value as List? ?? []))
          _row(entry.key, (addr as Map)['address']?.toString() ?? '-'),
    ]);
  }

  Widget _card(String title, List<Widget> rows) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 12),
              ...rows,
            ],
          ),
        ),
      );

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            SizedBox(width: 110, child: Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13))),
            Expanded(child: Text(value, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13))),
          ],
        ),
      );

  String _formatUptime(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    return '${h}h ${m}m';
  }
}
