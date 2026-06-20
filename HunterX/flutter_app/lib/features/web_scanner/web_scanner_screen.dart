import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/terminal_output_widget.dart';
import 'web_scanner_provider.dart';

class WebScannerScreen extends ConsumerStatefulWidget {
  const WebScannerScreen({super.key});

  @override
  ConsumerState<WebScannerScreen> createState() => _WebScannerScreenState();
}

class _WebScannerScreenState extends ConsumerState<WebScannerScreen> {
  final _targetController = TextEditingController();
  final _portController = TextEditingController(text: '80');
  bool _ssl = false;

  @override
  void dispose() {
    _targetController.dispose();
    _portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(webScanProvider);
    final notifier = ref.read(webScanProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new), onPressed: () => context.go('/')),
        title: const Text('Web Scanner (Nikto)'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.surface,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _targetController,
                        decoration: const InputDecoration(labelText: 'Target', hintText: 'example.com or IP'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _portController,
                        decoration: const InputDecoration(labelText: 'Port'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Switch(value: _ssl, onChanged: (v) => setState(() => _ssl = v), activeColor: AppTheme.primary),
                    const Text('SSL/HTTPS', style: TextStyle(color: AppTheme.textSecondary)),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: state.scanning
                          ? null
                          : () => notifier.scan(
                                _targetController.text.trim(),
                                port: int.tryParse(_portController.text) ?? 80,
                                ssl: _ssl,
                              ),
                      icon: const Icon(Icons.play_arrow, size: 18),
                      label: Text(state.scanning ? 'Scanning...' : 'Scan'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (state.scanning)
            const LinearProgressIndicator(color: AppTheme.primary, backgroundColor: AppTheme.border),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: TerminalOutputWidget(
                lines: state.output,
                showCursor: state.scanning,
                onClear: notifier.clear,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
