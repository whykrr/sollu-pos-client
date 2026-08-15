import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sollu_pos_client/core/theme/sollu_colors.dart';
import 'package:sollu_pos_client/core/providers/auto_sync_provider.dart';

class SyncProgressOverlay extends ConsumerWidget {
  const SyncProgressOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(autoSyncProvider);

    if (syncState.status == AutoSyncStatus.idle) {
      return const SizedBox.shrink();
    }

    Color bgColor = SolluColors.primary;
    IconData iconData = Icons.sync;
    bool isSpinning = false;

    switch (syncState.status) {
      case AutoSyncStatus.syncing:
        bgColor = SolluColors.primary;
        isSpinning = true;
        break;
      case AutoSyncStatus.success:
        bgColor = SolluColors.success;
        iconData = Icons.check_circle;
        break;
      case AutoSyncStatus.error:
        bgColor = SolluColors.danger;
        iconData = Icons.error;
        break;
      default:
        break;
    }

    return Positioned(
      bottom: 24,
      right: 24,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: bgColor.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSpinning)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              else
                Icon(iconData, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Text(
                syncState.message ?? 'Menyinkronkan...',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              if (!isSpinning) ...[
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    ref.read(autoSyncProvider.notifier).dismiss();
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(Icons.close, color: Colors.white70, size: 16),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
