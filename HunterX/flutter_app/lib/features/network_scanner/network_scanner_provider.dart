import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/services/ondevice_scanner.dart';
import '../../shared/services/api_service.dart';
import '../../shared/services/server_connection_service.dart';
import '../../core/constants/api_constants.dart';

enum ScanMode { onDevice, server }

class NetworkScanState {
  final bool scanning;
  final List<HostResult> hosts;
  final String? error;
  final String? localIp;
  final String? subnet;
  final ScanMode mode;

  const NetworkScanState({
    this.scanning = false,
    this.hosts = const [],
    this.error,
    this.localIp,
    this.subnet,
    this.mode = ScanMode.onDevice,
  });

  NetworkScanState copyWith({
    bool? scanning,
    List<HostResult>? hosts,
    String? error,
    String? localIp,
    String? subnet,
    ScanMode? mode,
  }) =>
      NetworkScanState(
        scanning: scanning ?? this.scanning,
        hosts: hosts ?? this.hosts,
        error: error,
        localIp: localIp ?? this.localIp,
        subnet: subnet ?? this.subnet,
        mode: mode ?? this.mode,
      );
}

final networkScanProvider =
    StateNotifierProvider<NetworkScanNotifier, NetworkScanState>((ref) {
  return NetworkScanNotifier(
    ref.read(onDeviceScannerProvider),
    ref.read(apiServiceProvider),
    ref.read(serverConfigProvider),
  );
});

class NetworkScanNotifier extends StateNotifier<NetworkScanState> {
  final OnDeviceScanner _scanner;
  final ApiService _api;
  final ServerConfig _serverConfig;

  NetworkScanNotifier(this._scanner, this._api, this._serverConfig)
      : super(const NetworkScanState()) {
    _init();
  }

  Future<void> _init() async {
    final ip = await _scanner.getLocalIp();
    if (ip != null) {
      final parts = ip.split('.');
      final subnet =
          parts.length >= 3 ? '${parts[0]}.${parts[1]}.${parts[2]}.0/24' : null;
      state = state.copyWith(localIp: ip, subnet: subnet);
    }
  }

  Future<void> scanOnDevice() async {
    if (state.scanning) return;
    final subnet = state.subnet;
    if (subnet == null) {
      state = state.copyWith(error: 'Could not determine local subnet');
      return;
    }
    state = state.copyWith(scanning: true, hosts: [], error: null, mode: ScanMode.onDevice);
    final found = <HostResult>[];
    await _scanner.pingSubnet(
      subnet,
      onFound: (h) {
        found.add(h);
        state = state.copyWith(hosts: List.from(found));
      },
    );
    state = state.copyWith(scanning: false, hosts: found);
  }

  Future<void> scanWithServer(String target, {String flags = '-sV -T4'}) async {
    if (state.scanning) return;
    state = state.copyWith(scanning: true, hosts: [], error: null, mode: ScanMode.server);
    try {
      final res = await _api.post<Map<String, dynamic>>(
        ApiConstants.nmapScan,
        data: {'target': target, 'flags': flags},
        timeout: ApiConstants.longTimeout,
      );
      final stdout = res.data?['stdout'] as String? ?? '';
      final hosts = _parseNmapOutput(stdout);
      state = state.copyWith(scanning: false, hosts: hosts);
    } catch (e) {
      state = state.copyWith(scanning: false, error: e.toString());
    }
  }

  List<HostResult> _parseNmapOutput(String output) {
    final results = <HostResult>[];
    final lines = output.split('\n');
    for (final line in lines) {
      final m = RegExp(r'Nmap scan report for (.+)').firstMatch(line);
      if (m != null) {
        results.add(HostResult(ip: m.group(1)!.trim(), responseMs: 0));
      }
    }
    return results;
  }
}
