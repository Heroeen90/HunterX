import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../services/server_connection_service.dart';

class ServerStatusWidget extends ConsumerWidget {
  const ServerStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(serverConfigProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: config.isConnected ? AppTheme.primary.withOpacity(0.4) : AppTheme.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: config.isConnected ? AppTheme.primary : AppTheme.accent,
              boxShadow: config.isConnected
                  ? [BoxShadow(color: AppTheme.primary.withOpacity(0.5), blurRadius: 6)]
                  : null,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            config.isConnected ? 'Connected' : 'Offline',
            style: TextStyle(
              color: config.isConnected ? AppTheme.primary : AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (config.isConnected) ...[
            const SizedBox(width: 6),
            Text(
              config.serverUrl.replaceFirst('http://', '').replaceFirst('https://', ''),
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }
}
