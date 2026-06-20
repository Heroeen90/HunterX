import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/server_status_widget.dart';
import 'network_scanner_provider.dart';

class NetworkScannerScreen extends ConsumerWidget {
  const NetworkScannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(networkScanProvider);
    final notifier = ref.read(networkScanProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.go('/'),
        ),
        title: const Text('Network Scanner'),
        actions: const [ServerStatusWidget(), SizedBox(width: 12)],
      ),
      body: Column(
        children: [
          _buildHeader(state, notifier),
          if (state.error != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(state.error!, style: const TextStyle(color: AppTheme.accent)),
            ),
          Expanded(child: _buildHostList(state)),
        ],
      ),
    );
  }

  Widget _buildHeader(NetworkScanState state, NetworkScanNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.localIp != null)
            Text('Local IP: ${state.localIp}  •  Subnet: ${state.subnet ?? "unknown"}',
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: state.scanning ? null : notifier.scanOnDevice,
                  icon: const Icon(Icons.radar, size: 18),
                  label: Text(state.scanning && state.mode == ScanMode.onDevice
                      ? 'Scanning...'
                      : 'On-Device Scan'),
                ),
              ),
            ],
          ),
          if (state.scanning)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: LinearProgressIndicator(
                color: AppTheme.primary,
                backgroundColor: AppTheme.border,
              ),
            ),
          if (state.hosts.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text('Found ${state.hosts.length} hosts',
                  style: const TextStyle(color: AppTheme.primary, fontSize: 12)),
            ),
        ],
      ),
    );
  }

  Widget _buildHostList(NetworkScanState state) {
    if (state.hosts.isEmpty && !state.scanning) {
      return const Center(
        child: Text('No hosts found yet. Start a scan.',
            style: TextStyle(color: AppTheme.textSecondary)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: state.hosts.length,
      itemBuilder: (ctx, i) {
        final host = state.hosts[i];
        return Animate(
          effects: [FadeEffect(duration: 200.ms)],
          child: Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: const Icon(Icons.computer, color: AppTheme.primary),
              title: Text(host.ip),
              subtitle: host.hostname != null ? Text(host.hostname!) : null,
              trailing: Text('${host.responseMs}ms',
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              onTap: () => context.go('/ports?host=${host.ip}'),
            ),
          ),
        );
      },
    );
  }
}
