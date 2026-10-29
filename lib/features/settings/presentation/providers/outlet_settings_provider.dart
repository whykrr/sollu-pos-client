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

/// Computed provider for current outlet ID
final currentOutletIdProvider = Provider<String>((ref) {
  final profile = ref.watch(outletProfileProvider);
  return profile?['id']?.toString() ?? 'default-outlet';
});

/// Computed provider for allow negative stock setting (defaults to true)
final allowNegativeStockProvider = Provider<bool>((ref) {
  final settings = ref.watch(outletSettingsProvider);
  if (settings != null && settings.containsKey('allowNegativeStock')) {
    final val = settings['allowNegativeStock'];
    return val == true || val == 1 || val == '1' || val == 'true';
  }
  return true;
});

/// Computed provider for active POS order types (walk_in, dine_in, take_away)
final posOrderTypesProvider = Provider<List<String>>((ref) {
  final settings = ref.watch(outletSettingsProvider);
  if (settings != null && settings['posOrderTypes'] is List) {
    final list = (settings['posOrderTypes'] as List)
        .map((e) => e.toString())
        .toList();
    if (list.isNotEmpty) return list;
  }
  return const ['walk_in', 'dine_in', 'take_away'];
});

/// Computed provider for enable supervisor PIN setting (defaults to false)
final enableSupervisorPinProvider = Provider<bool>((ref) {
  final settings = ref.watch(outletSettingsProvider);
  if (settings != null && settings.containsKey('enableSupervisorPin')) {
    final val = settings['enableSupervisorPin'];
    return val == true || val == 1 || val == '1' || val == 'true';
  }
  return false;
});

