import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import 'port_scanner_provider.dart';

class PortScannerScreen extends ConsumerStatefulWidget {
  const PortScannerScreen({super.key});

  @override
  ConsumerState<PortScannerScreen> createState() => _PortScannerScreenState();
}

class _PortScannerScreenState extends ConsumerState<PortScannerScreen> {
  final _hostController = TextEditingController();

  @override
  void dispose() {
    _hostController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(portScanProvider);
    final notifier = ref.read(portScanProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new), onPressed: () => context.go('/')),
        title: const Text('Port Scanner'),
      ),
      body: Column(
        children: [
          _buildInput(state, notifier),
          if (state.scanning)
            const LinearProgressIndicator(color: AppTheme.primary, backgroundColor: AppTheme.border),
          if (state.openPorts.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: AppTheme.primary, size: 16),
                  const SizedBox(width: 6),
                  Text('${state.openPorts.length} open ports on ${state.host}',
                      style: const TextStyle(color: AppTheme.primary, fontSize: 13)),
                ],
              ),
            ),
          Expanded(child: _buildResults(state)),
        ],
      ),
    );
  }

  Widget _buildInput(PortScanState state, PortScanNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppTheme.surface,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _hostController,
              decoration: const InputDecoration(
                labelText: 'Target host or IP',
                hintText: '192.168.1.1',
                prefixIcon: Icon(Icons.lan_outlined),
              ),
              keyboardType: TextInputType.url,
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: state.scanning
                ? null
                : () => notifier.scan(_hostController.text.trim()),
            child: Text(state.scanning ? '...' : 'Scan'),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(PortScanState state) {
    if (state.results.isEmpty) {
      return const Center(
        child: Text('Enter a target and press Scan', style: TextStyle(color: AppTheme.textSecondary)),
      );
    }
    final open = state.openPorts;
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: open.length,
      itemBuilder: (_, i) {
        final r = open[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 6),
          child: ListTile(
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(r.port.toString(),
                    style: const TextStyle(color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.w700)),
              ),
            ),
            title: Text(_portName(r.port)),
            subtitle: r.banner != null ? Text(r.banner!, maxLines: 1, overflow: TextOverflow.ellipsis) : null,
            trailing: const Chip(
              label: Text('OPEN', style: TextStyle(color: AppTheme.primary, fontSize: 10)),
              backgroundColor: Color(0x1100FF88),
              side: BorderSide.none,
            ),
          ),
        );
      },
    );
  }

  String _portName(int port) {
    const names = {
      21: 'FTP', 22: 'SSH', 23: 'Telnet', 25: 'SMTP', 53: 'DNS',
      80: 'HTTP', 110: 'POP3', 143: 'IMAP', 443: 'HTTPS', 445: 'SMB',
      3306: 'MySQL', 3389: 'RDP', 5432: 'PostgreSQL', 6379: 'Redis',
      8080: 'HTTP-Alt', 8443: 'HTTPS-Alt', 9200: 'Elasticsearch', 27017: 'MongoDB',
    };
    return names[port] ?? 'Port $port';
  }
}
