import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/services/api_service.dart';
import '../../core/constants/api_constants.dart';

enum DnsQueryType { lookup, whois, subfinder, reverse }

class DnsOsintState {
  final bool loading;
  final String? result;
  final String? error;
  final DnsQueryType queryType;

  const DnsOsintState({
    this.loading = false,
    this.result,
    this.error,
    this.queryType = DnsQueryType.lookup,
  });

  DnsOsintState copyWith({
    bool? loading,
    String? result,
    String? error,
    DnsQueryType? queryType,
  }) =>
      DnsOsintState(
        loading: loading ?? this.loading,
        result: result ?? this.result,
        error: error,
        queryType: queryType ?? this.queryType,
      );
}

final dnsOsintProvider = StateNotifierProvider<DnsOsintNotifier, DnsOsintState>((ref) {
  return DnsOsintNotifier(ref.read(apiServiceProvider));
});

class DnsOsintNotifier extends StateNotifier<DnsOsintState> {
  final ApiService _api;
  DnsOsintNotifier(this._api) : super(const DnsOsintState());

  void setQueryType(DnsQueryType type) => state = state.copyWith(queryType: type);

  Future<void> lookup(String target, {String recordType = 'A'}) async {
    state = state.copyWith(loading: true, result: null, error: null);
    try {
      final res = await _api.post<Map<String, dynamic>>(
        ApiConstants.dnsLookup,
        data: {'domain': target, 'type': recordType},
      );
      state = state.copyWith(loading: false, result: _formatJson(res.data));
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> whois(String domain) async {
    state = state.copyWith(loading: true, result: null, error: null);
    try {
      final res = await _api.post<Map<String, dynamic>>(
        ApiConstants.dnsWhois,
        data: {'domain': domain},
        timeout: ApiConstants.mediumTimeout,
      );
      state = state.copyWith(loading: false, result: res.data?['output'] as String?);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> subfinder(String domain) async {
    state = state.copyWith(loading: true, result: null, error: null);
    try {
      final res = await _api.post<Map<String, dynamic>>(
        ApiConstants.dnsSubfinder,
        data: {'domain': domain},
        timeout: ApiConstants.mediumTimeout,
      );
      final subs = (res.data?['subdomains'] as List? ?? []).join('\n');
      state = state.copyWith(loading: false, result: subs.isEmpty ? 'No subdomains found' : subs);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> reverseLookup(String ip) async {
    state = state.copyWith(loading: true, result: null, error: null);
    try {
      final res = await _api.post<Map<String, dynamic>>(
        ApiConstants.dnsReverse,
        data: {'ip': ip},
      );
      state = state.copyWith(loading: false, result: _formatJson(res.data));
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  String _formatJson(dynamic data) {
    if (data == null) return 'No data';
    if (data is Map || data is List) {
      return data.toString();
    }
    return data.toString();
  }
}
