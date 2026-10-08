import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/providers/preferences_provider.dart';
import '../../../../features/auth/providers/auth_provider.dart';
import '../../data/sync_repository.dart';
import '../../../pos/data/sync/delta_sync_service.dart';
import '../../../pos/data/sync/initial_sync_service.dart';

final syncRepositoryProvider = Provider<SyncRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  final database = ref.watch(databaseProvider);
  final outletSettingsService = ref.watch(outletSettingsServiceProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return SyncRepository(dioClient, database, outletSettingsService, prefs);
});

final initialSyncServiceProvider = Provider<InitialSyncService>((ref) {
  return ref.watch(syncRepositoryProvider).initialSyncService;
});

final deltaSyncServiceProvider = Provider<DeltaSyncService>((ref) {
  return ref.watch(syncRepositoryProvider).deltaSyncService;
});
