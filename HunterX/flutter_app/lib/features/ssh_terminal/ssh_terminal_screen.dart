import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:xterm/xterm.dart';
import '../../core/theme/app_theme.dart';
import 'ssh_terminal_provider.dart';

class SshTerminalScreen extends ConsumerStatefulWidget {
  final String? host;
  final int port;

  const SshTerminalScreen({super.key, this.host, this.port = 22});

  @override
  ConsumerState<SshTerminalScreen> createState() => _SshTerminalScreenState();
}

class _SshTerminalScreenState extends ConsumerState<SshTerminalScreen> {
  final _hostController = TextEditingController();
  final _portController = TextEditingController();
  final _usernameController = TextEditingController(text: 'root');
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _hostController.text = widget.host ?? '';
    _portController.text = widget.port.toString();
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sshStateProvider);
    final notifier = ref.read(sshStateProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new), onPressed: () => context.go('/')),
        title: Text(state.connected ? 'SSH: ${_hostController.text}' : 'SSH Terminal'),
        actions: [
          if (state.connected)
            IconButton(
              icon: const Icon(Icons.power_settings_new, color: AppTheme.accent),
              onPressed: notifier.disconnect,
              tooltip: 'Disconnect',
            ),
        ],
      ),
      body: state.connected
          ? _buildTerminal(notifier)
          : _buildConnectForm(state, notifier),
    );
  }

  Widget _buildConnectForm(SshState state, SshNotifier notifier) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('SSH Connection', style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(flex: 3, child: TextField(controller: _hostController, decoration: const InputDecoration(labelText: 'Host', hintText: '192.168.1.1'))),
            const SizedBox(width: 8),
            Expanded(child: TextField(controller: _portController, decoration: const InputDecoration(labelText: 'Port'), keyboardType: TextInputType.number)),
          ]),
          const SizedBox(height: 12),
          TextField(controller: _usernameController, decoration: const InputDecoration(labelText: 'Username')),
          const SizedBox(height: 12),
          TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
          const SizedBox(height: 24),
          if (state.error != null) ...[
            Text(state.error!, style: const TextStyle(color: AppTheme.accent)),
            const SizedBox(height: 12),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: state.connecting ? null : () => notifier.connect(
                host: _hostController.text.trim(),
                port: int.tryParse(_portController.text) ?? 22,
                username: _usernameController.text.trim(),
                password: _passwordController.text,
              ),
              icon: state.connecting
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                  : const Icon(Icons.terminal, size: 18),
              label: Text(state.connecting ? 'Connecting...' : 'Connect'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTerminal(SshNotifier notifier) {
    return TerminalView(
      notifier.terminal,
      theme: const TerminalTheme(
        cursor: AppTheme.terminalGreen,
        selection: Color(0x4400FF88),
        foreground: AppTheme.textPrimary,
        background: AppTheme.terminalBg,
        black: Color(0xFF000000),
        red: AppTheme.accent,
        green: AppTheme.terminalGreen,
        yellow: AppTheme.warning,
        blue: AppTheme.secondary,
        magenta: Color(0xFFBD93F9),
        cyan: Color(0xFF8BE9FD),
        white: AppTheme.textPrimary,
        brightBlack: Color(0xFF6272A4),
        brightRed: Color(0xFFFF6E6E),
        brightGreen: Color(0xFF69FF94),
        brightYellow: Color(0xFFFFFF87),
        brightBlue: Color(0xFFD6ACFF),
        brightMagenta: Color(0xFFFF92DF),
        brightCyan: Color(0xFFA4FFFF),
        brightWhite: Colors.white,
        searchHitBackground: Color(0xFFFFFF00),
        searchHitBackgroundCurrent: Color(0xFFFF8800),
        searchHitForeground: Colors.black,
      ),
    );
  }
}
