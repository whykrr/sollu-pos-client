import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sollu_pos_client/core/database/database_provider.dart';
import 'package:sollu_pos_client/core/models/printer_model.dart';
import 'package:sollu_pos_client/core/providers/preferences_provider.dart';
import 'package:sollu_pos_client/core/services/printer_service.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/transaction_provider.dart';
import 'package:sollu_pos_client/features/settings/presentation/providers/outlet_settings_provider.dart';
import 'package:sollu_pos_client/features/shift/presentation/providers/shift_provider.dart';
import 'package:sollu_pos_client/features/auth/presentation/providers/auth_provider.dart';

final printerServiceProvider = Provider<PrinterService>((ref) {
  return PrinterService();
});

Future<({bool success, String message})> printTransactionReceiptAction({
  required WidgetRef ref,
  required String transactionId,
  String? cashierName,
  String? outletName,
  String? outletAddress,
  String? outletPhone,
}) async {
  final printerConfig = ref.read(selectedPrinterProvider);
  if (printerConfig == null) {
    return (
      success: false,
      message: 'Printer belum diatur! Silakan pilih printer di Pengaturan.',
    );
  }

  final repository = ref.read(transactionRepositoryProvider);
  final detail = await repository.getTransactionDetails(transactionId);
  if (detail == null) {
    return (success: false, message: 'Data transaksi tidak ditemukan!');
  }

  final db = ref.read(databaseProvider);

  String? resolvedCashierName = cashierName;
  if (resolvedCashierName == null && detail.transaction.shiftId != null) {
    final shift =
        await (db.select(db.shifts)
              ..where((s) => s.id.equals(detail.transaction.shiftId!)))
            .getSingleOrNull();
    if (shift != null) {
      resolvedCashierName = await ref.read(
        cashierNameProvider(shift.userId).future,
      );
    }
  }
  // Fallback ke nama kasir yang sedang aktif jika transaksi tanpa shift
  resolvedCashierName ??= ref.read(activeEmployeeProvider)?['name']?.toString();

  // Dynamically enrich printer config from synced outlet receipt settings if available (store header, notes)
  final outletSetting = ref.read(outletSettingsProvider);
  final outletProfile = ref.read(outletProfileProvider);

  String? profileOutletName = outletProfile?['name']?.toString();
  String? profileOutletAddress = outletProfile?['address']?.toString();
  String? profileOutletPhone = outletProfile?['phone']?.toString();

  PrinterConfig effectiveConfig = printerConfig;
  if (outletSetting != null) {
    effectiveConfig = printerConfig.copyWith(
      storeName:
          (outletSetting['customHeaderTitle'] != null &&
              outletSetting['customHeaderTitle'].toString().isNotEmpty)
          ? outletSetting['customHeaderTitle'].toString()
          : (outletName ?? profileOutletName ?? printerConfig.storeName),
      headerNote:
          outletSetting['headerNotes']?.toString() ?? printerConfig.headerNote,
      footerNote:
          outletSetting['footerNotes']?.toString() ?? printerConfig.footerNote,
    );
  }

  // Load cached logo bytes if showLogo is enabled
  Uint8List? logoBytes;
  final rawShowLogo =
      outletSetting?['show_logo'] ?? outletSetting?['showLogo'];
  final bool showLogo = rawShowLogo == true ||
      rawShowLogo == 1 ||
      rawShowLogo == '1' ||
      rawShowLogo == null;

  if (showLogo) {
    final logoPath = outletSetting?['localLogoPath'] ??
        outletSetting?['local_logo_path'] ??
        outletProfile?['local_logo_path'] ??
        outletProfile?['localLogoPath'];

    if (logoPath != null && logoPath.toString().isNotEmpty) {
      try {
        final file = File(logoPath.toString());
        if (await file.exists()) {
          logoBytes = await file.readAsBytes();
        }
      } catch (e) {
        debugPrint('Error reading local logo file: $e');
      }
    }

    // Fallback: Load default asset logo if local logo is not available
    if (logoBytes == null || logoBytes.isEmpty) {
      try {
        final ByteData assetData =
            await rootBundle.load('img/logo-colored.png');
        logoBytes = assetData.buffer.asUint8List();
      } catch (e) {
        debugPrint('Error loading asset logo fallback: $e');
      }
    }
  }

  final service = ref.read(printerServiceProvider);
  return await service.printTransactionReceipt(
    detail: detail,
    config: effectiveConfig,
    outletSetting: outletSetting,
    logoBytes: logoBytes,
    cashierName: resolvedCashierName,
    outletName: outletName ?? profileOutletName,
    outletAddress: outletAddress ?? profileOutletAddress,
    outletPhone: outletPhone ?? profileOutletPhone,
    outletEmail: outletProfile?['email']?.toString(),
  );
}

/// Helper aksi untuk memicu pembukaan laci kasir (Drawer Kick) secara manual
Future<({bool success, String message})> openCashDrawerAction({
  required WidgetRef ref,
}) async {
  final printerConfig = ref.read(selectedPrinterProvider);
  if (printerConfig == null) {
    return (
      success: false,
      message: 'Printer belum diatur! Hubungkan printer di Pengaturan.',
    );
  }

  if (!printerConfig.openCashDrawer) {
    return (
      success: false,
      message: 'Pengaturan buka laci otomatis sedang nonaktif.',
    );
  }

  final service = ref.read(printerServiceProvider);
  return await service.openCashDrawer(printerConfig);
}

class SelectedPrinterNotifier extends Notifier<PrinterConfig?> {
  static const String _key = 'sollu_saved_printer_config';

