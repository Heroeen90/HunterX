import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart';

final wsServiceProvider = Provider<WebSocketService>((ref) => WebSocketService());

enum WsStatus { disconnected, connecting, connected, error }

class WsMessage {
  final String type;
  final String? data;
  final int? code;
  final String? sessionId;
  final String? command;

  WsMessage({required this.type, this.data, this.code, this.sessionId, this.command});

  factory WsMessage.fromJson(Map<String, dynamic> json) => WsMessage(
        type: json['type'] as String,
        data: json['data'] as String?,
        code: json['code'] as int?,
        sessionId: json['sessionId'] as String?,
        command: json['command'] as String?,
      );
}

class WebSocketService {
  WebSocketChannel? _channel;
  String _wsUrl = ApiConstants.defaultWsUrl;
  final _controller = StreamController<WsMessage>.broadcast();
  WsStatus _status = WsStatus.disconnected;

  Stream<WsMessage> get messages => _controller.stream;
  WsStatus get status => _status;

  Future<void> connect([String? url]) async {
    if (url != null) {
      _wsUrl = url;
    } else {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('ws_url');
      if (saved != null) _wsUrl = saved;
    }
    _status = WsStatus.connecting;
    try {
      _channel = WebSocketChannel.connect(Uri.parse(_wsUrl));
      _status = WsStatus.connected;
      _channel!.stream.listen(
        (raw) {
          try {
            final json = jsonDecode(raw as String) as Map<String, dynamic>;
            _controller.add(WsMessage.fromJson(json));
          } catch (_) {
            _controller.add(WsMessage(type: 'raw', data: raw.toString()));
          }
        },
        onDone: () {
          _status = WsStatus.disconnected;
          _controller.add(WsMessage(type: 'disconnected'));
        },
        onError: (err) {
          _status = WsStatus.error;
          _controller.add(WsMessage(type: 'error', data: err.toString()));
        },
      );
    } catch (e) {
      _status = WsStatus.error;
      _controller.add(WsMessage(type: 'error', data: e.toString()));
    }
  }

  void startProcess(String command, [List<String> args = const []]) {
    _send({'action': 'start', 'command': command, 'args': args});
  }

  void sendInput(String data) {
    _send({'action': 'input', 'data': data});
  }

  void stopProcess() {
    _send({'action': 'stop'});
  }

  void _send(Map<String, dynamic> msg) {
    if (_channel != null && _status == WsStatus.connected) {
      _channel!.sink.add(jsonEncode(msg));
    }
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
    _status = WsStatus.disconnected;
  }

  void dispose() {
    disconnect();
    _controller.close();
  }
}
