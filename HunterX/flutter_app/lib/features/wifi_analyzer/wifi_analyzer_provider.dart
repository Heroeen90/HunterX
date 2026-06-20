import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wifi_scan/wifi_scan.dart';

class WifiNetwork {
  final String ssid;
  final String bssid;
  final int level;
  final int frequency;
  final String? capabilities;

  const WifiNetwork({
    required this.ssid,
    required this.bssid,
    required this.level,
    required this.frequency,
    this.capabilities,
  });

  String get band => frequency >= 5000 ? '5 GHz' : '2.4 GHz';
  int get channel => frequency >= 5000
      ? ((frequency - 5000) ~/ 5)
      : ((frequency - 2407) ~/ 5);
  String get security {
    if (capabilities == null) return 'Unknown';
    if (capabilities!.contains('WPA3')) return 'WPA3';
    if (capabilities!.contains('WPA2')) return 'WPA2';
    if (capabilities!.contains('WPA')) return 'WPA';
    if (capabilities!.contains('WEP')) return 'WEP';
    return 'Open';
  }
}

class WifiAnalyzerState {
  final bool scanning;
  final List<WifiNetwork> networks;
  final String? error;
  final bool permissionGranted;

  const WifiAnalyzerState({
    this.scanning = false,
    this.networks = const [],
    this.error,
    this.permissionGranted = false,
  });

  WifiAnalyzerState copyWith({
    bool? scanning,
    List<WifiNetwork>? networks,
    String? error,
    bool? permissionGranted,
  }) =>
      WifiAnalyzerState(
        scanning: scanning ?? this.scanning,
        networks: networks ?? this.networks,
        error: error,
        permissionGranted: permissionGranted ?? this.permissionGranted,
      );
}

final wifiAnalyzerProvider =
    StateNotifierProvider<WifiAnalyzerNotifier, WifiAnalyzerState>((ref) {
  return WifiAnalyzerNotifier();
});

class WifiAnalyzerNotifier extends StateNotifier<WifiAnalyzerState> {
  WifiAnalyzerNotifier() : super(const WifiAnalyzerState());

  Future<void> scan() async {
    state = state.copyWith(scanning: true, error: null);
    try {
      final canScan = await WiFiScan.instance.canStartScan();
      if (canScan != CanStartScan.yes) {
        state = state.copyWith(
          scanning: false,
          error: 'Cannot start WiFi scan: $canScan. Ensure location permission is granted.',
        );
        return;
      }
      await WiFiScan.instance.startScan();
      final canGet = await WiFiScan.instance.canGetScannedResults();
      if (canGet != CanGetScannedResults.yes) {
        state = state.copyWith(scanning: false, error: 'Cannot read scan results');
        return;
      }
      final results = await WiFiScan.instance.getScannedResults();
      final networks = results
          .map((r) => WifiNetwork(
                ssid: r.ssid.isEmpty ? '<Hidden>' : r.ssid,
                bssid: r.bssid,
                level: r.level,
                frequency: r.frequency,
                capabilities: r.capabilities,
              ))
          .toList()
        ..sort((a, b) => b.level.compareTo(a.level));
      state = state.copyWith(scanning: false, networks: networks, permissionGranted: true);
    } catch (e) {
      state = state.copyWith(scanning: false, error: e.toString());
    }
  }
}
