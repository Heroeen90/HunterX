import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class BrowserTunnelScreen extends StatefulWidget {
  const BrowserTunnelScreen({super.key});

  @override
  State<BrowserTunnelScreen> createState() => _BrowserTunnelScreenState();
}

class _BrowserTunnelScreenState extends State<BrowserTunnelScreen> {
  final _urlController = TextEditingController(text: 'http://');
  String? _loadedUrl;
  bool _useProxy = false;
  final _proxyController = TextEditingController(text: '127.0.0.1:8080');

  @override
  void dispose() {
    _urlController.dispose();
    _proxyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new), onPressed: () => context.go('/')),
        title: const Text('Browser Tunnel'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: AppTheme.surface,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _urlController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.language),
                          labelText: 'URL',
                          isDense: true,
                        ),
                        keyboardType: TextInputType.url,
                        onSubmitted: _navigate,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _navigate(_urlController.text),
                      child: const Text('Go'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Switch(value: _useProxy, onChanged: (v) => setState(() => _useProxy = v), activeColor: AppTheme.primary),
                    const Text('Proxy', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    if (_useProxy) ...[
                      const SizedBox(width: 8),
                      Expanded(child: TextField(controller: _proxyController, decoration: const InputDecoration(labelText: 'Proxy host:port', isDense: true))),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _loadedUrl == null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.public, size: 48, color: AppTheme.textSecondary),
                        const SizedBox(height: 12),
                        const Text('Enter a URL to browse', style: TextStyle(color: AppTheme.textSecondary)),
                        const SizedBox(height: 8),
                        Text(
                          _useProxy ? 'Traffic will route through ${_proxyController.text}' : 'Direct connection',
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  )
                : Container(
                    color: AppTheme.terminalBg,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.open_in_new, color: AppTheme.primary, size: 40),
                          const SizedBox(height: 12),
                          Text(_loadedUrl!, style: const TextStyle(color: AppTheme.primary, fontSize: 13)),
                          const SizedBox(height: 8),
                          const Text(
                            'WebView integration requires flutter_webview_plugin.\nAdd it to pubspec.yaml to enable embedded browsing.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _navigate(String url) {
    if (url.trim().isEmpty) return;
    setState(() => _loadedUrl = url.trim());
  }
}
