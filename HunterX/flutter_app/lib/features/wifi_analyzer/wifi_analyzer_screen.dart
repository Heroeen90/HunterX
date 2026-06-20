import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
import 'wifi_analyzer_provider.dart';

class WifiAnalyzerScreen extends ConsumerWidget {
  const WifiAnalyzerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(wifiAnalyzerProvider);
    final notifier = ref.read(wifiAnalyzerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new), onPressed: () => context.go('/')),
        title: const Text('WiFi Analyzer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: state.scanning ? null : notifier.scan,
          ),
        ],
      ),
      body: Column(
        children: [
          if (state.scanning)
            const LinearProgressIndicator(color: AppTheme.primary, backgroundColor: AppTheme.border),
          if (state.error != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(state.error!, style: const TextStyle(color: AppTheme.accent)),
            ),
          if (state.networks.isNotEmpty) ...[
            _buildSignalChart(state.networks),
            Expanded(child: _buildNetworkList(state.networks)),
          ] else if (!state.scanning)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_find, size: 48, color: AppTheme.textSecondary),
                    const SizedBox(height: 12),
                    const Text('Tap scan to find nearby networks', style: TextStyle(color: AppTheme.textSecondary)),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: notifier.scan,
                      icon: const Icon(Icons.search),
                      label: const Text('Scan'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSignalChart(List<WifiNetwork> networks) {
    final top = networks.take(8).toList();
    return Container(
      height: 140,
      padding: const EdgeInsets.all(12),
      color: AppTheme.surface,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 100,
          minY: 0,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) {
                  final i = v.toInt();
                  if (i >= top.length) return const SizedBox();
                  return Text(
                    top[i].ssid.length > 6 ? top[i].ssid.substring(0, 6) : top[i].ssid,
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 9),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          barGroups: List.generate(top.length, (i) {
            final strength = (top[i].level + 100).clamp(0, 100).toDouble();
            return BarChartGroupData(x: i, barRods: [
              BarChartRodData(
                toY: strength,
                color: strength > 70 ? AppTheme.primary : strength > 40 ? AppTheme.warning : AppTheme.accent,
                width: 16,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ]);
          }),
        ),
      ),
    );
  }

  Widget _buildNetworkList(List<WifiNetwork> networks) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: networks.length,
      itemBuilder: (_, i) {
        final n = networks[i];
        final strength = (n.level + 100).clamp(0, 100);
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(
              n.level > -50 ? Icons.wifi : n.level > -70 ? Icons.wifi_2_bar : Icons.wifi_1_bar,
              color: strength > 70 ? AppTheme.primary : strength > 40 ? AppTheme.warning : AppTheme.accent,
            ),
            title: Text(n.ssid),
            subtitle: Text('${n.bssid}  •  ${n.band}  •  Ch ${n.channel}'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${n.level} dBm', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                Chip(
                  label: Text(n.security, style: const TextStyle(fontSize: 9)),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  backgroundColor: n.security == 'Open' ? AppTheme.accent.withOpacity(0.2) : AppTheme.surfaceVariant,
                  side: BorderSide.none,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
