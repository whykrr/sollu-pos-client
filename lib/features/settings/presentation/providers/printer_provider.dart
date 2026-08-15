import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sollu_pos_client/core/models/printer_model.dart';
import 'package:sollu_pos_client/core/providers/preferences_provider.dart';
import 'package:sollu_pos_client/core/services/printer_service.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/transaction_provider.dart';

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

  final service = ref.read(printerServiceProvider);
  return await service.printTransactionReceipt(
    detail: detail,
    config: printerConfig,
    cashierName: cashierName,
    outletName: outletName,
    outletAddress: outletAddress,
    outletPhone: outletPhone,
  );
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
