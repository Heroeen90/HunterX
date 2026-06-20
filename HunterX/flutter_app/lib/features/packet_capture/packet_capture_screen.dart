import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/services/server_connection_service.dart';
import 'packet_capture_provider.dart';

class PacketCaptureScreen extends ConsumerStatefulWidget {
  const PacketCaptureScreen({super.key});

  @override
  ConsumerState<PacketCaptureScreen> createState() => _PacketCaptureScreenState();
}

class _PacketCaptureScreenState extends ConsumerState<PacketCaptureScreen> {
  String? _selectedIface;
  final _filterController = TextEditingController();

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(packetCaptureProvider);
    final notifier = ref.read(packetCaptureProvider.notifier);
    final config = ref.watch(serverConfigProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new), onPressed: () => context.go('/')),
        title: const Text('Packet Capture'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(state),
            const SizedBox(height: 16),
            if (!state.active) ...[
              const Text('Network Interface', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              const SizedBox(height: 8),
              if (state.interfaces.isEmpty)
                const Text('No interfaces found — connect to server', style: TextStyle(color: AppTheme.textSecondary))
              else
                DropdownButtonFormField<String>(
                  value: _selectedIface ?? state.interfaces.first,
                  dropdownColor: AppTheme.surface,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  items: state.interfaces.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
                  onChanged: (v) => setState(() => _selectedIface = v),
                ),
              const SizedBox(height: 12),
              TextField(
                controller: _filterController,
                decoration: const InputDecoration(
                  labelText: 'BPF Filter (optional)',
                  hintText: 'tcp port 80, udp, host 192.168.1.1',
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => notifier.startCapture(
                    iface: _selectedIface ?? (state.interfaces.isNotEmpty ? state.interfaces.first : 'eth0'),
                    filter: _filterController.text.trim().isEmpty ? null : _filterController.text.trim(),
                  ),
                  icon: const Icon(Icons.fiber_manual_record, color: AppTheme.accent, size: 16),
                  label: const Text('Start Capture'),
                ),
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accent, foregroundColor: Colors.white),
                  onPressed: notifier.stopCapture,
                  icon: const Icon(Icons.stop, size: 18),
                  label: const Text('Stop Capture'),
                ),
              ),
              if (state.capturePath != null) ...[
                const SizedBox(height: 12),
                Text('Saving to: ${state.capturePath}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              ],
            ],
            if (state.capturePath != null && !state.active) ...[
              const SizedBox(height: 24),
              Text('Capture saved: ${state.capturePath}', style: const TextStyle(color: AppTheme.primary, fontSize: 13)),
              const SizedBox(height: 8),
              Text(
                'Download URL: ${notifier.downloadUrl(config.serverUrl)}',
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              ),
            ],
            if (state.error != null) ...[
              const SizedBox(height: 12),
              Text(state.error!, style: const TextStyle(color: AppTheme.accent)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(CaptureState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: state.active ? AppTheme.accent.withOpacity(0.5) : AppTheme.border),
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: state.active ? AppTheme.accent : AppTheme.textSecondary,
              boxShadow: state.active
                  ? [BoxShadow(color: AppTheme.accent.withOpacity(0.6), blurRadius: 8)]
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            state.active ? 'Capturing packets...' : 'Idle',
            style: TextStyle(
              color: state.active ? AppTheme.accent : AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (state.sessionId != null) ...[
            const Spacer(),
            Text('ID: ${state.sessionId}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
          ],
        ],
      ),
    );
  }
}
