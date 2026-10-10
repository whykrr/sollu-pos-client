import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/dio_client.dart';

class OutletSettingsService {
  final SharedPreferences _prefs;

  OutletSettingsService(this._prefs);

  static const _outletProfileKey = 'outlet_profile';
  static const _outletSettingsKey = 'outlet_settings';

  Future<void> saveOutletProfile(Map<String, dynamic> profile) async {
    await _prefs.setString(_outletProfileKey, jsonEncode(profile));
  }

  Map<String, dynamic>? getOutletProfile() {
    final data = _prefs.getString(_outletProfileKey);
    if (data != null) {
      return jsonDecode(data) as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> saveOutletSettings(Map<String, dynamic> settings) async {
    await _prefs.setString(_outletSettingsKey, jsonEncode(settings));
  }

  Map<String, dynamic>? getOutletSettings() {
    final data = _prefs.getString(_outletSettingsKey);
    if (data != null) {
      return jsonDecode(data) as Map<String, dynamic>;
    }
    return null;
  }

  static const _autoPrintKey = 'pos_auto_print';

  Future<void> saveAutoPrint(bool autoPrint) async {
    await _prefs.setBool(_autoPrintKey, autoPrint);
  }

  bool getAutoPrint() {
    return _prefs.getBool(_autoPrintKey) ?? true;
  }

  Future<void> clearAll() async {
    await _prefs.remove(_outletProfileKey);
    await _prefs.remove(_outletSettingsKey);
    await _prefs.remove(_autoPrintKey);
  }

  /// Sinkronisasikan payload pengaturan & profil outlet dari backend
  Future<void> syncSettingsPayload({
    required Map<String, dynamic> data,
    DioClient? dioClient,
  }) async {
    final Map<String, dynamic> structuredSettings =
        data['settings'] is Map<String, dynamic>
            ? data['settings'] as Map<String, dynamic>
            : (data['settings'] is Map ? Map<String, dynamic>.from(data['settings']) : {});
    final List<dynamic> outletSettings =
        data['outlet_settings'] is List ? data['outlet_settings'] : [];
    final Map<String, dynamic> outletDataRaw =
        data['outlet'] is Map<String, dynamic>
            ? data['outlet'] as Map<String, dynamic>
            : (data['outlet'] is Map ? Map<String, dynamic>.from(data['outlet']) : {});

    if (structuredSettings.isEmpty && outletSettings.isEmpty && outletDataRaw.isEmpty) {
      return;
    }

    final existingProfile = getOutletProfile();
    final existingSettings = getOutletSettings();
    final existingLocalLogoPath =
        existingProfile?['local_logo_path']?.toString() ??
        existingSettings?['localLogoPath']?.toString();

    final dynamic rawReceipt = structuredSettings['receipt'];
    final Map<String, dynamic> receiptObj =
        rawReceipt is Map<String, dynamic>
            ? rawReceipt
            : (rawReceipt is Map ? Map<String, dynamic>.from(rawReceipt) : {});

    double parsedTax =
        double.tryParse(structuredSettings['tax_percentage']?.toString() ?? '') ??
        (existingSettings?['taxPercentage'] as num?)?.toDouble() ??
        0.0;
    double parsedService =
        double.tryParse(structuredSettings['service_charge_percentage']?.toString() ?? '') ??
        (existingSettings?['serviceChargePercentage'] as num?)?.toDouble() ??
        0.0;
    bool parsedTaxIncluded =
        structuredSettings['tax_included_in_price'] == true ||
        structuredSettings['tax_included_in_price'] == 1 ||
        (existingSettings?['taxIncludedInPrice'] == true);
    bool parsedRoundingEnabled =
        structuredSettings['rounding_enabled'] == true ||
        structuredSettings['rounding_enabled'] == 1 ||
        (existingSettings?['roundingEnabled'] == true);
    String parsedRoundingMode =
        structuredSettings['rounding_mode']?.toString() ??
        existingSettings?['roundingMode']?.toString() ??
        'nearest';

    Map<String, dynamic> parsedReceipt = Map<String, dynamic>.from(receiptObj);
    if (parsedReceipt.isEmpty && outletSettings.isNotEmpty) {
      for (final row in outletSettings) {
        if (row['key'] == 'tax') {
          parsedTax = double.tryParse(row['value']?.toString() ?? '0') ?? parsedTax;
        } else if (row['key'] == 'service_fee') {
          parsedService = double.tryParse(row['value']?.toString() ?? '0') ?? parsedService;
        } else if (row['key'] == 'tax_included_in_price') {
          parsedTaxIncluded = row['value'] == true || row['value'] == 1;
        } else if (row['key'] == 'rounding_enabled') {
          parsedRoundingEnabled = row['value'] == true || row['value'] == 1;
        } else if (row['key'] == 'rounding_mode') {
          parsedRoundingMode = row['value']?.toString() ?? 'nearest';
        } else if (row['category'] == 'receipt' &&
            row['key'] == 'layout_config' &&
            row['value'] is Map) {
          parsedReceipt = Map<String, dynamic>.from(row['value']);
        }
      }
    }

    final paperSize = parsedReceipt['paper_size']?.toString() ??
        existingSettings?['paperSize']?.toString() ??
        '58mm';
    final autoPrint = parsedReceipt['auto_print'] == true ||
        parsedReceipt['auto_print'] == 1 ||
        (parsedReceipt['auto_print'] == null && (existingSettings?['autoPrint'] ?? true));
    final bool allowNegativeStock =
        structuredSettings['allow_negative_stock'] == true ||
        structuredSettings['allow_negative_stock'] == 1 ||
        (structuredSettings['allow_negative_stock'] == null && (existingSettings?['allowNegativeStock'] ?? true));
    final List<String> posOrderTypes = (structuredSettings['pos_order_types'] is List)
        ? (structuredSettings['pos_order_types'] as List).map((e) => e.toString()).toList()
        : (existingSettings?['posOrderTypes'] is List
            ? (existingSettings!['posOrderTypes'] as List).map((e) => e.toString()).toList()
            : const ['walk_in', 'dine_in', 'take_away']);

    final showLogo = parsedReceipt['show_logo'] == true ||
        parsedReceipt['show_logo'] == 1 ||
        (parsedReceipt['show_logo'] == null && (existingSettings?['showLogo'] ?? true));
    final customHeaderTitle = parsedReceipt['custom_header_title']?.toString() ??
        existingSettings?['customHeaderTitle']?.toString();
    final headerNotes = parsedReceipt['header_notes']?.toString() ??
        existingSettings?['headerNotes']?.toString() ??
        'Terima kasih atas kunjungan Anda!';
    final showAddress = parsedReceipt['show_address'] == true ||
        parsedReceipt['show_address'] == 1 ||
        (parsedReceipt['show_address'] == null && (existingSettings?['showAddress'] ?? true));
    final showPhone = parsedReceipt['show_phone'] == true ||
        parsedReceipt['show_phone'] == 1 ||
        (parsedReceipt['show_phone'] == null && (existingSettings?['showPhone'] ?? true));
    final showEmail = parsedReceipt['show_email'] == true ||
        parsedReceipt['show_email'] == 1 ||
        (existingSettings?['showEmail'] == true);
    final showCashierName = parsedReceipt['show_cashier_name'] == true ||
        parsedReceipt['show_cashier_name'] == 1 ||
        (parsedReceipt['show_cashier_name'] == null && (existingSettings?['showCashierName'] ?? true));
    final showCustomerName = parsedReceipt['show_customer_name'] == true ||
        parsedReceipt['show_customer_name'] == 1 ||
        (parsedReceipt['show_customer_name'] == null && (existingSettings?['showCustomerName'] ?? true));
    final showOrderType = parsedReceipt['show_order_type'] == true ||
        parsedReceipt['show_order_type'] == 1 ||
        (parsedReceipt['show_order_type'] == null && (existingSettings?['showOrderType'] ?? true));
    final showModifiers = parsedReceipt['show_modifiers'] == true ||
        parsedReceipt['show_modifiers'] == 1 ||
        (parsedReceipt['show_modifiers'] == null && (existingSettings?['showModifiers'] ?? true));
    final showItemNotes = parsedReceipt['show_item_notes'] == true ||
        parsedReceipt['show_item_notes'] == 1 ||
        (parsedReceipt['show_item_notes'] == null && (existingSettings?['showItemNotes'] ?? true));
    final showTaxDetail = parsedReceipt['show_tax_detail'] == true ||
        parsedReceipt['show_tax_detail'] == 1 ||
        (parsedReceipt['show_tax_detail'] == null && (existingSettings?['showTaxDetail'] ?? true));
    final showServiceCharge = parsedReceipt['show_service_charge'] == true ||
        parsedReceipt['show_service_charge'] == 1 ||
        (existingSettings?['showServiceCharge'] == true);
    final footerNotes = parsedReceipt['footer_notes']?.toString() ??
        existingSettings?['footerNotes']?.toString() ??
        'Barang yang sudah dibeli tidak dapat ditukar atau dikembalikan.';
    final socialMediaInfo = parsedReceipt['social_media_info']?.toString() ??
        existingSettings?['socialMediaInfo']?.toString();
    final wifiInfo = parsedReceipt['wifi_info']?.toString() ??
        existingSettings?['wifiInfo']?.toString();
    final showQrCode = parsedReceipt['show_qr_code'] == true ||
        parsedReceipt['show_qr_code'] == 1 ||
        (existingSettings?['showQrCode'] == true);
    final qrType = parsedReceipt['qr_type']?.toString() ??
        existingSettings?['qrType']?.toString() ??
        'invoice';

    final String? logoUrl = parsedReceipt['logo_url']?.toString() ??
        outletDataRaw['logo_url']?.toString() ??
        existingSettings?['logoUrl']?.toString();

    String? localLogoPath = existingLocalLogoPath;

    if (dioClient != null && logoUrl != null && logoUrl.isNotEmpty) {
      try {
        String fullLogoUrl = logoUrl;
        if (!fullLogoUrl.startsWith('http://') && !fullLogoUrl.startsWith('https://')) {
          final baseUrl = dioClient.dio.options.baseUrl;
          if (baseUrl.isNotEmpty) {
            final baseUri = Uri.parse(baseUrl);
            final origin =
                '${baseUri.scheme}://${baseUri.host}${baseUri.hasPort ? ':${baseUri.port}' : ''}';
            fullLogoUrl = fullLogoUrl.startsWith('/')
                ? '$origin$fullLogoUrl'
                : '$origin/$fullLogoUrl';
          }
        }

        final appDir = await getApplicationDocumentsDirectory();
        final logoFile = File(p.join(appDir.path, 'outlet_logo.png'));

        final imgRes = await dioClient.dio.get<List<int>>(
          fullLogoUrl,
          options: Options(responseType: ResponseType.bytes),
        );
        if (imgRes.statusCode == 200 && imgRes.data != null) {
          await logoFile.writeAsBytes(imgRes.data!);
          localLogoPath = logoFile.path;
        }
      } catch (e) {
        debugPrint('Error downloading logo: $e');
      }
    }

    if (outletDataRaw.isNotEmpty) {
      final outletData = Map<String, dynamic>.from(existingProfile ?? {});
      outletData.addAll(outletDataRaw);
      if (localLogoPath != null) {
        outletData['local_logo_path'] = localLogoPath;
      }
      await saveOutletProfile(outletData);
    }

    final settingsToSave = {
      'taxPercentage': parsedTax,
      'serviceChargePercentage': parsedService,
      'taxIncludedInPrice': parsedTaxIncluded,
      'roundingEnabled': parsedRoundingEnabled,
      'roundingMode': parsedRoundingMode,
      'allowNegativeStock': allowNegativeStock,
      'posOrderTypes': posOrderTypes,
      'paperSize': paperSize,
      'autoPrint': autoPrint,
      'showLogo': showLogo,
      'customHeaderTitle': customHeaderTitle,
      'headerNotes': headerNotes,
      'showAddress': showAddress,
      'showPhone': showPhone,
      'showEmail': showEmail,
      'showCashierName': showCashierName,
      'showCustomerName': showCustomerName,
      'showOrderType': showOrderType,
      'showModifiers': showModifiers,
      'showItemNotes': showItemNotes,
      'showTaxDetail': showTaxDetail,
      'showServiceCharge': showServiceCharge,
      'footerNotes': footerNotes,
      'socialMediaInfo': socialMediaInfo,
      'wifiInfo': wifiInfo,
      'showQrCode': showQrCode,
      'qrType': qrType,
      'logoUrl': logoUrl,
      'localLogoPath': localLogoPath,
    };
    await saveOutletSettings(settingsToSave);
  }
}
