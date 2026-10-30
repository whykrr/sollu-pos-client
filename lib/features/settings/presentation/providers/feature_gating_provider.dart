import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'outlet_settings_provider.dart';

/// Domain service untuk mengevaluasi hak akses fitur POS merchant
class FeatureGatingService {
  final List<String> activeFeatures;

  const FeatureGatingService({required this.activeFeatures});

  /// Cek apakah fitur tertentu aktif (case-insensitive & trimmed)
  bool hasFeature(String code) {
    return activeFeatures.contains(code.trim().toLowerCase());
  }

  /// Fitur Pembagian Pembayaran Multi-Tender / Split Bill
  bool canUseSplitPayment() => hasFeature('split_payment');

  /// Fitur CRM, Member & Pelanggan
  bool canUseCrm() => hasFeature('crm');

  /// Fitur Manajemen Shift Kasir
  bool canUseShiftCashier() => hasFeature('shift_cashier');

  /// Fitur Laci Kasir Fisik (Cash Drawer Kick)
  bool canUseCashDrawer() => hasFeature('cash_drawer');

  /// Fitur Otorisasi Ganda / PIN Supervisor
  bool canUseDoubleAuthorization() => hasFeature('double_authorization');

  /// Fitur Varian Produk
  bool canUseProductVariant() => hasFeature('product_variant');

  /// Fitur Modifier Produk
  bool canUseProductModifier() => hasFeature('product_modifier');

  /// Fitur Resep & BOM Produk
  bool canUseProductBom() => hasFeature('product_bom');

  /// Evaluasi apakah PIN supervisor boleh aktif berdasarkan ketersediaan fitur DOUBLE_AUTHORIZATION
  bool isSupervisorPinAllowed(bool configuredSetting) {
    return canUseDoubleAuthorization() && configuredSetting;
  }
}

/// Provider daftar fitur aktif yang diekstrak dari SharedPreferences outlet settings
final activeFeaturesListProvider = Provider<List<String>>((ref) {
  final settings = ref.watch(outletSettingsProvider);
  if (settings != null) {
    final raw = settings['activeFeatures'] ?? settings['active_features'];
    if (raw is List) {
      return raw
          .map((e) => e.toString().trim().toLowerCase())
          .where((e) => e.isNotEmpty)
          .toList();
    }
  }
  return const <String>[];
});

/// Provider utama Feature Gating Service
final featureGatingProvider = Provider<FeatureGatingService>((ref) {
  final features = ref.watch(activeFeaturesListProvider);
  return FeatureGatingService(activeFeatures: features);
});
