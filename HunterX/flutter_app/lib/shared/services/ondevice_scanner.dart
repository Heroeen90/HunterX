import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network_info_plus/network_info_plus.dart';

final onDeviceScannerProvider = Provider<OnDeviceScanner>((ref) => OnDeviceScanner());

class HostResult {
  final String ip;
  final String? hostname;
  final int responseMs;

  const HostResult({required this.ip, this.hostname, required this.responseMs});
}

class PortResult {
  final int port;
  final bool open;
  final String? banner;

  const PortResult({required this.port, required this.open, this.banner});
}

class OnDeviceScanner {
  final _info = NetworkInfo();

  Future<String?> getLocalIp() => _info.getWifiIP();
  Future<String?> getGateway() => _info.getWifiGatewayIP();
  Future<String?> getSsid() => _info.getWifiName();

  Future<List<HostResult>> pingSubnet(
    String subnet, {
    int timeoutMs = 800,
    void Function(HostResult)? onFound,
  }) async {
    final parts = subnet.split('.');
    if (parts.length < 3) return [];
    final base = '${parts[0]}.${parts[1]}.${parts[2]}';
    final results = <HostResult>[];
    final futures = <Future>[];

    for (int i = 1; i <= 254; i++) {
      futures.add(() async {
        final ip = '$base.$i';
        final sw = Stopwatch()..start();
        try {
          final socket = await Socket.connect(
            ip, 80,
            timeout: Duration(milliseconds: timeoutMs),
          );
          sw.stop();
          socket.destroy();
          String? hostname;
          try {
            final resolved = await InternetAddress(ip).reverse();
            hostname = resolved.host;
          } catch (_) {}
          final result = HostResult(ip: ip, hostname: hostname, responseMs: sw.elapsedMilliseconds);
          results.add(result);
          onFound?.call(result);
        } on SocketException {
          // Host not reachable on port 80 — try ICMP-like ping via raw socket
        } catch (_) {}
      }());
    }

    await Future.wait(futures);
    results.sort((a, b) {
      final aLast = int.tryParse(a.ip.split('.').last) ?? 0;
      final bLast = int.tryParse(b.ip.split('.').last) ?? 0;
      return aLast.compareTo(bLast);
    });
    return results;
  }

  Stream<PortResult> scanPorts(
    String host, {
    List<int>? ports,
    int timeoutMs = 500,
  }) async* {
    final targetPorts = ports ??
        [
          21, 22, 23, 25, 53, 80, 110, 143, 443, 445,
          3306, 3389, 5432, 6379, 8080, 8443, 8888, 9200, 27017,
        ];

    for (final port in targetPorts) {
      final sw = Stopwatch()..start();
      try {
        final socket = await Socket.connect(
          host, port,
          timeout: Duration(milliseconds: timeoutMs),
        );
        sw.stop();
        String? banner;
        try {
          socket.write('\n');
          final data = await socket.first.timeout(const Duration(milliseconds: 300));
          banner = String.fromCharCodes(data).trim();
        } catch (_) {}
        socket.destroy();
        yield PortResult(port: port, open: true, banner: banner);
      } catch (_) {
        yield PortResult(port: port, open: false);
      }
    }
  }
}
