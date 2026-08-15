import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sollu_pos_client/core/models/printer_model.dart';
import 'package:sollu_pos_client/core/providers/preferences_provider.dart';
import 'package:sollu_pos_client/core/services/printer_service.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/transaction_provider.dart';

import 'package:drift/drift.dart' as drift;
import 'package:sollu_pos_client/core/database/app_database.dart';
import 'package:sollu_pos_client/core/database/database_provider.dart';
import 'package:sollu_pos_client/features/auth/providers/auth_provider.dart';
import 'package:sollu_pos_client/features/shift/presentation/providers/shift_provider.dart';

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
    return (
      success: false,
      message: 'Data transaksi tidak ditemukan!',
    );
  }
  
  final db = ref.read(databaseProvider);

  String? resolvedCashierName = cashierName;
  if (resolvedCashierName == null && detail.transaction.shiftId != null) {
    final shift = await (db.select(db.shifts)..where((s) => s.id.equals(detail.transaction.shiftId!))).getSingleOrNull();
    if (shift != null) {
      resolvedCashierName = await ref.read(cashierNameProvider(shift.userId).future);
    }
  }

  // Dynamically enrich printer config from synced outlet receipt settings if available
  final outletSetting = await (db.select(db.outletSettings)..limit(1)).getSingleOrNull();
  PrinterConfig effectiveConfig = printerConfig;
  if (outletSetting != null) {
    effectiveConfig = printerConfig.copyWith(
      storeName: (outletSetting.customHeaderTitle != null && outletSetting.customHeaderTitle!.isNotEmpty)
          ? outletSetting.customHeaderTitle
          : (outletName ?? printerConfig.storeName),
      headerNote: outletSetting.headerNotes ?? printerConfig.headerNote,
      footerNote: outletSetting.footerNotes ?? printerConfig.footerNote,
      paperSize: outletSetting.paperSize == '80mm' ? PrinterPaperSize.mm80 : PrinterPaperSize.mm58,
    );
  }

  // Load cached logo bytes if showLogo is enabled
  Uint8List? logoBytes;
  if ((outletSetting?.showLogo ?? true) && outletSetting?.localLogoPath != null) {
    try {
      final file = File(outletSetting!.localLogoPath!);
      if (await file.exists()) {
        logoBytes = await file.readAsBytes();
      }
    } catch (e) {
      debugPrint('Error reading logo file: $e');
    }
  }

  final service = ref.read(printerServiceProvider);
  return await service.printTransactionReceipt(
    detail: detail,
    config: effectiveConfig,
    outletSetting: outletSetting,
    logoBytes: logoBytes,
    cashierName: resolvedCashierName,
    outletName: outletName,
    outletAddress: outletAddress,
    outletPhone: outletPhone,
  );
}

Future<({bool success, String message})> openCashDrawerAction({
  required WidgetRef ref,
}) async {
  final printerConfig = ref.read(selectedPrinterProvider);
  if (printerConfig == null) {
    return (
      success: false,
      message: 'Printer belum diatur! Silakan pilih printer di Pengaturan.',
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

    // Override local database & sync to backend central database
    await _syncToLocalDbAndBackend(config);
  }

  Future<void> _syncToLocalDbAndBackend(PrinterConfig config) async {
    final paperSizeStr = config.paperSize == PrinterPaperSize.mm80 ? '80mm' : '58mm';
    
    // 1. Override local Drift OutletSettings
    try {
      final db = ref.read(databaseProvider);
      final existing = await (db.select(db.outletSettings)..limit(1)).getSingleOrNull();
      if (existing != null) {
        await (db.update(db.outletSettings)..where((t) => t.id.equals(existing.id))).write(
          OutletSettingsCompanion(
            paperSize: drift.Value(paperSizeStr),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error updating local outlet settings paper size: $e');
    }

    // 2. Sync to Backend Central API
    try {
      final dioClient = ref.read(dioClientProvider);
      await dioClient.dio.put(
        '/settings/printer',
        data: {
          'paper_size': paperSizeStr,
          'printer_name': config.name,
          'printer_mac_address': config.address,
          'auto_cut': config.autoCut,
          'open_cash_drawer': config.openCashDrawer,
        },
      );
      debugPrint('Printer paper size successfully synced to central backend: $paperSizeStr');
    } catch (e) {
      debugPrint('Failed to sync printer settings to backend (offline or error): $e');
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

  Future<void> updateNotes({String? storeName, String? headerNote, String? footerNote}) async {
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

class AvailablePrintersNotifier extends AsyncNotifier<List<DiscoveredPrinterInfo>> {
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
    AsyncNotifierProvider<AvailablePrintersNotifier, List<DiscoveredPrinterInfo>>(
  AvailablePrintersNotifier.new,
);