  @override
  PrinterConfig? build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final jsonStr = prefs.getString(_key);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        return PrinterConfig.fromJson(jsonStr);
      } catch (e) {
        debugPrint('Error parsing saved printer config: $e');
      }
    }
    return null;
  }

  Future<void> savePrinter(PrinterConfig config) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_key, config.toJson());
    state = config;

    // Simpan ukuran kertas ke OutletSettingsService lokal (dedicated on-device)
    try {
      final service = ref.read(outletSettingsServiceProvider);
      final existing = service.getOutletSettings() ?? <String, dynamic>{};
      final paperSizeStr = config.paperSize == PrinterPaperSize.mm80
          ? '80mm'
          : '58mm';
      existing['paperSize'] = paperSizeStr;
      await service.saveOutletSettings(existing);
    } catch (e) {
      debugPrint('Error updating local outlet settings paper size: $e');
    }
  }

  Future<void> updateAutoPrint(bool autoPrint) async {
    // Update SharedPreferences via OutletSettingsService lokal secara dedicated
    try {
      final service = ref.read(outletSettingsServiceProvider);
      await service.saveAutoPrint(autoPrint);
      final existing = service.getOutletSettings();
      if (existing != null) {
        existing['autoPrint'] = autoPrint;
        await service.saveOutletSettings(existing);
      }
    } catch (e) {
      debugPrint('Error updating auto_print locally: $e');
    }
  }

  Future<void> removePrinter() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.remove(_key);
    state = null;
  }

  Future<void> updatePaperSize(PrinterPaperSize size) async {
    if (state != null) {
      final updated = state!.copyWith(paperSize: size);
      await savePrinter(updated);
    }
  }

  Future<void> updateAutoCut(bool autoCut) async {
    if (state != null) {
      final updated = state!.copyWith(autoCut: autoCut);
      await savePrinter(updated);
    }
  }

  Future<void> updateCashDrawer(bool openCashDrawer) async {
    if (state != null) {
      final updated = state!.copyWith(openCashDrawer: openCashDrawer);
      await savePrinter(updated);
    }
  }

  Future<void> updateNotes({
    String? storeName,
    String? headerNote,
    String? footerNote,
  }) async {
    if (state != null) {
      final updated = state!.copyWith(
        storeName: storeName ?? state!.storeName,
        headerNote: headerNote ?? state!.headerNote,
        footerNote: footerNote ?? state!.footerNote,
      );
      await savePrinter(updated);
    }
  }
}

final selectedPrinterProvider =
    NotifierProvider<SelectedPrinterNotifier, PrinterConfig?>(
      SelectedPrinterNotifier.new,
    );

class AvailablePrintersNotifier
    extends AsyncNotifier<List<DiscoveredPrinterInfo>> {
  @override
  Future<List<DiscoveredPrinterInfo>> build() async {
    return _fetchDevices();
  }

  Future<List<DiscoveredPrinterInfo>> _fetchDevices() async {
    final service = ref.read(printerServiceProvider);
    return await service.getAvailablePrinters();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchDevices());
  }
}

final availablePrintersProvider =
    AsyncNotifierProvider<
      AvailablePrintersNotifier,
      List<DiscoveredPrinterInfo>
    >(AvailablePrintersNotifier.new);

/// Helper aksi untuk menjalankan Live Setup Test Print dengan konteks toko riil
Future<({bool success, String message})> printTestReceiptAction({
  required WidgetRef ref,
  required PrinterConfig config,
}) async {
  final outletSetting = ref.read(outletSettingsProvider);
  final outletProfile = ref.read(outletProfileProvider);

  String? profileOutletName = outletProfile?['name']?.toString();

  PrinterConfig effectiveConfig = config;
  if (outletSetting != null) {
    effectiveConfig = config.copyWith(
      storeName:
          (outletSetting['customHeaderTitle'] != null &&
              outletSetting['customHeaderTitle'].toString().isNotEmpty)
          ? outletSetting['customHeaderTitle'].toString()
          : (profileOutletName ?? config.storeName),
      headerNote:
          outletSetting['headerNotes']?.toString() ?? config.headerNote,
      footerNote:
          outletSetting['footerNotes']?.toString() ?? config.footerNote,
    );
  }

  // Load cached logo bytes if showLogo is enabled
  Uint8List? logoBytes;
  final rawShowLogo =
      outletSetting?['show_logo'] ?? outletSetting?['showLogo'];
  final bool showLogo = rawShowLogo == true ||
      rawShowLogo == 1 ||
      rawShowLogo == '1' ||
      rawShowLogo == null;

  if (showLogo) {
    final logoPath = outletSetting?['localLogoPath'] ??
        outletSetting?['local_logo_path'] ??
        outletProfile?['local_logo_path'] ??
        outletProfile?['localLogoPath'];

    if (logoPath != null && logoPath.toString().isNotEmpty) {
      try {
        final file = File(logoPath.toString());
        if (await file.exists()) {
          logoBytes = await file.readAsBytes();
        }
      } catch (e) {
        debugPrint('Error reading local logo file for test: $e');
      }
    }

    if (logoBytes == null || logoBytes.isEmpty) {
      try {
        final ByteData assetData =
            await rootBundle.load('img/logo-colored.png');
        logoBytes = assetData.buffer.asUint8List();
      } catch (e) {
        debugPrint('Error loading asset logo fallback for test: $e');
      }
    }
  }

  final service = ref.read(printerServiceProvider);
  return await service.printTest(
    effectiveConfig,
    outletProfile: outletProfile,
    outletSetting: outletSetting,
    logoBytes: logoBytes,
  );
}
