import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import '../../core/constants/api_constants.dart';

class ServerConfig {
  final String serverUrl;
  final String wsUrl;
  final String? apiKey;
  final bool isConnected;
  final Map<String, bool> toolsAvailable;

  const ServerConfig({
    required this.serverUrl,
    required this.wsUrl,
    this.apiKey,
    this.isConnected = false,
    this.toolsAvailable = const {},
  });

  ServerConfig copyWith({
    String? serverUrl,
    String? wsUrl,
    String? apiKey,
    bool? isConnected,
    Map<String, bool>? toolsAvailable,
  }) =>
      ServerConfig(
        serverUrl: serverUrl ?? this.serverUrl,
        wsUrl: wsUrl ?? this.wsUrl,
        apiKey: apiKey ?? this.apiKey,
        isConnected: isConnected ?? this.isConnected,
        toolsAvailable: toolsAvailable ?? this.toolsAvailable,
      );
}

final serverConfigProvider = StateNotifierProvider<ServerConfigNotifier, ServerConfig>((ref) {
  return ServerConfigNotifier(ref.read(apiServiceProvider));
});

class ServerConfigNotifier extends StateNotifier<ServerConfig> {
  final ApiService _api;

  ServerConfigNotifier(this._api)
      : super(ServerConfig(
          serverUrl: ApiConstants.defaultBaseUrl,
          wsUrl: ApiConstants.defaultWsUrl,
        )) {
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final url = prefs.getString('server_url') ?? ApiConstants.defaultBaseUrl;
    final ws = prefs.getString('ws_url') ?? ApiConstants.defaultWsUrl;
    final key = prefs.getString('api_key');
    state = state.copyWith(serverUrl: url, wsUrl: ws, apiKey: key);
    _api.setBaseUrl(url);
    _api.setApiKey(key);
  }

  Future<bool> connect(String serverUrl, {String? apiKey}) async {
    final wsUrl = serverUrl
        .replaceFirst('http://', 'ws://')
        .replaceFirst('https://', 'wss://') + '/ws/terminal'.replaceFirst('/api', '');

    _api.setBaseUrl(serverUrl);
    _api.setApiKey(apiKey);

    final ok = await _api.ping();
    if (ok) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('server_url', serverUrl);
      await prefs.setString('ws_url', wsUrl);
      if (apiKey != null) await prefs.setString('api_key', apiKey);

      Map<String, bool> tools = {};
      try {
        final res = await _api.get<Map<String, dynamic>>(ApiConstants.systemTools);
        tools = Map<String, bool>.from((res.data?['tools'] as Map?) ?? {});
      } catch (_) {}

      state = state.copyWith(
        serverUrl: serverUrl,
        wsUrl: wsUrl,
        apiKey: apiKey,
        isConnected: true,
        toolsAvailable: tools,
      );
    } else {
      state = state.copyWith(isConnected: false);
    }
    return ok;
  }

  void disconnect() {
    state = state.copyWith(isConnected: false);
  }
}
