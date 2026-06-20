import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../shared/services/api_service.dart';
import '../../core/constants/api_constants.dart';

class CaptureState {
  final bool active;
  final String? sessionId;
  final String? capturePath;
  final List<String> interfaces;
  final String? error;

  const CaptureState({
    this.active = false,
    this.sessionId,
    this.capturePath,
    this.interfaces = const [],
    this.error,
  });

  CaptureState copyWith({
    bool? active,
    String? sessionId,
    String? capturePath,
    List<String>? interfaces,
    String? error,
  }) =>
      CaptureState(
        active: active ?? this.active,
        sessionId: sessionId ?? this.sessionId,
        capturePath: capturePath ?? this.capturePath,
        interfaces: interfaces ?? this.interfaces,
        error: error,
      );
}

final packetCaptureProvider = StateNotifierProvider<PacketCaptureNotifier, CaptureState>((ref) {
  return PacketCaptureNotifier(ref.read(apiServiceProvider));
});

class PacketCaptureNotifier extends StateNotifier<CaptureState> {
  final ApiService _api;
  final _uuid = const Uuid();

  PacketCaptureNotifier(this._api) : super(const CaptureState()) {
    _loadInterfaces();
  }

  Future<void> _loadInterfaces() async {
    try {
      final res = await _api.get<Map<String, dynamic>>(ApiConstants.captureInterfaces);
      final ifaces = (res.data?['interfaces'] as List? ?? []).cast<String>();
      state = state.copyWith(interfaces: ifaces);
    } catch (_) {}
  }

  Future<void> startCapture({String iface = 'eth0', String? filter}) async {
    if (state.active) return;
    final id = _uuid.v4().substring(0, 8);
    try {
      final res = await _api.post<Map<String, dynamic>>(
        ApiConstants.captureStart,
        data: {'id': id, 'iface': iface, if (filter != null) 'filter': filter},
      );
      state = state.copyWith(
        active: true,
        sessionId: id,
        capturePath: res.data?['outFile'] as String?,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> stopCapture() async {
    if (!state.active || state.sessionId == null) return;
    try {
      final res = await _api.post<Map<String, dynamic>>(
        ApiConstants.captureStop,
        data: {'id': state.sessionId},
      );
      state = state.copyWith(
        active: false,
        capturePath: state.capturePath,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(active: false, error: e.toString());
    }
  }

  String downloadUrl(String baseUrl) =>
      '${baseUrl}${ApiConstants.captureDownload}/${state.sessionId}';
}
