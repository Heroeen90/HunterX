import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SshState {
  final bool isConnected;
  final bool isConnecting;
  final String? error;
  final List<Map<String, String>> savedConnections;

  const SshState({
    this.isConnected = false,
    this.isConnecting = false,
    this.error,
    this.savedConnections = const [],
  });

  SshState copyWith({
    bool? isConnected,
    bool? isConnecting,
    String? error,
    List<Map<String, String>>? savedConnections,
  }) {
    return SshState(
      isConnected: isConnected ?? this.isConnected,
      isConnecting: isConnecting ?? this.isConnecting,
      error: error,
      savedConnections: savedConnections ?? this.savedConnections,
    );
  }
}

class SshNotifier extends StateNotifier<SshState> {
  SSHClient? _client;
  SSHSession? _session;
  final _storage = const FlutterSecureStorage();

  SshNotifier() : super(const SshState());

  Future<void> connect({
    required String host,
    required int port,
    required String username,
    String? password,
    String? privateKey,
    required Function(String) onOutput,
  }) async {
    state = state.copyWith(isConnecting: true, error: null);
    try {
      final socket = await SSHSocket.connect(host, port);
      _client = SSHClient(
        socket,
        username: username,
        onPasswordRequest: password != null ? () => password : null,
        identities: privateKey != null
            ? SSHKeyPair.fromPem(privateKey)
            : null,
      );

      _session = await _client!.shell();
      state = state.copyWith(isConnected: true, isConnecting: false);

      _session!.stdout.listen((data) {
        onOutput(String.fromCharCodes(data));
      });

      _session!.stderr.listen((data) {
        onOutput(String.fromCharCodes(data));
      });
    } catch (e) {
      state = state.copyWith(
        isConnected: false,
        isConnecting: false,
        error: e.toString(),
      );
    }
  }

  void sendCommand(String command) {
    if (_session == null) return;
    final data = Uint8List.fromList('$command\n'.codeUnits);
    _session!.stdin.add(data);
  }

  void disconnect() {
    _session?.close();
    _client?.close();
    _session = null;
    _client = null;
    state = state.copyWith(isConnected: false);
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}

final sshProvider = StateNotifierProvider<SshNotifier, SshState>(
  (ref) => SshNotifier(),
);
