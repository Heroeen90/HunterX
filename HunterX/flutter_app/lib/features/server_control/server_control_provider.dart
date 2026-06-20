import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/services/api_service.dart';
import '../../shared/services/server_connection_service.dart';
import '../../core/constants/api_constants.dart';

class ServerControlState {
  final bool loading;
  final Map<String, dynamic>? systemInfo;
  final Map<String, bool> tools;
  final Map<String, dynamic>? networkInfo;
  final String? error;

  const ServerControlState({
    this.loading = false,
    this.systemInfo,
    this.tools = const {},
    this.networkInfo,
    this.error,
  });

  ServerControlState copyWith({
    bool? loading,
    Map<String, dynamic>? systemInfo,
    Map<String, bool>? tools,
    Map<String, dynamic>? networkInfo,
    String? error,
  }) =>
      ServerControlState(
        loading: loading ?? this.loading,
        systemInfo: systemInfo ?? this.systemInfo,
        tools: tools ?? this.tools,
        networkInfo: networkInfo ?? this.networkInfo,
        error: error,
      );
}

final serverControlProvider = StateNotifierProvider<ServerControlNotifier, ServerControlState>((ref) {
  return ServerControlNotifier(ref.read(apiServiceProvider));
});

class ServerControlNotifier extends StateNotifier<ServerControlState> {
  final ApiService _api;
  ServerControlNotifier(this._api) : super(const ServerControlState()) {
    refresh();
  }

  Future<void> refresh() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final results = await Future.wait([
        _api.get<Map<String, dynamic>>(ApiConstants.systemInfo),
        _api.get<Map<String, dynamic>>(ApiConstants.systemTools),
        _api.get<Map<String, dynamic>>(ApiConstants.systemNetwork),
      ]);
      state = state.copyWith(
        loading: false,
        systemInfo: results[0].data,
        tools: Map<String, bool>.from((results[1].data?['tools'] as Map?) ?? {}),
        networkInfo: results[2].data,
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }
}
