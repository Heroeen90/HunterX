import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:xterm/xterm.dart';

class SshState {
  final bool connecting;
  final bool connected;
  final String? error;

  const SshState({this.connecting = false, this.connected = false, this.error});

  SshState copyWith({bool? connecting, bool? connected, String? error}) =>
      SshState(
        connecting: connecting ?? this.connecting,
        connected: connected ?? this.connected,
        error: error,
      );
}

final sshStateProvider = StateNotifierProvider.autoDispose<SshNotifier, SshState>((ref) {
  return SshNotifier();
});

class SshNotifier extends StateNotifier<SshState> {
  SSHClient? _client;
  SSHSession? _session;

  SshNotifier() : super(const SshState());

  Terminal get terminal => _terminal;
  final _terminal = Terminal(maxLines: 10000);

  Future<void> connect({
    required String host,
    required int port,
    required String username,
    String? password,
    String? privateKey,
  }) async {
    if (state.connecting || state.connected) return;
    state = state.copyWith(connecting: true, error: null);

    try {
      final socket = await SSHSocket.connect(host, port, timeout: const Duration(seconds: 10));
      _client = SSHClient(
        socket,
        username: username,
        onPasswordRequest: password != null ? () => password : null,
        identities: privateKey != null ? [SSHKeyPair.fromPem(privateKey)] : null,
      );

      _session = await _client!.shell(
        pty: SSHPtyConfig(
          type: 'xterm-256color',
          width: 80,
          height: 24,
        ),
      );

      state = state.copyWith(connecting: false, connected: true);

      _session!.stdout.listen((data) {
        _terminal.write(String.fromCharCodes(data));
      });

      _session!.stderr.listen((data) {
        _terminal.write(String.fromCharCodes(data));
      });

      _terminal.onOutput = (data) {
        _session!.stdin.add(data.codeUnits);
      };

      _session!.done.then((_) {
        state = state.copyWith(connected: false);
        _terminal.write('\r\n[Session closed]\r\n');
      });
    } catch (e) {
      state = state.copyWith(connecting: false, connected: false, error: e.toString());
    }
  }

  void resize(int cols, int rows) {
    _session?.resizeTerminal(cols, rows);
  }

  void disconnect() {
    _session?.close();
    _client?.close();
    _session = null;
    _client = null;
    state = state.copyWith(connected: false);
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
