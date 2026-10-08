import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:printing/printing.dart';

import 'package:sollu_pos_client/core/models/printer_model.dart';
import 'package:sollu_pos_client/core/services/desktop_raw_printer.dart';
import 'package:sollu_pos_client/core/services/printer_image_utils.dart';
import 'package:sollu_pos_client/core/utils/currency_formatter.dart';
import 'package:sollu_pos_client/features/pos/data/transaction_repository.dart';
import 'package:sollu_pos_client/features/shift/data/shift_repository.dart';

class PrinterService {
  // Image cache
  String? _lastLogoHash;
  int? _lastLogoWidth;
  List<int>? _cachedLogoRasterBytes;

  Future<List<int>?> _getLogoRasterBytes(
    Uint8List bytes,
    int width,
    Generator generator,
  ) async {
    final hash =
        '${bytes.length}_${bytes.isNotEmpty ? bytes[0] : 0}_${bytes.length > 50 ? bytes[50] : 0}_${bytes.length > 100 ? bytes[100] : 0}_${bytes.last}';
    if (_lastLogoHash == hash &&
        _lastLogoWidth == width &&
        _cachedLogoRasterBytes != null) {
      return _cachedLogoRasterBytes;
    }

    final resized = await compute(processReceiptLogo, {
      'bytes': bytes,
      'paperWidthDots': width,
      'width': width,
    });

    if (resized != null) {
      // Use ESC * bit-image mode (generator.image) for 100% universal thermal printer hardware compatibility
      final rasterBytes = generator.image(resized);

      _lastLogoHash = hash;
      _lastLogoWidth = width;
      _cachedLogoRasterBytes = rasterBytes;
      return rasterBytes;
    }
    return null;
  }

  CapabilityProfile? _profile;

  Future<CapabilityProfile> _getProfile() async {
    _profile ??= await CapabilityProfile.load();
    return _profile!;
  }

  /// Memeriksa apakah platform saat ini adalah platform Desktop
  bool get isDesktopPlatform =>
      Platform.isWindows || Platform.isMacOS || Platform.isLinux;

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

        final bluetoothScanGranted =
            statuses[Permission.bluetoothScan]?.isGranted ?? true;
        final bluetoothConnectGranted =
            statuses[Permission.bluetoothConnect]?.isGranted ?? true;
        final locationGranted =
            statuses[Permission.location]?.isGranted ?? true;

