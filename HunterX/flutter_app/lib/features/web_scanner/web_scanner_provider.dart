import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/services/api_service.dart';
import '../../core/constants/api_constants.dart';
import '../../shared/widgets/terminal_output_widget.dart';

class WebScanState {
  final bool scanning;
  final List<TerminalLine> output;
  final String? error;

  const WebScanState({
    this.scanning = false,
    this.output = const [],
    this.error,
  });

  WebScanState copyWith({bool? scanning, List<TerminalLine>? output, String? error}) =>
      WebScanState(
        scanning: scanning ?? this.scanning,
        output: output ?? this.output,
        error: error,
      );
}

final webScanProvider = StateNotifierProvider<WebScanNotifier, WebScanState>((ref) {
  return WebScanNotifier(ref.read(apiServiceProvider));
});

class WebScanNotifier extends StateNotifier<WebScanState> {
  final ApiService _api;
  WebScanNotifier(this._api) : super(const WebScanState());

  Future<void> scan(String target, {int port = 80, bool ssl = false}) async {
    if (state.scanning) return;
    state = state.copyWith(scanning: true, output: [
      TerminalLine.info('Starting Nikto scan on $target:$port ${ssl ? "[SSL]" : ""}...'),
    ]);
    try {
      final res = await _api.post<Map<String, dynamic>>(
        ApiConstants.niktoScan,
        data: {'target': target, 'port': port, 'ssl': ssl},
        timeout: const Duration(minutes: 5),
      );
      final raw = res.data?['output'] as String? ?? '';
      final lines = raw.split('\n').where((l) => l.trim().isNotEmpty).map((l) {
        if (l.contains('+ ')) return TerminalLine.stdout(l);
        if (l.startsWith('-')) return TerminalLine.stderr(l);
        return TerminalLine.system(l);
      }).toList();
      state = state.copyWith(scanning: false, output: [
        ...state.output,
        ...lines,
        TerminalLine.info('Scan complete. Exit: ${res.data?["exitCode"]}'),
      ]);
    } catch (e) {
      state = state.copyWith(
        scanning: false,
        output: [...state.output, TerminalLine.stderr('Error: $e')],
        error: e.toString(),
      );
    }
  }

  void clear() => state = state.copyWith(output: []);
}
