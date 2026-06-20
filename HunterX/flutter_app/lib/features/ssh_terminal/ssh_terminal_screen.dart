import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/terminal_output_widget.dart';
import 'ssh_terminal_provider.dart';

class SshTerminalScreen extends ConsumerStatefulWidget {
  const SshTerminalScreen({super.key});
  @override
  ConsumerState<SshTerminalScreen> createState() => _SshTerminalScreenState();
}

class _SshTerminalScreenState extends ConsumerState<SshTerminalScreen> {
  final _hostCtrl = TextEditingController();
  final _portCtrl = TextEditingController(text: '22');
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _cmdCtrl = TextEditingController();
  final List<String> _output = [];

  void _addOutput(String text) {
    if (mounted) setState(() => _output.add(text));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final state = ref.watch(sshProvider);
    final notifier = ref.read(sshProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.sshTerminal),
        actions: [
          if (state.isConnected)
            IconButton(
              icon: const Icon(Icons.close, color: AppTheme.error),
              onPressed: () => notifier.disconnect(),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          if (!state.isConnected) ...[
            Row(children: [
              Expanded(flex: 3, child: TextField(
                controller: _hostCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(labelText: l.host),
              )),
              const SizedBox(width: 8),
              Expanded(child: TextField(
                controller: _portCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(labelText: l.port),
              )),
            ]),
            const SizedBox(height: 8),
            TextField(
              controller: _userCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(labelText: l.username),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _passCtrl,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(labelText: l.password),
            ),
            const SizedBox(height: 12),
            if (state.error != null)
              Text(state.error!, style: const TextStyle(color: AppTheme.error, fontSize: 12)),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: state.isConnecting ? null : () {
                  notifier.connect(
                    host: _hostCtrl.text.trim(),
                    port: int.tryParse(_portCtrl.text) ?? 22,
                    username: _userCtrl.text.trim(),
                    password: _passCtrl.text,
                    onOutput: _addOutput,
                  );
                },
                icon: state.isConnecting
                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                    : const Icon(Icons.computer),
                label: Text(state.isConnecting ? l.connecting : l.connect),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Expanded(child: TerminalOutputWidget(lines: _output, height: double.infinity)),
          if (state.isConnected) ...[
            const SizedBox(height: 8),
            Row(children: [
              const Text('\$ ', style: TextStyle(color: AppTheme.primary, fontFamily: 'monospace')),
              Expanded(child: TextField(
                controller: _cmdCtrl,
                style: const TextStyle(color: AppTheme.primary, fontFamily: 'monospace'),
                decoration: InputDecoration(hintText: l.typeCommand, hintStyle: const TextStyle(color: AppTheme.muted)),
                onSubmitted: (cmd) {
                  notifier.sendCommand(cmd);
                  _cmdCtrl.clear();
                },
              )),
              IconButton(
                icon: const Icon(Icons.send, color: AppTheme.primary),
                onPressed: () {
                  notifier.sendCommand(_cmdCtrl.text);
                  _cmdCtrl.clear();
                },
              ),
            ]),
          ],
        ]),
      ),
    );
  }
}