        return (bluetoothScanGranted && bluetoothConnectGranted) ||
            locationGranted;
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
          final List<BluetoothInfo> list =
              await PrintBluetoothThermal.pairedBluetooths;
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
      return (
        success: true,
        message: 'Berhasil mengirim data ke printer jaringan $ipAddress:$port',
      );
    } catch (e) {
      debugPrint(
        'Error sending bytes to network printer ($ipAddress:$port): $e',
      );
      return (
        success: false,
        message:
            'Gagal menghubungkan ke printer jaringan ($ipAddress:$port): $e',
      );
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

  /// Menghasilkan byte untuk Live Setup Test Print ESC/POS sesuai format riil toko
  Future<List<int>> generateTestReceiptBytes(
    PrinterConfig config, {
    Map<String, dynamic>? outletProfile,
    Map<String, dynamic>? outletSetting,
    Uint8List? logoBytes,
  }) async {
    final profile = await _getProfile();
    final paperSize = config.paperSize == PrinterPaperSize.mm58
        ? PaperSize.mm58
        : PaperSize.mm80;
    final generator = Generator(paperSize, profile);
    List<int> bytes = [];

    const regular = PosStyles(fontType: PosFontType.fontB);
    const bold = PosStyles(fontType: PosFontType.fontB, bold: true);
    const center = PosStyles(
      fontType: PosFontType.fontB,
      align: PosAlign.center,
    );
    const right = PosStyles(fontType: PosFontType.fontB, align: PosAlign.right);
    const rightBold = PosStyles(
      fontType: PosFontType.fontB,
      align: PosAlign.right,
      bold: true,
    );
    const header = PosStyles(
      fontType: PosFontType.fontA,
      align: PosAlign.center,
      bold: true,
    );

    bytes += generator.reset();

    // 1. Banner Test Print
    bytes += generator.text(
      '*** TEST PRINT / UJI STRUK ***',
      styles: const PosStyles(
        fontType: PosFontType.fontB,
        align: PosAlign.center,
        bold: true,
      ),
    );
    bytes += generator.feed(1);

    // 2. Logo Toko Riil
    final rawShowLogo =
        outletSetting?['show_logo'] ?? outletSetting?['showLogo'];
    final bool showLogo =
        rawShowLogo == true ||
        rawShowLogo == 1 ||
        rawShowLogo == '1' ||
        rawShowLogo == null;
    if (showLogo && logoBytes != null) {
      try {
        final paperWidthDots = config.paperSize == PrinterPaperSize.mm58
            ? 384
            : 576;
        final rasterBytes = await _getLogoRasterBytes(
          logoBytes,
          paperWidthDots,
          generator,
        );
        if (rasterBytes != null) {
          bytes += rasterBytes;
        }
      } catch (e) {
        debugPrint('Error rasterizing logo in test print: $e');
      }
    }

    // 3. Nama Toko Riil
    final String customHeader =
        outletSetting?['custom_header_title']?.toString() ??
        outletSetting?['customHeaderTitle']?.toString() ??
        '';
    final String profileName = outletProfile?['name']?.toString() ?? '';
    final displayName = customHeader.isNotEmpty
        ? customHeader
        : (profileName.isNotEmpty
            ? profileName
            : (config.storeName ?? 'SOLLU POS STORE'));
    bytes += generator.text(displayName.toUpperCase(), styles: header);

    // 4. Detail Alamat & Kontak Riil
    final String address =
        outletProfile?['address']?.toString() ?? 'Alamat Outlet Toko';
    final String phone = outletProfile?['phone']?.toString() ?? '';
    final String email = outletProfile?['email']?.toString() ?? '';

    bool showAddress =
        (outletSetting?['show_address'] as bool?) ??
        (outletSetting?['showAddress'] as bool?) ??
        true;
    if (showAddress && address.isNotEmpty) {
      bytes += generator.text(address, styles: center);
    }

    bool showPhone =
        (outletSetting?['show_phone'] as bool?) ??
        (outletSetting?['showPhone'] as bool?) ??
        true;
    if (showPhone && phone.isNotEmpty) {
      bytes += generator.text('Telp: $phone', styles: center);
    }

    bool showEmail =
        (outletSetting?['show_email'] as bool?) ??
        (outletSetting?['showEmail'] as bool?) ??
        false;
    if (showEmail && email.isNotEmpty) {
      bytes += generator.text('Email: $email', styles: center);
    }

    // 5. Header Notes Riil
    final headerNote =
        (outletSetting?['header_notes']?.toString()) ??
        (outletSetting?['headerNotes']?.toString()) ??
        config.headerNote;
    if (headerNote != null && headerNote.isNotEmpty) {
      bytes += generator.text(headerNote, styles: center);
    }

    bytes += generator.hr();

    // 6. Metadata Transaksi Simulasi
    bytes += generator.row([
      PosColumn(text: 'No: SIMULASI/TEST/01', width: 7, styles: regular),
      PosColumn(
        text: DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
        width: 5,
        styles: right,
      ),
    ]);
    bytes += generator.row([
      PosColumn(text: 'Kasir: Kasir Uji Coba', width: 7, styles: regular),
      PosColumn(text: 'Dine In', width: 5, styles: rightBold),
    ]);
    bytes += generator.text('Pelanggan: Tamu Umum', styles: regular);

    bytes += generator.hr();

    // 7. Item Belanja Simulasi
    bytes += generator.text('Kopi Susu Aren (Reguler)', styles: regular);
    bytes += generator.row([
      PosColumn(text: '2 x Rp 25.000', width: 7, styles: regular),
      PosColumn(text: 'Rp 50.000', width: 5, styles: right),
    ]);
    bytes += generator.text('  + Less Sugar, Extra Shot', styles: regular);

    bytes += generator.text('Croissant Butter Pastry', styles: regular);
    bytes += generator.row([
      PosColumn(text: '1 x Rp 28.000', width: 7, styles: regular),
      PosColumn(text: 'Rp 28.000', width: 5, styles: right),
    ]);

    bytes += generator.hr();

    // 8. Kalkulasi Pajak & Service Charge Riil
    const double subtotal = 78000;
    final double taxPct = double.tryParse(
      (outletSetting?['tax_percentage'] ??
              outletSetting?['taxPercentage'] ??
              11)
          .toString(),
    ) ?? 11.0;
    final double servicePct = double.tryParse(
      (outletSetting?['service_charge_percentage'] ??
              outletSetting?['serviceChargePercentage'] ??
              5)
          .toString(),
    ) ?? 5.0;

    final double taxAmount = subtotal * (taxPct / 100);
    final double serviceAmount = subtotal * (servicePct / 100);
    final double totalAmount = subtotal + taxAmount + serviceAmount;

    bytes += generator.row([
      PosColumn(text: 'Subtotal', width: 6, styles: regular),
      PosColumn(
        text: CurrencyFormatter.format(subtotal.toInt()),
        width: 6,
        styles: right,
      ),
    ]);

    if (serviceAmount > 0) {
      bytes += generator.row([
        PosColumn(
          text: 'Service Fee (${servicePct.toInt()}%)',
          width: 7,
          styles: regular,
        ),
        PosColumn(
          text: CurrencyFormatter.format(serviceAmount.toInt()),
          width: 5,
          styles: right,
        ),
      ]);
    }

    if (taxAmount > 0) {
      bytes += generator.row([
        PosColumn(
          text: 'Pajak PPN (${taxPct.toInt()}%)',
          width: 7,
          styles: regular,
        ),
        PosColumn(
          text: CurrencyFormatter.format(taxAmount.toInt()),
          width: 5,
          styles: right,
        ),
      ]);
    }

    bytes += generator.hr();
    bytes += generator.row([
      PosColumn(text: 'TOTAL', width: 6, styles: bold),
      PosColumn(
        text: CurrencyFormatter.format(totalAmount.toInt()),
        width: 6,
        styles: rightBold,
      ),
    ]);
    bytes += generator.row([
      PosColumn(text: 'Tunai (Pas)', width: 6, styles: regular),
      PosColumn(
        text: CurrencyFormatter.format(totalAmount.toInt()),
        width: 6,
        styles: right,
      ),
    ]);
    bytes += generator.row([
      PosColumn(text: 'Kembalian', width: 6, styles: regular),
      PosColumn(text: 'Rp 0', width: 6, styles: right),
    ]);

    // 9. Footer Notes Riil
    final footerNote =
        (outletSetting?['footer_notes']?.toString()) ??
        (outletSetting?['footerNotes']?.toString()) ??
        config.footerNote ??
        'Terima kasih atas kunjungan Anda!';
    bytes += generator.text(footerNote, styles: center);

    bytes += generator.hr();

    // 10. Diagnostik Teknis Hardware
    bytes += generator.text(
      'DIAGNOSTIK HARDWARE PRINTER:',
      styles: const PosStyles(
        fontType: PosFontType.fontB,
        bold: true,
        align: PosAlign.center,
      ),
    );
    bytes += generator.text('Lebar Kertas: ${config.paperSize.label}', styles: center);
    bytes += generator.text('Tipe Koneksi: ${config.connectionType.label}', styles: center);
    bytes += generator.text(
      'Waktu Uji   : ${DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now())}',
      styles: center,
    );

    bytes += generator.feed(2);

    if (config.autoCut) {
      bytes += generator.cut();
    }

    if (config.openCashDrawer) {
      bytes += [0x1B, 0x70, 0x00, 0x19, 0xFA]; // Pin 2 kick
    }

    return bytes;
  }

  Future<List<int>> generateTransactionReceiptBytes({
    required TransactionDetailData detail,
    required PrinterConfig config,
    Map<String, dynamic>? outletSetting,
    Uint8List? logoBytes,
    String? cashierName,
    String? outletName,
    String? outletAddress,
    String? outletPhone,
    String? outletEmail,
  }) async {
    final profile = await _getProfile();
    final paperSize = config.paperSize == PrinterPaperSize.mm58
        ? PaperSize.mm58
        : PaperSize.mm80;
    final generator = Generator(paperSize, profile);
    List<int> bytes = [];

    const regular = PosStyles(fontType: PosFontType.fontB);
    const bold = PosStyles(fontType: PosFontType.fontB, bold: true);
    const center = PosStyles(
      fontType: PosFontType.fontB,
      align: PosAlign.center,
    );
    const right = PosStyles(fontType: PosFontType.fontB, align: PosAlign.right);
    const rightBold = PosStyles(
      fontType: PosFontType.fontB,
      align: PosAlign.right,
      bold: true,
    );
    const header = PosStyles(
      fontType: PosFontType.fontA,
      align: PosAlign.center,
      bold: true,
    );

    bytes += generator.reset();

    // Logo Toko
    final rawShowLogo =
        outletSetting?['show_logo'] ?? outletSetting?['showLogo'];
    final bool showLogo =
        rawShowLogo == true ||
        rawShowLogo == 1 ||
        rawShowLogo == '1' ||
        rawShowLogo == null;
    if (showLogo && logoBytes != null) {
      try {
        final paperWidthDots = config.paperSize == PrinterPaperSize.mm58
            ? 384
            : 576;
        final rasterBytes = await _getLogoRasterBytes(
          logoBytes,
          paperWidthDots,
          generator,
        );
        if (rasterBytes != null) {
          bytes += rasterBytes;
        }
      } catch (e) {
        debugPrint('Error rasterizing logo for ESC/POS: $e');
      }
    }

    // Header Title
    final String customHeader =
        outletSetting?['custom_header_title']?.toString() ??
        outletSetting?['customHeaderTitle']?.toString() ??
        '';
    final displayName = customHeader.isNotEmpty
        ? customHeader
        : (outletName ?? config.storeName ?? 'NAMA OUTLET KASIR');
    bytes += generator.text(displayName, styles: header);

    // Address & Contact
    bool showAddress =
        (outletSetting?['show_address'] as bool?) ??
        (outletSetting?['showAddress'] as bool?) ??
        true;
    if (showAddress && outletAddress != null && outletAddress.isNotEmpty) {
      bytes += generator.text(outletAddress, styles: center);
    }
    bool showPhone =
        (outletSetting?['show_phone'] as bool?) ??
        (outletSetting?['showPhone'] as bool?) ??
        true;
    if (showPhone && outletPhone != null && outletPhone.isNotEmpty) {
      bytes += generator.text('Telp: $outletPhone', styles: center);
    }
    bool showEmail =
        (outletSetting?['show_email'] as bool?) ??
        (outletSetting?['showEmail'] as bool?) ??
        false;
    if (showEmail && outletEmail != null && outletEmail.isNotEmpty) {
      bytes += generator.text('Email: $outletEmail', styles: center);
    }

    // Header Note
    final headerNote =
        (outletSetting?['header_notes']?.toString()) ??
        (outletSetting?['headerNotes']?.toString()) ??
        config.headerNote;
    if (headerNote != null && headerNote.isNotEmpty) {
      bytes += generator.text(headerNote, styles: center);
    }

    bytes += generator.hr();

    // Meta Info
    final tx = detail.transaction;
    bytes += generator.row([
      PosColumn(
        text: 'No: ${tx.transactionNumber.trim()}',
        width: 7,
        styles: regular,
      ),
      PosColumn(
        text: DateFormat('dd/MM/yyyy HH:mm').format(tx.createdAt),
        width: 5,
        styles: right,
      ),
    ]);

    bool showCashier =
        (outletSetting?['show_cashier_name'] as bool?) ??
        (outletSetting?['showCashierName'] as bool?) ??
        true;
    String cashierText =
        (showCashier && cashierName != null && cashierName.isNotEmpty)
        ? 'Kasir: $cashierName'
        : '';

    bool showOrderType =
        (outletSetting?['show_order_type'] as bool?) ??
        (outletSetting?['showOrderType'] as bool?) ??
        true;
    String orderTypeText = showOrderType ? 'Dine In' : ''; // Placeholder

    if (cashierText.isNotEmpty || orderTypeText.isNotEmpty) {
      bytes += generator.row([
        PosColumn(text: cashierText, width: 7, styles: regular),
        PosColumn(text: orderTypeText, width: 5, styles: rightBold),
      ]);
    }

    bool showCustomer =
        (outletSetting?['show_customer_name'] as bool?) ??
        (outletSetting?['showCustomerName'] as bool?) ??
        true;
    if (showCustomer && detail.customer != null) {
      bytes += generator.text(
        'Pelanggan: ${detail.customer!.name}',
        styles: regular,
      );
    }

    bytes += generator.hr();

    // Item List
    for (final item in detail.items) {
      bytes += generator.text(item.productName, styles: regular);

      final qtyStr = item.qty % 1 == 0
          ? item.qty.toInt().toString()
          : item.qty.toString();
      final priceStr = CurrencyFormatter.format(item.price.toInt());
      final subtotalStr = CurrencyFormatter.format(
        item.subtotal.toInt() + item.discountAmount.toInt(),
      );

      bytes += generator.row([
        PosColumn(text: '$qtyStr x $priceStr', width: 7, styles: regular),
        PosColumn(text: subtotalStr, width: 5, styles: right),
      ]);

      // Modifiers
      if ((outletSetting?['show_modifiers'] as bool?) ??
          (outletSetting?['showModifiers'] as bool?) ??
          true) {
        final modifiers = detail.modifiersByItemId[item.id] ?? [];
        if (modifiers.isNotEmpty) {
          String modsText = modifiers
              .map((mod) {
                final modPrice = mod.price > 0
                    ? ' (+${CurrencyFormatter.format(mod.price.toInt())})'
                    : '';
                return '${mod.modifierName}$modPrice';
              })
              .join(', ');
          bytes += generator.text('  + $modsText', styles: regular);
        }
      }

      // Notes
      if (((outletSetting?['show_item_notes'] as bool?) ??
              (outletSetting?['showItemNotes'] as bool?) ??
              true) &&
          item.notes != null &&
          item.notes!.isNotEmpty) {
        bytes += generator.text('  * ${item.notes}', styles: regular);
      }

      // Diskon item
      if (item.discountAmount > 0) {
        bytes += generator.row([
          PosColumn(text: '  Diskon Item', width: 7, styles: regular),
          PosColumn(
            text: '-${CurrencyFormatter.format(item.discountAmount.toInt())}',
            width: 5,
            styles: right,
          ),
        ]);
      }
    }

    bytes += generator.hr();

    // Financial Calculation
    bytes += generator.row([
      PosColumn(text: 'Subtotal', width: 6, styles: regular),
      PosColumn(
        text: CurrencyFormatter.format(tx.subtotal.toInt()),
        width: 6,
        styles: right,
      ),
    ]);

    if (tx.discountAmount > 0) {
      bytes += generator.row([
        PosColumn(text: 'Diskon', width: 6, styles: regular),
        PosColumn(
          text: '-${CurrencyFormatter.format(tx.discountAmount.toInt())}',
          width: 6,
          styles: right,
        ),
      ]);
    }

    if (((outletSetting?['show_tax_detail'] as bool?) ??
            (outletSetting?['showTaxDetail'] as bool?) ??
            true) &&
        tx.taxAmount > 0) {
      bytes += generator.row([
        PosColumn(text: 'Pajak (PB1/PPN)', width: 6, styles: regular),
        PosColumn(
          text: CurrencyFormatter.format(tx.taxAmount.toInt()),
          width: 6,
          styles: right,
        ),
      ]);
    }

    if (((outletSetting?['show_service_charge'] as bool?) ??
            (outletSetting?['showServiceCharge'] as bool?) ??
            true) &&
        tx.serviceChargeAmount > 0) {
      bytes += generator.row([
        PosColumn(text: 'Service Charge', width: 6, styles: regular),
        PosColumn(
          text: CurrencyFormatter.format(tx.serviceChargeAmount.toInt()),
          width: 6,
          styles: right,
        ),
      ]);
    }

    bytes += generator.hr();

    // Total
    bytes += generator.row([
      PosColumn(text: 'TOTAL', width: 6, styles: bold),
      PosColumn(
        text: CurrencyFormatter.format(tx.total.toInt()),
        width: 6,
        styles: rightBold,
      ),
    ]);

    // Pembayaran
    if (detail.payments.isNotEmpty) {
      for (final payment in detail.payments) {
        final methodName = detail.paymentMethod?.name ?? 'Tunai';
        bytes += generator.row([
          PosColumn(text: methodName, width: 6, styles: regular),
          PosColumn(
            text: CurrencyFormatter.format(payment.amount.toInt()),
            width: 6,
            styles: right,
          ),
        ]);

        if (payment.changeAmount > 0) {
          bytes += generator.row([
            PosColumn(text: 'Kembalian', width: 6, styles: regular),
            PosColumn(
              text: CurrencyFormatter.format(payment.changeAmount.toInt()),
              width: 6,
              styles: right,
            ),
          ]);
        }
      }
    }

    // Footer Area
    final footer =
        (outletSetting?['footer_notes']?.toString()) ??
        (outletSetting?['footerNotes']?.toString()) ??
        config.footerNote;
    if (footer != null && footer.isNotEmpty) {
      bytes += generator.text(footer, styles: center);
    }

    final socialMedia =
        (outletSetting?['social_media_info']?.toString()) ??
        (outletSetting?['socialMediaInfo']?.toString());
    if (socialMedia != null && socialMedia.isNotEmpty) {
      bytes += generator.text(socialMedia, styles: center);
    }

    final wifiInfo =
        (outletSetting?['wifi_info']?.toString()) ??
        (outletSetting?['wifiInfo']?.toString());
    if (wifiInfo != null && wifiInfo.isNotEmpty) {
      bytes += generator.text('WiFi: $wifiInfo', styles: center);
    }

    if ((outletSetting?['show_qr_code'] as bool?) ??
        (outletSetting?['showQrCode'] as bool?) ??
        false) {
      bytes += generator.feed(1);
      bytes += generator.qrcode(tx.transactionNumber, size: QRSize.size4);
      bytes += generator.text('Scan untuk detail transaksi', styles: center);
    }

    bytes += generator.feed(2);

    if (config.autoCut) {
      bytes += generator.cut();
    }

    if (config.openCashDrawer) {
      bytes += generator.drawer();
    }

    return bytes;
  }

  /// Eksekusi Test Print Multiplatform (Bluetooth, System Spooler OS, atau Network TCP)
  Future<({bool success, String message})> printTest(
    PrinterConfig config, {
    Map<String, dynamic>? outletProfile,
    Map<String, dynamic>? outletSetting,
    Uint8List? logoBytes,
  }) async {
    if (config.address.isEmpty &&
        (config.ipAddress == null || config.ipAddress!.isEmpty)) {
      return (
        success: false,
        message: 'Alamat / Identitas printer tidak valid!',
      );
    }

    // A. Mode SYSTEM (Windows / macOS Print Spooler)
    if (config.connectionType == PrinterConnectionType.system) {
      try {
        final bytes = await generateTestReceiptBytes(
          config,
          outletProfile: outletProfile,
          outletSetting: outletSetting,
          logoBytes: logoBytes,
        );
        return await DesktopRawPrinter.printRawBytes(
          printerName: config.name,
          bytes: bytes,
          docName: 'Test_Receipt_${config.name}',
        );
      } catch (e) {
        debugPrint('Error printing test on desktop OS: $e');
        return (success: false, message: 'Error cetak desktop: $e');
      }
    }

    // B. Mode NETWORK (LAN / WiFi Socket TCP Port 9100)
    if (config.connectionType == PrinterConnectionType.network) {
      final ip = config.ipAddress ?? config.address;
      final bytes = await generateTestReceiptBytes(
        config,
        outletProfile: outletProfile,
        outletSetting: outletSetting,
        logoBytes: logoBytes,
      );
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
      return (
        success: false,
        message: 'Gagal menghubungkan ke printer Bluetooth ${config.name}',
      );
    }

    final bytes = await generateTestReceiptBytes(
      config,
      outletProfile: outletProfile,
      outletSetting: outletSetting,
      logoBytes: logoBytes,
    );
    final printSuccess = await _writeBluetoothBytesChunked(bytes);

    if (printSuccess) {
      return (success: true, message: 'Uji cetak Bluetooth berhasil!');
    } else {
      return (
        success: false,
        message: 'Gagal mengirim data ke printer Bluetooth!',
      );
    }
  }

  /// Eksekusi Cetak Struk Transaksi Multiplatform
  Future<({bool success, String message})> printTransactionReceipt({
    required TransactionDetailData detail,
    required PrinterConfig config,
    Map<String, dynamic>? outletSetting,
    Uint8List? logoBytes,
    String? cashierName,
    String? outletName,
    String? outletAddress,
    String? outletPhone,
    String? outletEmail,
  }) async {
    if (config.address.isEmpty &&
        (config.ipAddress == null || config.ipAddress!.isEmpty)) {
      return (
        success: false,
        message: 'Printer belum dipilih di Pengaturan Printer!',
      );
    }

    // A. Mode SYSTEM (Windows / macOS Print Spooler)
    if (config.connectionType == PrinterConnectionType.system) {
      try {
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
        return await DesktopRawPrinter.printRawBytes(
          printerName: config.name,
          bytes: bytes,
          docName: 'Struk_${detail.transaction.transactionNumber}',
        );
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
        return (
          success: true,
          message: 'Struk berhasil dicetak ke printer jaringan!',
        );
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
      return (
        success: false,
        message: 'Gagal menghubungkan ke printer ${config.name}',
      );
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

    final printSuccess = await _writeBluetoothBytesChunked(bytes);
    if (printSuccess) {
      return (success: true, message: 'Struk berhasil dicetak!');
    } else {
      return (success: false, message: 'Gagal mencetak struk Bluetooth!');
    }
  }

  /// Mengirim byte data ke printer Bluetooth dalam potongan (chunk) kecil
  /// untuk mencegah buffer overflow pada mikroprosesor printer thermal murah.
  Future<bool> _writeBluetoothBytesChunked(List<int> bytes) async {
    if (bytes.isEmpty) return true;
    const chunkSize = 512;
    if (bytes.length <= chunkSize) {
      return await PrintBluetoothThermal.writeBytes(bytes);
    }

    for (int i = 0; i < bytes.length; i += chunkSize) {
      final end = (i + chunkSize < bytes.length) ? i + chunkSize : bytes.length;
      final chunk = bytes.sublist(i, end);
      final ok = await PrintBluetoothThermal.writeBytes(chunk);
      if (!ok) return false;
      await Future.delayed(const Duration(milliseconds: 15));
    }
    return true;
  }

  /// Menghasilkan byte untuk cetak laporan tutup shift
  Future<List<int>> generateShiftReportBytes({
    required ShiftSummary summary,
    required PrinterConfig config,
    String? cashierName,
    String? outletName,
    String? outletAddress,
    String? outletPhone,
    String? outletEmail,
  }) async {
    final profile = await _getProfile();
    final paperSize = config.paperSize == PrinterPaperSize.mm58
        ? PaperSize.mm58
        : PaperSize.mm80;
    final generator = Generator(paperSize, profile);
    List<int> bytes = [];

    const regular = PosStyles(fontType: PosFontType.fontB);
    const bold = PosStyles(fontType: PosFontType.fontB, bold: true);
    const center = PosStyles(
      fontType: PosFontType.fontB,
      align: PosAlign.center,
    );
    const right = PosStyles(fontType: PosFontType.fontB, align: PosAlign.right);
    const rightBold = PosStyles(
      fontType: PosFontType.fontB,
      align: PosAlign.right,
      bold: true,
    );
    const header = PosStyles(
      fontType: PosFontType.fontA,
      align: PosAlign.center,
      bold: true,
    );

    bytes += generator.reset();

    // 1. Header Toko
    final displayName = outletName ?? config.storeName ?? 'SOLLU POS';
    bytes += generator.text(displayName, styles: header);

    if (outletAddress != null && outletAddress.isNotEmpty) {
      bytes += generator.text(outletAddress, styles: center);
    }
    if (outletPhone != null && outletPhone.isNotEmpty) {
      bytes += generator.text('Telp: $outletPhone', styles: center);
    }

    bytes += generator.hr();

    bytes += generator.text('LAPORAN TUTUP SHIFT', styles: header);

    bytes += generator.feed(1);

    bytes += generator.row([
      PosColumn(text: 'Waktu Cetak:', width: 5, styles: regular),
      PosColumn(
        text: DateFormat('dd/MM/yy HH:mm').format(DateTime.now()),
        width: 7,
        styles: right,
      ),
    ]);

    if (cashierName != null && cashierName.isNotEmpty) {
      bytes += generator.row([
        PosColumn(text: 'Kasir:', width: 5, styles: regular),
        PosColumn(text: cashierName, width: 7, styles: right),
      ]);
    }

    bytes += generator.hr();

    // 2. Rincian Laporan
    bytes += generator.row([
      PosColumn(text: 'Modal Awal', width: 6, styles: regular),
      PosColumn(
        text: CurrencyFormatter.format(summary.openingCash.toInt()),
        width: 6,
        styles: right,
      ),
    ]);

    bytes += generator.feed(1);
    bytes += generator.text('Pemasukan per Metode:', styles: bold);

    for (final entry in summary.salesByPaymentMethod.entries) {
      bytes += generator.row([
        PosColumn(text: '- ${entry.key}', width: 6, styles: regular),
        PosColumn(
          text: CurrencyFormatter.format(entry.value.toInt()),
          width: 6,
          styles: right,
        ),
      ]);
    }

    bytes += generator.feed(1);
    bytes += generator.row([
      PosColumn(text: 'Kas Masuk/Keluar', width: 6, styles: regular),
      PosColumn(
        text: CurrencyFormatter.format(
          (summary.cashIn - summary.cashOut).toInt(),
        ),
        width: 6,
        styles: right,
      ),
    ]);

    bytes += generator.hr();

    bytes += generator.row([
      PosColumn(text: 'Ekspektasi Kas Laci', width: 6, styles: bold),
      PosColumn(
        text: CurrencyFormatter.format(summary.expectedCash.toInt()),
        width: 6,
        styles: rightBold,
      ),
    ]);

    bytes += generator.hr();

    bytes += generator.text(
      'Laporan ini dicetak secara otomatis\ndari sistem Sollu POS.',
      styles: center,
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
    if (config.address.isEmpty &&
        (config.ipAddress == null || config.ipAddress!.isEmpty)) {
      return (
        success: false,
        message: 'Printer belum dipilih di Pengaturan Printer!',
      );
    }

    // A. Mode SYSTEM (Windows / macOS Print Spooler)
    if (config.connectionType == PrinterConnectionType.system) {
      try {
        final bytes = await generateShiftReportBytes(
          summary: summary,
          config: config,
          cashierName: cashierName,
          outletName: outletName,
          outletAddress: outletAddress,
          outletPhone: outletPhone,
        );
        return await DesktopRawPrinter.printRawBytes(
          printerName: config.name,
          bytes: bytes,
          docName: 'Shift_Report_${DateTime.now().millisecondsSinceEpoch}',
        );
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
        return (
          success: true,
          message: 'Laporan berhasil dicetak ke printer jaringan!',
        );
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
      return (
        success: false,
        message: 'Gagal menghubungkan ke printer ${config.name}',
      );
    }

    final bytes = await generateShiftReportBytes(
      summary: summary,
      config: config,
      cashierName: cashierName,
      outletName: outletName,
      outletAddress: outletAddress,
      outletPhone: outletPhone,
    );

    final printSuccess = await _writeBluetoothBytesChunked(bytes);
    if (printSuccess) {
      return (success: true, message: 'Laporan shift berhasil dicetak!');
    } else {
      return (success: false, message: 'Gagal mencetak laporan Bluetooth!');
    }
  }

  /// Eksekusi perintah pembukaan Cash Drawer (Laci Uang)
  Future<({bool success, String message})> openCashDrawer(
    PrinterConfig config,
  ) async {
    if (config.address.isEmpty &&
        (config.ipAddress == null || config.ipAddress!.isEmpty)) {
      return (
        success: false,
        message: 'Printer belum dipilih di Pengaturan Printer!',
      );
    }

    final profile = await _getProfile();
    final paperSize = config.paperSize == PrinterPaperSize.mm58
        ? PaperSize.mm58
        : PaperSize.mm80;
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
        return (
          success: false,
          message: 'Bluetooth perangkat belum dinyalakan!',
        );
      }

      final connected = await connectBluetooth(config.address);
      if (!connected) {
        return (
          success: false,
          message: 'Gagal menghubungkan ke printer Bluetooth ${config.name}',
        );
      }

      final printSuccess = await PrintBluetoothThermal.writeBytes(bytes);
      if (printSuccess) {
        return (
          success: true,
          message: 'Laci uang berhasil dibuka (Bluetooth)!',
        );
      } else {
        return (
          success: false,
          message: 'Gagal mengirim perintah ke printer Bluetooth!',
        );
      }
    }

    // C. Mode SYSTEM (Desktop Print Spooler)
    if (config.connectionType == PrinterConnectionType.system) {
      return await DesktopRawPrinter.printRawBytes(
        printerName: config.name,
        bytes: bytes,
        docName: 'Drawer_Kick',
      );
    }

    return (success: false, message: 'Tipe koneksi printer tidak dikenali.');
  }
}
