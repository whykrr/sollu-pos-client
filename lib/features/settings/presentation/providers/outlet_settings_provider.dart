import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/preferences_provider.dart';
import 'feature_gating_provider.dart';

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

/// Computed provider for enable supervisor PIN setting.
/// WAJIB digate oleh fitur 'double_authorization' dari langganan merchant.
final enableSupervisorPinProvider = Provider<bool>((ref) {
  final settings = ref.watch(outletSettingsProvider);
  if (settings != null && settings.containsKey('enableSupervisorPin')) {
    final val = settings['enableSupervisorPin'];
    final isConfigured = val == true || val == 1 || val == '1' || val == 'true';
    if (!isConfigured) return false;
    final featureGating = ref.watch(featureGatingProvider);
    if (featureGating.activeFeatures.isNotEmpty) {
      return featureGating.canUseDoubleAuthorization();
    }
    return true;
  }
  return false;
});

/// Computed provider for whether tax is included in price (inclusive tax)
final taxIncludedInPriceProvider = Provider<bool>((ref) {
  final settings = ref.watch(outletSettingsProvider);
  if (settings != null &&
      (settings.containsKey('taxIncludedInPrice') ||
          settings.containsKey('tax_included_in_price'))) {
    final val =
        settings['taxIncludedInPrice'] ?? settings['tax_included_in_price'];
    return val == true || val == 1 || val == '1' || val == 'true';
  }
  return false;
});

/// Computed provider for rounding enabled
final roundingEnabledProvider = Provider<bool>((ref) {
  final settings = ref.watch(outletSettingsProvider);
  if (settings != null &&
      (settings.containsKey('roundingEnabled') ||
          settings.containsKey('rounding_enabled'))) {
    final val =
        settings['roundingEnabled'] ?? settings['rounding_enabled'];
    return val == true || val == 1 || val == '1' || val == 'true';
  }
  return false;
});

/// Computed provider for rounding mode ('nearest', 'up', 'down')
final roundingModeProvider = Provider<String>((ref) {
  final settings = ref.watch(outletSettingsProvider);
  return (settings?['roundingMode'] ?? settings?['rounding_mode'])?.toString() ??
      'nearest';
});

/// Helper domain kalkulasi pajak (inklusif vs eksklusif)
double calculateTaxAmount({
  required double taxableAmount,
  required double taxRate,
  required bool taxIncludedInPrice,
}) {
  if (taxRate <= 0) return 0.0;
  if (taxIncludedInPrice) {
    return taxableAmount - (taxableAmount / (1 + (taxRate / 100.0)));
  } else {
    return taxableAmount * (taxRate / 100.0);
  }
}

/// Helper domain kalkulasi grand total
double calculateGrandTotal({
  required double taxableAmount,
  required double taxAmount,
  required double serviceChargeAmount,
  required bool taxIncludedInPrice,
}) {
  if (taxIncludedInPrice) {
    return taxableAmount + serviceChargeAmount;
  } else {
    return taxableAmount + taxAmount + serviceChargeAmount;
  }
}

/// Helper pembulatan nominal tunai kasir (cash rounding)
double applyCashRounding({
  required double amount,
  required bool roundingEnabled,
  required String roundingMode,
  int denomination = 100,
}) {
  if (!roundingEnabled || denomination <= 0) return amount;
  switch (roundingMode.toLowerCase()) {
    case 'up':
    case 'ceil':
      return (amount / denomination).ceilToDouble() * denomination;
    case 'down':
    case 'floor':
      return (amount / denomination).floorToDouble() * denomination;
    case 'nearest':
    default:
      return (amount / denomination).roundToDouble() * denomination;
  }
}

