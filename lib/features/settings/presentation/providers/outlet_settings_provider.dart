import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';

/// Stream of the active outlet settings from Drift database
final outletSettingsStreamProvider = StreamProvider<OutletSetting?>((ref) {
  final db = ref.watch(databaseProvider);
  return db.select(db.outletSettings).watchSingleOrNull();
});

/// Direct Future provider for synchronous/async reading of outlet settings
final outletSettingsProvider = FutureProvider<OutletSetting?>((ref) async {
  final db = ref.watch(databaseProvider);
  return (db.select(db.outletSettings)..limit(1)).getSingleOrNull();
});

/// Computed provider for active tax percentage (defaults to 0.0)
final activeTaxRateProvider = Provider<double>((ref) {
  final settingsAsync = ref.watch(outletSettingsStreamProvider);
  return settingsAsync.value?.taxPercentage ?? 0.0;
});

/// Computed provider for active service charge percentage (defaults to 0.0)
final activeServiceChargeRateProvider = Provider<double>((ref) {
  final settingsAsync = ref.watch(outletSettingsStreamProvider);
  return settingsAsync.value?.serviceChargePercentage ?? 0.0;
});
