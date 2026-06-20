import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/services/api_service.dart';
import '../../core/constants/api_constants.dart';

enum PasswordMode { crack, identify }

class PasswordToolsState {
  final bool loading;
  final PasswordMode mode;
  final String? result;
  final String? cracked;
  final String? error;

  const PasswordToolsState({
    this.loading = false,
    this.mode = PasswordMode.identify,
    this.result,
    this.cracked,
    this.error,
  });

  PasswordToolsState copyWith({
    bool? loading,
    PasswordMode? mode,
    String? result,
    String? cracked,
    String? error,
  }) =>
      PasswordToolsState(
        loading: loading ?? this.loading,
        mode: mode ?? this.mode,
        result: result ?? this.result,
        cracked: cracked ?? this.cracked,
        error: error,
      );
}

final passwordToolsProvider = StateNotifierProvider<PasswordToolsNotifier, PasswordToolsState>((ref) {
  return PasswordToolsNotifier(ref.read(apiServiceProvider));
});

class PasswordToolsNotifier extends StateNotifier<PasswordToolsState> {
  final ApiService _api;
  PasswordToolsNotifier(this._api) : super(const PasswordToolsState());

  void setMode(PasswordMode mode) => state = state.copyWith(mode: mode);

  Future<void> identify(String hash) async {
    if (state.loading) return;
    state = state.copyWith(loading: true, result: null, cracked: null, error: null);
    try {
      final res = await _api.post<Map<String, dynamic>>(ApiConstants.hashcatIdentify, data: {'hash': hash});
      state = state.copyWith(loading: false, result: res.data?['output'] as String?);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> crack(String hash, {int hashType = 0, int attackMode = 0, String? mask}) async {
    if (state.loading) return;
    state = state.copyWith(loading: true, result: null, cracked: null, error: null);
    try {
      final res = await _api.post<Map<String, dynamic>>(
        ApiConstants.hashcatCrack,
        data: {'hash': hash, 'hashType': hashType, 'attackMode': attackMode, if (mask != null) 'mask': mask},
        timeout: const Duration(minutes: 10),
      );
      final cracked = res.data?['cracked'] as String?;
      final output = res.data?['output'] as String? ?? '';
      state = state.copyWith(loading: false, cracked: cracked, result: output);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }
}
