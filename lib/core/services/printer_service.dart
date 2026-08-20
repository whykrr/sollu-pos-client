import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:printing/printing.dart';
import 'package:sollu_pos_client/core/database/app_database.dart';
import 'package:sollu_pos_client/core/models/printer_model.dart';
import 'package:sollu_pos_client/core/services/receipt_pdf_builder.dart';
import 'package:sollu_pos_client/core/utils/currency_formatter.dart';
import 'package:sollu_pos_client/features/pos/data/transaction_repository.dart';
import 'package:sollu_pos_client/features/shift/data/shift_repository.dart';

class PrinterService {
  CapabilityProfile? _profile;

  Future<CapabilityProfile> _getProfile() async {
    _profile ??= await CapabilityProfile.load();
    return _profile!;
  }

  /// Memeriksa apakah platform saat ini adalah platform Desktop
  bool get isDesktopPlatform => Platform.isWindows || Platform.isMacOS || Platform.isLinux;

  /// Memeriksa apakah platform saat ini adalah Mobile (Android / iOS)
  bool get isMobilePlatform => Platform.isAndroid || Platform.isIOS;

  /// Memeriksa dan meminta izin Bluetooth & Lokasi (khusus Mobile)
  Future<bool> checkAndRequestPermissions() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return true;
    }

    try {
      if (Platform.isAndroid) {
        Map<Permission, PermissionStatus> statuses = await [
          Permission.bluetoothScan,
          Permission.bluetoothConnect,
          Permission.location,
        ].request();

        final bluetoothScanGranted = statuses[Permission.bluetoothScan]?.isGranted ?? true;
        final bluetoothConnectGranted = statuses[Permission.bluetoothConnect]?.isGranted ?? true;
        final locationGranted = statuses[Permission.location]?.isGranted ?? true;

        return (bluetoothScanGranted && bluetoothConnectGranted) || locationGranted;
      }
      return true;
    } catch (e) {
      debugPrint('Error requesting permissions: $e');
      return false;
    }
  }

  /// Cek apakah Bluetooth di perangkat aktif
  Future<bool> isBluetoothEnabled() async {
    if (!isMobilePlatform) return true;
    try {
      return await PrintBluetoothThermal.bluetoothEnabled;
    } catch (e) {
      debugPrint('Error checking bluetooth enabled: $e');
      return false;
    }
  }

  /// Mengambil daftar printer yang tersedia secara adaptif berdasarkan platform OS
  Future<List<DiscoveredPrinterInfo>> getAvailablePrinters() async {
    final List<DiscoveredPrinterInfo> result = [];

    // 1. Desktop (Windows / macOS / Linux): Ambil dari System Print Spooler / USB Driver
    if (isDesktopPlatform) {
      try {
        final printers = await Printing.listPrinters();
        for (final p in printers) {
          result.add(
            DiscoveredPrinterInfo(
              name: p.name,
              address: p.url,
              connectionType: PrinterConnectionType.system,
              isDefault: p.isDefault,
              location: p.location,
            ),
          );
        }
      } catch (e) {
        debugPrint('Error listing desktop printers: $e');
      }
      return result;
    }

    // 2. Mobile (Android / iOS): Ambil dari Bluetooth Paired
    if (isMobilePlatform) {
      final hasPermission = await checkAndRequestPermissions();
      if (hasPermission) {
        try {
          final List<BluetoothInfo> list = await PrintBluetoothThermal.pairedBluetooths;
          for (final d in list) {
            result.add(
              DiscoveredPrinterInfo(
                name: d.name.isNotEmpty ? d.name : 'Unknown Device',
                address: d.macAdress,
                connectionType: PrinterConnectionType.bluetooth,
              ),
            );
          }
        } catch (e) {
          debugPrint('Error getting bluetooth paired devices: $e');
        }
      }
    }

    return result;
  }

  /// Kirim byte ESC/POS langsung ke printer jaringan melalui Socket TCP (Port 9100)
  Future<({bool success, String message})> sendToNetworkPrinter({
    required String ipAddress,
    int port = 9100,
    required List<int> bytes,
  }) async {
    Socket? socket;
    try {
      socket = await Socket.connect(
        ipAddress,
        port,
        timeout: const Duration(seconds: 4),
      );
      socket.add(bytes);
      await socket.flush();
      await socket.close();
      return (success: true, message: 'Berhasil mengirim data ke printer jaringan $ipAddress:$port');
    } catch (e) {
      debugPrint('Error sending bytes to network printer ($ipAddress:$port): $e');
      return (success: false, message: 'Gagal menghubungkan ke printer jaringan ($ipAddress:$port): $e');
    } finally {
      socket?.destroy();
    }
  }

  /// Hubungkan ke printer Bluetooth
  Future<bool> connectBluetooth(String macAddress) async {
    try {
      final connected = await PrintBluetoothThermal.connectionStatus;
      if (connected) return true;
      return await PrintBluetoothThermal.connect(macPrinterAddress: macAddress);
    } catch (e) {
      debugPrint('Error connecting to bluetooth: $e');
      return false;
    }
  }

  /// Menghasilkan byte untuk Test Print ESC/POS (Bluetooth & Network)
  Future<List<int>> generateTestReceiptBytes(PrinterConfig config) async {
    final profile = await _getProfile();
    final paperSize = config.paperSize == PrinterPaperSize.mm58 ? PaperSize.mm58 : PaperSize.mm80;
    final generator = Generator(paperSize, profile);
    List<int> bytes = [];

    bytes += generator.reset();
    
    // Header
    bytes += generator.text(
      config.storeName ?? 'SOLLU POS',
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );
    bytes += generator.text(
      'UJI COBA CETAK STRUK',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.text(
      DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now()),
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.hr();

    // Body
    bytes += generator.text('Status: TERHUBUNG', styles: const PosStyles(bold: true));
    bytes += generator.text('Printer: ${config.name}');
    bytes += generator.text('Tipe: ${config.connectionType.label}');
    bytes += generator.text('Alamat/IP: ${config.address}');
    bytes += generator.text('Ukuran Kertas: ${config.paperSize.label}');
    bytes += generator.hr();

    bytes += generator.row([
      PosColumn(text: 'Item Contoh A x1', width: 8),
      PosColumn(
        text: 'Rp 15.000',
        width: 4,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(text: 'Item Contoh B x2', width: 8),
      PosColumn(
        text: 'Rp 20.000',
        width: 4,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.hr();
    bytes += generator.row([
      PosColumn(text: 'TOTAL', width: 6, styles: const PosStyles(bold: true)),
      PosColumn(
        text: 'Rp 35.000',
        width: 6,
        styles: const PosStyles(align: PosAlign.right, bold: true),
      ),
    ]);
    bytes += generator.hr();

    // Footer
    bytes += generator.text(
      config.footerNote ?? 'Printer siap digunakan untuk transaksi!',
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.feed(2);

    if (config.autoCut) {
      bytes += generator.cut();
    }

    return bytes;
  }

  /// Menghasilkan bytes struk transaksi resmi ESC/POS (Bluetooth & Network)
  Future<List<int>> generateTransactionReceiptBytes({
    required TransactionDetailData detail,
    required PrinterConfig config,
    OutletSetting? outletSetting,
    Uint8List? logoBytes,
    String? cashierName,
    String? outletName,
    String? outletAddress,
    String? outletPhone,
  }) async {
    final profile = await _getProfile();
    final paperSize = config.paperSize == PrinterPaperSize.mm58 ? PaperSize.mm58 : PaperSize.mm80;
    final generator = Generator(paperSize, profile);
    List<int> bytes = [];

    bytes += generator.reset();

    // 0. Logo Toko
    if ((outletSetting?.showLogo ?? true) && logoBytes != null) {
      try {
        final decoded = img.decodeImage(logoBytes);
        if (decoded != null) {
          final targetWidth = config.paperSize == PrinterPaperSize.mm58 ? 160 : 220;
          final resized = img.copyResize(decoded, width: targetWidth);
          bytes += generator.imageRaster(resized, align: PosAlign.center);
          bytes += generator.emptyLines(1);
        }
      } catch (e) {
        debugPrint('Error rasterizing logo for ESC/POS: $e');
      }
    }

    // 1. Header Toko
    final displayName = (outletSetting?.customHeaderTitle != null && outletSetting!.customHeaderTitle!.isNotEmpty)
        ? outletSetting.customHeaderTitle!
        : (outletName ?? config.storeName ?? 'SOLLU POS');
    bytes += generator.text(
      displayName,
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );

    if ((outletSetting?.showAddress ?? true) && outletAddress != null && outletAddress.isNotEmpty) {
      bytes += generator.text(
        outletAddress,
        styles: const PosStyles(align: PosAlign.center),
      );
    }
    if ((outletSetting?.showPhone ?? true) && outletPhone != null && outletPhone.isNotEmpty) {
      bytes += generator.text(
        'Telp: $outletPhone',
        styles: const PosStyles(align: PosAlign.center),
      );
    }

    final headerNote = outletSetting?.headerNotes ?? config.headerNote;
    if (headerNote != null && headerNote.isNotEmpty) {
      bytes += generator.text(
        headerNote,
        styles: const PosStyles(align: PosAlign.center),
      );
    }

    if (outletSetting?.wifiInfo != null && outletSetting!.wifiInfo!.isNotEmpty) {
      bytes += generator.text(
        'WiFi: ${outletSetting.wifiInfo}',
        styles: const PosStyles(align: PosAlign.center),
      );
    }

    bytes += generator.hr();

    // 2. Info Transaksi
    final tx = detail.transaction;
    bytes += generator.row([
      PosColumn(text: 'No: ${tx.transactionNumber}', width: 8),
      PosColumn(
        text: DateFormat('dd/MM/yy HH:mm').format(tx.createdAt),
        width: 4,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    if ((outletSetting?.showCashierName ?? true) && cashierName != null && cashierName.isNotEmpty) {
      bytes += generator.text('Kasir: $cashierName');
    }

    if ((outletSetting?.showCustomerName ?? true) && detail.customer != null) {
      bytes += generator.text('Pelanggan: ${detail.customer!.name}');
    }

    bytes += generator.hr();

    // 3. Daftar Item
    for (final item in detail.items) {
      bytes += generator.text(
        item.productName,
        styles: const PosStyles(bold: true),
      );

      final qtyStr = item.qty % 1 == 0 ? item.qty.toInt().toString() : item.qty.toString();
      final priceStr = CurrencyFormatter.format(item.price.toInt());
      final subtotalStr = CurrencyFormatter.format(item.subtotal.toInt());

      bytes += generator.row([
        PosColumn(text: '$qtyStr x $priceStr', width: 7),
        PosColumn(
          text: subtotalStr,
          width: 5,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);

      // Modifiers / Extra
      if (outletSetting?.showModifiers ?? true) {
        final modifiers = detail.modifiersByItemId[item.id] ?? [];
        for (final mod in modifiers) {
          final modPrice = mod.price > 0 ? ' (+${CurrencyFormatter.format(mod.price.toInt())})' : '';
          bytes += generator.text('  + ${mod.modifierName}$modPrice');
        }
      }

      // Catatan Item
      if ((outletSetting?.showItemNotes ?? true) && item.notes != null && item.notes!.isNotEmpty) {
        bytes += generator.text('  * ${item.notes}');
      }

      // Diskon per item jika ada
      if (item.discountAmount > 0) {
        bytes += generator.row([
          PosColumn(text: '  Diskon Item', width: 7),
          PosColumn(
            text: '-${CurrencyFormatter.format(item.discountAmount.toInt())}',
            width: 5,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]);
      }
    }

    bytes += generator.hr();

    // 4. Perhitungan Finansial
    bytes += generator.row([
      PosColumn(text: 'Subtotal', width: 6),
      PosColumn(
        text: CurrencyFormatter.format(tx.subtotal.toInt()),
        width: 6,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    if (tx.discountAmount > 0) {
      final promoLabel = tx.promoName != null ? 'Diskon (${tx.promoName})' : 'Diskon';
      bytes += generator.row([
        PosColumn(text: promoLabel, width: 6),
        PosColumn(
          text: '-${CurrencyFormatter.format(tx.discountAmount.toInt())}',
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }

    if ((outletSetting?.showTaxDetail ?? true) && tx.taxAmount > 0) {
      bytes += generator.row([
        PosColumn(text: 'Pajak (PB1/PPN)', width: 6),
        PosColumn(
          text: CurrencyFormatter.format(tx.taxAmount.toInt()),
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }

    if ((outletSetting?.showServiceCharge ?? true) && tx.serviceChargeAmount > 0) {
      bytes += generator.row([
        PosColumn(text: 'Service Charge', width: 6),
        PosColumn(
          text: CurrencyFormatter.format(tx.serviceChargeAmount.toInt()),
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }

    bytes += generator.hr();

    // Total
    bytes += generator.row([
      PosColumn(text: 'TOTAL', width: 6, styles: const PosStyles(bold: true, height: PosTextSize.size1)),
      PosColumn(
        text: CurrencyFormatter.format(tx.total.toInt()),
        width: 6,
        styles: const PosStyles(align: PosAlign.right, bold: true, height: PosTextSize.size1),
      ),
    ]);

    // 5. Pembayaran
    if (detail.payments.isNotEmpty) {
      for (final payment in detail.payments) {
        final methodName = detail.paymentMethod?.name ?? 'Pembayaran';
        bytes += generator.row([
          PosColumn(text: methodName, width: 6),
          PosColumn(
            text: CurrencyFormatter.format(payment.amount.toInt()),
            width: 6,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]);

        if (payment.changeAmount > 0) {
          bytes += generator.row([
            PosColumn(text: 'Kembalian', width: 6),
            PosColumn(
              text: CurrencyFormatter.format(payment.changeAmount.toInt()),
              width: 6,
              styles: const PosStyles(align: PosAlign.right),
            ),
          ]);
        }
      }
    }

    bytes += generator.hr();

    // 6. Footer
    final footer = outletSetting?.footerNotes ?? config.footerNote ?? 'Terima Kasih Telah Berbelanja!';
    bytes += generator.text(
      footer,
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );

    if (outletSetting?.socialMediaInfo != null && outletSetting!.socialMediaInfo!.isNotEmpty) {
      bytes += generator.text(
        outletSetting.socialMediaInfo!,
        styles: const PosStyles(align: PosAlign.center),
      );
    }

    bytes += generator.text(
      'Simpan struk ini sebagai bukti pembayaran yang sah',
      styles: const PosStyles(align: PosAlign.center),
    );

    if (outletSetting?.showQrCode ?? false) {
      bytes += generator.qrcode(tx.transactionNumber, size: QRSize.size4);
    }

    bytes += generator.feed(2);

    if (config.autoCut) {
      bytes += generator.cut();
    }

    return bytes;
  }

  /// Eksekusi Test Print Multiplatform (Bluetooth, System Spooler OS, atau Network TCP)
  Future<({bool success, String message})> printTest(PrinterConfig config) async {
    if (config.address.isEmpty && (config.ipAddress == null || config.ipAddress!.isEmpty)) {
      return (success: false, message: 'Alamat / Identitas printer tidak valid!');
    }

    // A. Mode SYSTEM (Windows / macOS Print Spooler)
    if (config.connectionType == PrinterConnectionType.system) {
      try {
        final pdfBytes = await ReceiptPdfBuilder.buildTestReceiptPdf(config);
        final printer = Printer(url: config.address, name: config.name);
        final bool printSuccess = await Printing.directPrintPdf(
          printer: printer,
          onLayout: (format) async => pdfBytes,
          name: 'Test_Receipt_${config.name}',
          usePrinterSettings: true,
        );
        if (printSuccess) {
          return (success: true, message: 'Uji cetak berhasil dikirim ke printer OS!');
        } else {
          return (success: false, message: 'Gagal mengirim tugas cetak ke printer OS!');
        }
      } catch (e) {
        debugPrint('Error printing test on desktop OS: $e');
        return (success: false, message: 'Error cetak desktop: $e');
      }
    }

    // B. Mode NETWORK (LAN / WiFi Socket TCP Port 9100)
    if (config.connectionType == PrinterConnectionType.network) {
      final ip = config.ipAddress ?? config.address;
      final bytes = await generateTestReceiptBytes(config);
      return await sendToNetworkPrinter(
        ipAddress: ip,
        port: config.port,
        bytes: bytes,
      );
    }

    // C. Mode BLUETOOTH (Mobile)
    final isBluetoothOn = await isBluetoothEnabled();
    if (!isBluetoothOn) {
      return (success: false, message: 'Bluetooth perangkat belum dinyalakan!');
    }

    final connected = await connectBluetooth(config.address);
    if (!connected) {
      return (success: false, message: 'Gagal menghubungkan ke printer Bluetooth ${config.name}');
    }

    final bytes = await generateTestReceiptBytes(config);
    final printSuccess = await PrintBluetoothThermal.writeBytes(bytes);

    if (printSuccess) {
      return (success: true, message: 'Uji cetak Bluetooth berhasil!');
    } else {
      return (success: false, message: 'Gagal mengirim data ke printer Bluetooth!');
    }
  }

  /// Eksekusi Cetak Struk Transaksi Multiplatform
  Future<({bool success, String message})> printTransactionReceipt({
    required TransactionDetailData detail,
    required PrinterConfig config,
    OutletSetting? outletSetting,
    Uint8List? logoBytes,
    String? cashierName,
    String? outletName,
    String? outletAddress,
    String? outletPhone,
  }) async {
    if (config.address.isEmpty && (config.ipAddress == null || config.ipAddress!.isEmpty)) {
      return (success: false, message: 'Printer belum dipilih di Pengaturan Printer!');
    }

    // A. Mode SYSTEM (Windows / macOS Print Spooler)
    if (config.connectionType == PrinterConnectionType.system) {
      try {
        final pdfBytes = await ReceiptPdfBuilder.buildTransactionReceiptPdf(
          detail: detail,
          config: config,
          outletSetting: outletSetting,
          logoBytes: logoBytes,
          cashierName: cashierName,
          outletName: outletName,
          outletAddress: outletAddress,
          outletPhone: outletPhone,
        );
        final printer = Printer(url: config.address, name: config.name);
        final bool printSuccess = await Printing.directPrintPdf(
          printer: printer,
          onLayout: (format) async => pdfBytes,
          name: 'Struk_${detail.transaction.transactionNumber}',
          usePrinterSettings: true,
        );
        if (printSuccess) {
          return (success: true, message: 'Struk berhasil dicetak!');
        } else {
          return (success: false, message: 'Gagal mencetak struk ke printer OS!');
        }
      } catch (e) {
        debugPrint('Error printing transaction on desktop OS: $e');
        return (success: false, message: 'Error cetak struk: $e');
      }
    }

    // B. Mode NETWORK (LAN / WiFi Socket TCP Port 9100)
    if (config.connectionType == PrinterConnectionType.network) {
      final ip = config.ipAddress ?? config.address;
      final bytes = await generateTransactionReceiptBytes(
        detail: detail,
        config: config,
        outletSetting: outletSetting,
        logoBytes: logoBytes,
        cashierName: cashierName,
        outletName: outletName,
        outletAddress: outletAddress,
        outletPhone: outletPhone,
      );
      final netResult = await sendToNetworkPrinter(
        ipAddress: ip,
        port: config.port,
        bytes: bytes,
      );
      if (netResult.success) {
        return (success: true, message: 'Struk berhasil dicetak ke printer jaringan!');
      } else {
        return netResult;
      }
    }

    // C. Mode BLUETOOTH (Mobile)
    final isBluetoothOn = await isBluetoothEnabled();
    if (!isBluetoothOn) {
      return (success: false, message: 'Bluetooth perangkat belum dinyalakan!');
    }

    final connected = await connectBluetooth(config.address);
    if (!connected) {
      return (success: false, message: 'Gagal menghubungkan ke printer ${config.name}');
    }

    final bytes = await generateTransactionReceiptBytes(
      detail: detail,
      config: config,
      outletSetting: outletSetting,
      logoBytes: logoBytes,
      cashierName: cashierName,
      outletName: outletName,
      outletAddress: outletAddress,
      outletPhone: outletPhone,
    );

    final printSuccess = await PrintBluetoothThermal.writeBytes(bytes);
    if (printSuccess) {
      return (success: true, message: 'Struk berhasil dicetak!');
    } else {
      return (success: false, message: 'Gagal mencetak struk Bluetooth!');
    }
  }

  /// Menghasilkan byte untuk cetak laporan tutup shift
  Future<List<int>> generateShiftReportBytes({
    required ShiftSummary summary,
    required PrinterConfig config,
    String? cashierName,
    String? outletName,
    String? outletAddress,
    String? outletPhone,
  }) async {
    final profile = await _getProfile();
    final paperSize = config.paperSize == PrinterPaperSize.mm58 ? PaperSize.mm58 : PaperSize.mm80;
    final generator = Generator(paperSize, profile);
    List<int> bytes = [];

    bytes += generator.reset();

    // 1. Header Toko
    final displayName = outletName ?? config.storeName ?? 'SOLLU POS';
    bytes += generator.text(
      displayName,
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );

    if (outletAddress != null && outletAddress.isNotEmpty) {
      bytes += generator.text(
        outletAddress,
        styles: const PosStyles(align: PosAlign.center),
      );
    }
    if (outletPhone != null && outletPhone.isNotEmpty) {
      bytes += generator.text(
        'Telp: $outletPhone',
        styles: const PosStyles(align: PosAlign.center),
      );
    }

    bytes += generator.hr();

    bytes += generator.text(
      'LAPORAN TUTUP SHIFT',
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
      ),
    );

    bytes += generator.feed(1);

    bytes += generator.row([
      PosColumn(text: 'Waktu Cetak:', width: 5),
      PosColumn(
        text: DateFormat('dd/MM/yy HH:mm').format(DateTime.now()),
        width: 7,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    if (cashierName != null && cashierName.isNotEmpty) {
      bytes += generator.row([
        PosColumn(text: 'Kasir:', width: 5),
        PosColumn(
          text: cashierName,
          width: 7,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }

    bytes += generator.hr();

    // 2. Rincian Laporan
    bytes += generator.row([
      PosColumn(text: 'Modal Awal', width: 6),
      PosColumn(
        text: CurrencyFormatter.format(summary.openingCash.toInt()),
        width: 6,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.feed(1);
    bytes += generator.text('Pemasukan per Metode:', styles: const PosStyles(bold: true));
    
    for (final entry in summary.salesByPaymentMethod.entries) {
      bytes += generator.row([
        PosColumn(text: '- ${entry.key}', width: 6),
        PosColumn(
          text: CurrencyFormatter.format(entry.value.toInt()),
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }

    bytes += generator.feed(1);
    bytes += generator.row([
      PosColumn(text: 'Kas Masuk/Keluar', width: 6),
      PosColumn(
        text: CurrencyFormatter.format((summary.cashIn - summary.cashOut).toInt()),
        width: 6,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.hr();

    bytes += generator.row([
      PosColumn(text: 'Ekspektasi Kas Laci', width: 6, styles: const PosStyles(bold: true)),
      PosColumn(
        text: CurrencyFormatter.format(summary.expectedCash.toInt()),
        width: 6,
        styles: const PosStyles(align: PosAlign.right, bold: true),
      ),
    ]);

    bytes += generator.hr();

    bytes += generator.text(
      'Laporan ini dicetak secara otomatis\ndari sistem Sollu POS.',
      styles: const PosStyles(align: PosAlign.center),
    );

    bytes += generator.feed(2);

    if (config.autoCut) {
      bytes += generator.cut();
    }

    return bytes;
  }

  /// Eksekusi Cetak Laporan Tutup Shift
  Future<({bool success, String message})> printShiftReport({
    required ShiftSummary summary,
    required PrinterConfig config,
    String? cashierName,
    String? outletName,
    String? outletAddress,
    String? outletPhone,
  }) async {
    if (config.address.isEmpty && (config.ipAddress == null || config.ipAddress!.isEmpty)) {
      return (success: false, message: 'Printer belum dipilih di Pengaturan Printer!');
    }

    // A. Mode SYSTEM (Windows / macOS Print Spooler)
    if (config.connectionType == PrinterConnectionType.system) {
      try {
        final pdfBytes = await ReceiptPdfBuilder.buildShiftReportPdf(
          summary: summary,
          config: config,
          cashierName: cashierName,
          outletName: outletName,
          outletAddress: outletAddress,
          outletPhone: outletPhone,
        );
        final printer = Printer(url: config.address, name: config.name);
        final bool printSuccess = await Printing.directPrintPdf(
          printer: printer,
          onLayout: (format) async => pdfBytes,
          name: 'Shift_Report_${DateTime.now().millisecondsSinceEpoch}',
          usePrinterSettings: true,
        );
        if (printSuccess) {
          return (success: true, message: 'Laporan shift berhasil dicetak!');
        } else {
          return (success: false, message: 'Gagal mencetak laporan ke printer OS!');
        }
      } catch (e) {
        debugPrint('Error printing shift report on desktop OS: $e');
        return (success: false, message: 'Error cetak laporan: $e');
      }
    }

    // B. Mode NETWORK
    if (config.connectionType == PrinterConnectionType.network) {
      final ip = config.ipAddress ?? config.address;
      final bytes = await generateShiftReportBytes(
        summary: summary,
        config: config,
        cashierName: cashierName,
        outletName: outletName,
        outletAddress: outletAddress,
        outletPhone: outletPhone,
      );
      final netResult = await sendToNetworkPrinter(
        ipAddress: ip,
        port: config.port,
        bytes: bytes,
      );
      if (netResult.success) {
        return (success: true, message: 'Laporan berhasil dicetak ke printer jaringan!');
      } else {
        return netResult;
      }
    }

    // C. Mode BLUETOOTH
    final isBluetoothOn = await isBluetoothEnabled();
    if (!isBluetoothOn) {
      return (success: false, message: 'Bluetooth perangkat belum dinyalakan!');
    }

    final connected = await connectBluetooth(config.address);
    if (!connected) {
      return (success: false, message: 'Gagal menghubungkan ke printer ${config.name}');
    }

    final bytes = await generateShiftReportBytes(
      summary: summary,
      config: config,
      cashierName: cashierName,
      outletName: outletName,
      outletAddress: outletAddress,
      outletPhone: outletPhone,
    );

    final printSuccess = await PrintBluetoothThermal.writeBytes(bytes);
    if (printSuccess) {
      return (success: true, message: 'Laporan shift berhasil dicetak!');
    } else {
      return (success: false, message: 'Gagal mencetak laporan Bluetooth!');
    }
  }

  /// Eksekusi perintah pembukaan Cash Drawer (Laci Uang)
  Future<({bool success, String message})> openCashDrawer(PrinterConfig config) async {
    if (config.address.isEmpty && (config.ipAddress == null || config.ipAddress!.isEmpty)) {
      return (success: false, message: 'Printer belum dipilih di Pengaturan Printer!');
    }

    final profile = await _getProfile();
    final paperSize = config.paperSize == PrinterPaperSize.mm58 ? PaperSize.mm58 : PaperSize.mm80;
    final generator = Generator(paperSize, profile);
    
    // Command standar ESC/POS untuk membuka laci (drawer kick)
    List<int> bytes = [];
    bytes += generator.drawer();

    // A. Mode NETWORK (LAN / WiFi Socket TCP Port 9100)
    if (config.connectionType == PrinterConnectionType.network) {
      final ip = config.ipAddress ?? config.address;
      final netResult = await sendToNetworkPrinter(
        ipAddress: ip,
        port: config.port,
        bytes: bytes,
      );
      if (netResult.success) {
        return (success: true, message: 'Laci uang berhasil dibuka (Network)!');
      } else {
        return netResult;
      }
    }

    // B. Mode BLUETOOTH (Mobile)
    if (config.connectionType == PrinterConnectionType.bluetooth) {
      final isBluetoothOn = await isBluetoothEnabled();
      if (!isBluetoothOn) {
        return (success: false, message: 'Bluetooth perangkat belum dinyalakan!');
      }

      final connected = await connectBluetooth(config.address);
      if (!connected) {
        return (success: false, message: 'Gagal menghubungkan ke printer Bluetooth ${config.name}');
      }

      final printSuccess = await PrintBluetoothThermal.writeBytes(bytes);
      if (printSuccess) {
        return (success: true, message: 'Laci uang berhasil dibuka (Bluetooth)!');
      } else {
        return (success: false, message: 'Gagal mengirim perintah ke printer Bluetooth!');
      }
    }

    // C. Mode SYSTEM (Desktop Print Spooler)
    // Sebagian besar spooler sistem operasi tidak mengizinkan pengiriman raw bytes secara langsung.
    return (success: false, message: 'Printer mode sistem tidak mendukung fungsi drawer langsung. Harap gunakan koneksi Bluetooth/Network.');
  }
}
