import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sollu_pos_client/core/providers/auto_sync_provider.dart';
import 'package:sollu_pos_client/features/settings/presentation/providers/bootstrap_provider.dart';
import 'package:sollu_pos_client/features/settings/presentation/providers/feature_gating_provider.dart';
import 'package:sollu_pos_client/features/settings/presentation/widgets/sync_progress_overlay.dart';
import 'package:sollu_pos_client/features/shift/presentation/providers/shift_provider.dart';
import 'package:sollu_pos_client/features/shift/presentation/widgets/shift_dialogs.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/pos_mode_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/realtime_provider.dart';
import '../views/fast_retail/fast_retail_view.dart';
import '../views/visual_touch/visual_touch_view.dart';

/// Clean Root Router & Orchestrator untuk Dual Mode POS Sollu (Fast Retail vs Visual Touch)
class PosLayout extends ConsumerStatefulWidget {
  const PosLayout({super.key});

  @override
  ConsumerState<PosLayout> createState() => _PosLayoutState();
}

class _PosLayoutState extends ConsumerState<PosLayout> {
  @override
  void initState() {
    super.initState();
    // 1. Inisialisasi background sync bootstrap master data & karyawan
    ref.read(bootstrapProvider);

    // 2. Inisialisasi Reverb WebSocket Realtime Client
    ref.read(posReverbClientProvider);

    // 3. Shift Cashier Gating & Auto Prompt Dialog Buka Shift
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final featureGating = ref.read(featureGatingProvider);
      if (!featureGating.canUseShiftCashier()) return;

      final shiftRepository = ref.read(shiftRepositoryProvider);
      final activeShift = await shiftRepository.getActiveShift();
      if (activeShift == null && mounted) {
        OpenShiftDialog.show(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch auto-sync background worker
    ref.watch(autoSyncProvider);

    final posMode = ref.watch(posModeProvider);

    return Scaffold(
      body: Stack(
        children: [
          posMode == PosMode.fastRetail
              ? const FastRetailView()
              : const VisualTouchView(),

          // Floating Background Sync Progress Overlay
          const SyncProgressOverlay(),
        ],
      ),
    );
  }
}
