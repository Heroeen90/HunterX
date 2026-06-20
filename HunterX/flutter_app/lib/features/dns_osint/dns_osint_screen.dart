import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import 'dns_osint_provider.dart';

class DnsOsintScreen extends ConsumerStatefulWidget {
  const DnsOsintScreen({super.key});

  @override
  ConsumerState<DnsOsintScreen> createState() => _DnsOsintScreenState();
}

class _DnsOsintScreenState extends ConsumerState<DnsOsintScreen> {
  final _targetController = TextEditingController();
  String _recordType = 'A';

  @override
  void dispose() {
    _targetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dnsOsintProvider);
    final notifier = ref.read(dnsOsintProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new), onPressed: () => context.go('/')),
        title: const Text('DNS / OSINT'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: DnsQueryType.values.map((t) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(_typeName(t)),
                        selected: state.queryType == t,
                        onSelected: (_) => notifier.setQueryType(t),
                        selectedColor: AppTheme.primary.withOpacity(0.2),
                        labelStyle: TextStyle(
                          color: state.queryType == t ? AppTheme.primary : AppTheme.textSecondary,
                        ),
                      ),
                    )).toList(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _targetController,
                        decoration: InputDecoration(
                          labelText: state.queryType == DnsQueryType.reverse ? 'IP Address' : 'Domain',
                          hintText: state.queryType == DnsQueryType.reverse ? '8.8.8.8' : 'example.com',
                        ),
                      ),
                    ),
                    if (state.queryType == DnsQueryType.lookup) ...[
                      const SizedBox(width: 8),
                      DropdownButton<String>(
                        value: _recordType,
                        dropdownColor: AppTheme.surface,
                        style: const TextStyle(color: AppTheme.textPrimary),
                        items: ['A', 'AAAA', 'MX', 'NS', 'TXT', 'CNAME', 'SOA']
                            .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                            .toList(),
                        onChanged: (v) => setState(() => _recordType = v!),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: state.loading ? null : () => _run(state.queryType, notifier),
                  icon: const Icon(Icons.search, size: 18),
                  label: Text(state.loading ? 'Running...' : 'Run Query'),
                ),
              ],
            ),
          ),
          if (state.loading)
            const LinearProgressIndicator(color: AppTheme.primary, backgroundColor: AppTheme.border),
          if (state.error != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(state.error!, style: const TextStyle(color: AppTheme.accent)),
            ),
          if (state.result != null)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.terminalBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: SelectableText(
                    state.result!,
                    style: const TextStyle(
                      color: AppTheme.terminalGreen,
                      fontFamily: 'monospace',
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _run(DnsQueryType type, DnsOsintNotifier notifier) {
    final t = _targetController.text.trim();
    if (t.isEmpty) return;
    switch (type) {
      case DnsQueryType.lookup: notifier.lookup(t, recordType: _recordType);
      case DnsQueryType.whois: notifier.whois(t);
      case DnsQueryType.subfinder: notifier.subfinder(t);
      case DnsQueryType.reverse: notifier.reverseLookup(t);
    }
  }

  String _typeName(DnsQueryType t) => switch (t) {
        DnsQueryType.lookup => 'DNS Lookup',
        DnsQueryType.whois => 'WHOIS',
        DnsQueryType.subfinder => 'Subfinder',
        DnsQueryType.reverse => 'Reverse',
      };
}
