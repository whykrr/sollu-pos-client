import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/auto_sync_provider.dart';
import '../../../../core/providers/preferences_provider.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../data/realtime/pos_reverb_client.dart';

final posReverbClientProvider = Provider<PosReverbClient>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  final outletSettings = ref.watch(outletSettingsServiceProvider);

  final client = PosReverbClient(
    dioClient: dioClient,
    outletSettingsService: outletSettings,
    onNudge: (entities) {
      debugPrint('[RealtimeProvider] Received pos.catalog.nudge ($entities). Triggering delta sync...');
      ref.read(autoSyncProvider.notifier).triggerDeltaSync(entities: entities);
    },
  );

  // Monitor auth status: connect when authenticated, disconnect when unauthenticated
  final authState = ref.watch(authNotifierProvider);
  if (authState == AuthState.authenticated) {
    client.connect();
  } else {
    client.disconnect();
  }

  ref.onDispose(() {
    client.dispose();
  });

  return client;
});
