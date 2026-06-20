import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../core/theme/app_theme.dart';

class BrowserTunnelScreen extends StatefulWidget {
  final String url;
  const BrowserTunnelScreen({super.key, this.url = ''});

  @override
  State<BrowserTunnelScreen> createState() => _BrowserTunnelScreenState();
}

class _BrowserTunnelScreenState extends State<BrowserTunnelScreen> {
  final _urlCtrl = TextEditingController();
  InAppWebViewController? _webCtrl;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _urlCtrl.text = widget.url;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browser Tunnel'),
        actions: [
          IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: () => _webCtrl?.goBack()),
          IconButton(icon: const Icon(Icons.arrow_forward_ios), onPressed: () => _webCtrl?.goForward()),
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => _webCtrl?.reload()),
        ],
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: _urlCtrl,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: const InputDecoration(
                  hintText: 'http://192.168.1.100:8080',
                  prefixIcon: Icon(Icons.link, color: AppTheme.primary),
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
                onSubmitted: (url) => _webCtrl?.loadUrl(urlRequest: URLRequest(url: WebUri(url))),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => _webCtrl?.loadUrl(urlRequest: URLRequest(url: WebUri(_urlCtrl.text))),
              child: const Text('GO'),
            ),
          ]),
        ),
        if (_loading) const LinearProgressIndicator(color: AppTheme.primary),
        Expanded(
          child: _urlCtrl.text.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.open_in_browser, color: AppTheme.primary, size: 60),
                  const SizedBox(height: 16),
                  const Text('Enter server URL above', style: TextStyle(color: AppTheme.textSecondary)),
                  const SizedBox(height: 8),
                  const Text('e.g. http://192.168.1.100:8080', style: TextStyle(color: AppTheme.muted, fontSize: 12, fontFamily: 'monospace')),
                ]))
              : InAppWebView(
                  initialUrlRequest: URLRequest(url: WebUri(_urlCtrl.text)),
                  initialSettings: InAppWebViewSettings(
                    javaScriptEnabled: true,
                    allowFileAccess: true,
                    mediaPlaybackRequiresUserGesture: false,
                  ),
                  onWebViewCreated: (ctrl) => _webCtrl = ctrl,
                  onLoadStart: (_, __) => setState(() => _loading = true),
                  onLoadStop: (_, __) => setState(() => _loading = false),
                ),
        ),
      ]),
    );
  }
}
