import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/preferences_provider.dart';

/// Provider for outlet settings from SharedPreferences
final outletSettingsProvider = Provider<Map<String, dynamic>?>((ref) {
  final service = ref.watch(outletSettingsServiceProvider);
  return service.getOutletSettings();
});

/// Provider for outlet profile from SharedPreferences
final outletProfileProvider = Provider<Map<String, dynamic>?>((ref) {
  final service = ref.watch(outletSettingsServiceProvider);
  return service.getOutletProfile();
});

/// Computed provider for active tax percentage (defaults to 0.0)
final activeTaxRateProvider = Provider<double>((ref) {
  final settings = ref.watch(outletSettingsProvider);
  if (settings != null && settings.containsKey('taxPercentage')) {
    return (settings['taxPercentage'] as num).toDouble();
  }
  return 0.0;
});

/// Computed provider for active service charge percentage (defaults to 0.0)
final activeServiceChargeRateProvider = Provider<double>((ref) {
  final settings = ref.watch(outletSettingsProvider);
  if (settings != null && settings.containsKey('serviceChargePercentage')) {
    return (settings['serviceChargePercentage'] as num).toDouble();
  }
  return 0.0;
});
