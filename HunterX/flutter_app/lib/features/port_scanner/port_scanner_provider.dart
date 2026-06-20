import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/services/ondevice_scanner.dart';

class PortScanState {
  final bool scanning;
  final String? host;
  final List<PortResult> results;
  final String? error;

  const PortScanState({
    this.scanning = false,
    this.host,
    this.results = const [],
    this.error,
  });

  PortScanState copyWith({
    bool? scanning,
    String? host,
    List<PortResult>? results,
    String? error,
  }) =>
      PortScanState(
        scanning: scanning ?? this.scanning,
        host: host ?? this.host,
        results: results ?? this.results,
        error: error,
      );

  List<PortResult> get openPorts => results.where((r) => r.open).toList();
}

final portScanProvider =
    StateNotifierProvider<PortScanNotifier, PortScanState>((ref) {
  return PortScanNotifier(ref.read(onDeviceScannerProvider));
});

class PortScanNotifier extends StateNotifier<PortScanState> {
  final OnDeviceScanner _scanner;

  PortScanNotifier(this._scanner) : super(const PortScanState());

  Future<void> scan(String host, {List<int>? customPorts}) async {
    if (state.scanning) return;
    state = state.copyWith(scanning: true, host: host, results: [], error: null);
    final results = <PortResult>[];
    await for (final result in _scanner.scanPorts(host, ports: customPorts)) {
      results.add(result);
      state = state.copyWith(results: List.from(results));
    }
    state = state.copyWith(scanning: false, results: results);
  }
}
