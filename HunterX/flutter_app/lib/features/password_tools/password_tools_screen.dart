import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import 'password_tools_provider.dart';

class PasswordToolsScreen extends ConsumerStatefulWidget {
  const PasswordToolsScreen({super.key});

  @override
  ConsumerState<PasswordToolsScreen> createState() => _PasswordToolsScreenState();
}

class _PasswordToolsScreenState extends ConsumerState<PasswordToolsScreen> {
  final _hashController = TextEditingController();
  int _hashType = 0;
  int _attackMode = 0;
  final _maskController = TextEditingController(text: '?a?a?a?a?a?a?a?a');

  static const _hashTypes = {0: 'MD5', 100: 'SHA1', 1400: 'SHA256', 1800: 'SHA512crypt', 3200: 'bcrypt'};
  static const _attackModes = {0: 'Dictionary', 3: 'Brute-force (mask)'};

  @override
  void dispose() {
    _hashController.dispose();
    _maskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(passwordToolsProvider);
    final notifier = ref.read(passwordToolsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new), onPressed: () => context.go('/')),
        title: const Text('Password Tools'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(child: _modeChip('Identify', PasswordMode.identify, state, notifier)),
              const SizedBox(width: 8),
              Expanded(child: _modeChip('Crack (hashcat)', PasswordMode.crack, state, notifier)),
            ]),
            const SizedBox(height: 16),
            TextField(
              controller: _hashController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Hash', hintText: 'Paste your hash here'),
            ),
            if (state.mode == PasswordMode.crack) ...[
              const SizedBox(height: 12),
              const Text('Hash Type', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              DropdownButtonFormField<int>(
                value: _hashType,
                dropdownColor: AppTheme.surface,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: _hashTypes.entries.map((e) => DropdownMenuItem(value: e.key, child: Text('${e.key} - ${e.value}'))).toList(),
                onChanged: (v) => setState(() => _hashType = v!),
              ),
              const SizedBox(height: 12),
              const Text('Attack Mode', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              DropdownButtonFormField<int>(
                value: _attackMode,
                dropdownColor: AppTheme.surface,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: _attackModes.entries.map((e) => DropdownMenuItem(value: e.key, child: Text('${e.key} - ${e.value}'))).toList(),
                onChanged: (v) => setState(() => _attackMode = v!),
              ),
              if (_attackMode == 3) ...[
                const SizedBox(height: 12),
                TextField(controller: _maskController, decoration: const InputDecoration(labelText: 'Mask', hintText: '?a?a?a?a?a?a?a?a')),
              ],
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: state.loading ? null : () => _run(state, notifier),
                icon: Icon(state.mode == PasswordMode.identify ? Icons.search : Icons.lock_open, size: 18),
                label: Text(state.loading ? 'Running...' : (state.mode == PasswordMode.identify ? 'Identify' : 'Crack')),
              ),
            ),
            if (state.loading) ...[
              const SizedBox(height: 12),
              const LinearProgressIndicator(color: AppTheme.primary, backgroundColor: AppTheme.border),
            ],
            if (state.cracked != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.primary),
                ),
                child: Row(children: [
                  const Icon(Icons.check_circle, color: AppTheme.primary),
                  const SizedBox(width: 12),
                  Expanded(child: SelectableText('Cracked: ${state.cracked}', style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700))),
                ]),
              ),
            ],
            if (state.result != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppTheme.terminalBg, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppTheme.border)),
                child: SelectableText(state.result!, style: const TextStyle(color: AppTheme.terminalGreen, fontFamily: 'monospace', fontSize: 12, height: 1.5)),
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

  Widget _modeChip(String label, PasswordMode mode, PasswordToolsState state, PasswordToolsNotifier notifier) {
    final selected = state.mode == mode;
    return GestureDetector(
      onTap: () => notifier.setMode(mode),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary.withOpacity(0.15) : AppTheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? AppTheme.primary : AppTheme.border),
        ),
        child: Center(child: Text(label, style: TextStyle(color: selected ? AppTheme.primary : AppTheme.textSecondary, fontWeight: FontWeight.w600))),
      ),
    );
  }

  void _run(PasswordToolsState state, PasswordToolsNotifier notifier) {
    final hash = _hashController.text.trim();
    if (hash.isEmpty) return;
    if (state.mode == PasswordMode.identify) {
      notifier.identify(hash);
    } else {
      notifier.crack(hash, hashType: _hashType, attackMode: _attackMode, mask: _attackMode == 3 ? _maskController.text.trim() : null);
    }
  }
}
