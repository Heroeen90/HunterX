import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/services/server_connection_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _urlController;
  late TextEditingController _apiKeyController;
  bool _connecting = false;
  bool? _lastResult;

  @override
  void initState() {
    super.initState();
    final config = ref.read(serverConfigProvider);
    _urlController = TextEditingController(text: config.serverUrl);
    _apiKeyController = TextEditingController(text: config.apiKey ?? '');
  }

  @override
  void dispose() {
    _urlController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(serverConfigProvider);
    final notifier = ref.read(serverConfigProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new), onPressed: () => context.go('/')),
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('HunterX Server', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 4),
            const Text('Configure the backend server URL where HunterX is running.',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
            const SizedBox(height: 20),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'Server URL',
                hintText: 'http://192.168.1.100:5000/api',
                prefixIcon: Icon(Icons.dns_outlined),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _apiKeyController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'API Key (optional)',
                hintText: 'Set HUNTERX_API_KEY env var on server',
                prefixIcon: Icon(Icons.key),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _connecting ? null : () => _connect(notifier),
                    icon: _connecting
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                        : const Icon(Icons.link, size: 18),
                    label: Text(_connecting ? 'Connecting...' : 'Connect'),
                  ),
                ),
                if (config.isConnected) ...[
                  const SizedBox(width: 8),
                  OutlinedButton(onPressed: notifier.disconnect, child: const Text('Disconnect')),
                ],
              ],
            ),
            if (_lastResult != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (_lastResult! ? AppTheme.primary : AppTheme.accent).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _lastResult! ? AppTheme.primary : AppTheme.accent),
                ),
                child: Row(children: [
                  Icon(_lastResult! ? Icons.check_circle : Icons.error_outline,
                      color: _lastResult! ? AppTheme.primary : AppTheme.accent, size: 18),
                  const SizedBox(width: 8),
                  Text(_lastResult! ? 'Connected successfully!' : 'Connection failed — check URL and server.',
                      style: TextStyle(color: _lastResult! ? AppTheme.primary : AppTheme.accent)),
                ]),
              ),
            ],
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),
            const Text('Connection Info', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 8),
            _infoRow('Status', config.isConnected ? 'Connected' : 'Disconnected', config.isConnected ? AppTheme.primary : AppTheme.accent),
            _infoRow('Server URL', config.serverUrl, AppTheme.textPrimary),
            _infoRow('WebSocket', config.wsUrl, AppTheme.textSecondary),
            const SizedBox(height: 24),
            const Text('About', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 8),
            _infoRow('App', 'HunterX', AppTheme.textPrimary),
            _infoRow('Version', '1.0.0', AppTheme.textSecondary),
            _infoRow('Backend', 'Node.js + Express + WebSocket', AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }

  Future<void> _connect(ServerConfigNotifier notifier) async {
    setState(() { _connecting = true; _lastResult = null; });
    final ok = await notifier.connect(
      _urlController.text.trim(),
      apiKey: _apiKeyController.text.trim().isEmpty ? null : _apiKeyController.text.trim(),
    );
    if (mounted) setState(() { _connecting = false; _lastResult = ok; });
  }

  Widget _infoRow(String label, String value, Color valueColor) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(children: [
          SizedBox(width: 100, child: Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12))),
          Expanded(child: Text(value, style: TextStyle(color: valueColor, fontSize: 12))),
        ]),
      );
}
