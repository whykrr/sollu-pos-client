import 'dart:io';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/database/app_database.dart';

class SyncRepository {
  final DioClient _dioClient;
  final AppDatabase _database;

  SyncRepository(this._dioClient, this._database);

  Future<void> syncMasterData() async {
    try {
      final response = await _dioClient.dio.get('/sync/master');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data['data'];

        final List<dynamic> products = data['products'] ?? [];
        final List<dynamic> productPrices = data['product_prices'] ?? [];
        final List<dynamic> paymentMethods = data['payment_methods'] ?? [];
        final List<dynamic> outletSettings = data['outlet_settings'] ?? [];
        final List<dynamic> outletProducts = data['outlet_products'] ?? [];
        final List<dynamic> inventoryItems = data['inventory_items'] ?? [];
        final List<dynamic> inventoryBalances = data['inventory_balances'] ?? [];
        
        final List<dynamic> productCategories = data['product_categories'] ?? [];
        final List<dynamic> variantGroups = data['variant_groups'] ?? [];
        final List<dynamic> variantGroupOptions = data['variant_group_options'] ?? [];
        final List<dynamic> productModifierGroups = data['product_modifier_groups'] ?? [];
        final List<dynamic> modifierGroups = data['modifier_groups'] ?? [];
        final List<dynamic> modifierOptions = data['modifier_options'] ?? [];
        final List<dynamic> inventoryItemVariantGroupOptions = data['inventory_item_variant_group_options'] ?? [];
        final List<dynamic> promos = data['promos'] ?? [];
        final List<dynamic> customers = data['customers'] ?? [];

        // Helper map to quickly find price by product_id
        final Map<String, double> priceMap = {};
        for (var p in productPrices) {
          final prodId = p['product_id'];
          if (prodId != null) {
            final rawAmount = p['amount'] ?? p['price'];
            final amountVal = double.tryParse(rawAmount?.toString() ?? '0') ?? 0.0;
            if (amountVal > 0 && (!priceMap.containsKey(prodId) || p['inventory_item_id'] == null)) {
              priceMap[prodId] = amountVal;
            }
          }
        }

        // Helper map to check outlet product availability & enabled status
        final Map<String, bool> outletProductAvailability = {};
        for (var op in outletProducts) {
          final prodId = op['product_id'];
          if (prodId != null) {
            final isEnabled = op['is_enabled'] == 1 || op['is_enabled'] == true || op['is_enabled'] == 'true' || op['is_enabled'] == null;
            final isAvailable = op['is_available'] == 1 || op['is_available'] == true || op['is_available'] == 'true' || op['is_available'] == null;
            outletProductAvailability[prodId] = isEnabled && isAvailable;
          }
        }

        // Helper map to quickly find stock by inventory_item_id
        final Map<String, double> stockByItemId = {};
        for (var bal in inventoryBalances) {
          final itemId = bal['inventory_item_id'];
          stockByItemId[itemId] = (stockByItemId[itemId] ?? 0) +
              (double.tryParse(bal['current_stock'].toString()) ?? 0.0);
        }

        // Simpan state lokal sebelum dihapus (agar tidak tertimpa saat sinkronisasi)
        final existingPaymentMethods = await _database.select(_database.paymentMethods).get();
        final Map<String, int?> localSortOrderMap = {
          for (var pm in existingPaymentMethods)
            if (pm.localSortOrder != null) pm.id: pm.localSortOrder,
        };

        final existingOutletSetting = await (_database.select(_database.outletSettings)..limit(1)).getSingleOrNull();
        final String? existingLocalLogoPath = existingOutletSetting?.localLogoPath;

        await _database.transaction(() async {
          // Clear old data (order matters due to foreign keys)
          await _database.delete(_database.inventoryItemVariantGroupOptions).go();
          await _database.delete(_database.productModifierGroups).go();
          await _database.delete(_database.modifierOptions).go();
          await _database.delete(_database.modifierGroups).go();
          await _database.delete(_database.variantGroupOptions).go();
          await _database.delete(_database.variantGroups).go();
          await _database.delete(_database.productPrices).go();
          await _database.delete(_database.inventories).go();
          await _database.delete(_database.products).go();
          await _database.delete(_database.productCategories).go();
          await _database.delete(_database.paymentMethods).go();
          await _database.delete(_database.outletSettings).go();
          await _database.delete(_database.promos).go();
          await _database.delete(_database.customers).go();

          // Insert Products
          for (final item in products) {
            final productId = item['id'];
            final isShow = item['is_show'] == 1 || item['is_show'] == true || item['is_show'] == 'true' || item['is_show'] == null;
            final isAvailableAtOutlet = outletProductAvailability.containsKey(productId) 
                ? outletProductAvailability[productId]! 
                : true;
            final isAvailable = isShow && isAvailableAtOutlet;

            await _database
                .into(_database.products)
                .insert(
                  ProductsCompanion.insert(
                    id: productId,
                    name: item['name'],
                    categoryId: Value(item['product_category_id'] ?? item['category_id']),
                    sku: Value(item['sku']),
                    barcode: Value(item['barcode']),
                    price: priceMap[productId] ?? 0.0,
                    isAvailable: Value(isAvailable),
                  ),
                );
          }

          // Insert Payment Methods
          for (final item in paymentMethods) {
            final methodId = item['id'];
            await _database
                .into(_database.paymentMethods)
                .insert(
                  PaymentMethodsCompanion.insert(
                    id: methodId,
                    name: item['name'],
                    type: item['type'],
                    sortOrder: Value(int.tryParse(item['sort_order']?.toString() ?? '0') ?? 0),
                    localSortOrder: Value(localSortOrderMap[methodId]),
                    isActive: Value(
                      item['is_active'] == 1 || item['is_active'] == true || item['is_active'] == 'true' || item['is_active'] == null,
                    ),
                  ),
                );
          }

          // Insert Outlet Settings
          final dynamic rawSettings = data['settings'];
          final Map<String, dynamic> structuredSettings = rawSettings is Map<String, dynamic> ? rawSettings : {};
          final dynamic rawReceipt = structuredSettings['receipt'];
          final Map<String, dynamic> receiptObj = rawReceipt is Map<String, dynamic> ? rawReceipt : {};

          // Fallback parsing from key-value outletSettings if structuredSettings is empty
          double parsedTax = double.tryParse(structuredSettings['tax_percentage']?.toString() ?? '') ?? 0.0;
          double parsedService = double.tryParse(structuredSettings['service_charge_percentage']?.toString() ?? '') ?? 0.0;
          bool parsedTaxIncluded = structuredSettings['tax_included_in_price'] == true || structuredSettings['tax_included_in_price'] == 1;
          bool parsedRoundingEnabled = structuredSettings['rounding_enabled'] == true || structuredSettings['rounding_enabled'] == 1;
          String parsedRoundingMode = structuredSettings['rounding_mode']?.toString() ?? 'nearest';

          Map<String, dynamic> parsedReceipt = Map<String, dynamic>.from(receiptObj);
          if (parsedReceipt.isEmpty && outletSettings.isNotEmpty) {
            for (final row in outletSettings) {
              if (row['key'] == 'tax') {
                parsedTax = double.tryParse(row['value']?.toString() ?? '0') ?? 0.0;
              } else if (row['key'] == 'service_fee') {
                parsedService = double.tryParse(row['value']?.toString() ?? '0') ?? 0.0;
              } else if (row['key'] == 'tax_included_in_price') {
                parsedTaxIncluded = row['value'] == true || row['value'] == 1;
              } else if (row['key'] == 'rounding_enabled') {
                parsedRoundingEnabled = row['value'] == true || row['value'] == 1;
              } else if (row['key'] == 'rounding_mode') {
                parsedRoundingMode = row['value']?.toString() ?? 'nearest';
              } else if (row['category'] == 'receipt' && row['key'] == 'layout_config' && row['value'] is Map) {
                parsedReceipt = Map<String, dynamic>.from(row['value']);
              }
            }
          }

          final paperSize = parsedReceipt['paper_size']?.toString() ?? '58mm';
          final autoPrint = parsedReceipt['auto_print'] == true || parsedReceipt['auto_print'] == 1 || parsedReceipt['auto_print'] == null;
          final printKitchenCopy = parsedReceipt['print_kitchen_copy'] == true || parsedReceipt['print_kitchen_copy'] == 1;
          final printCheckerCopy = parsedReceipt['print_checker_copy'] == true || parsedReceipt['print_checker_copy'] == 1;
          final showLogo = parsedReceipt['show_logo'] == true || parsedReceipt['show_logo'] == 1 || parsedReceipt['show_logo'] == null;
          final customHeaderTitle = parsedReceipt['custom_header_title']?.toString();
          final headerNotes = parsedReceipt['header_notes']?.toString() ?? 'Terima kasih atas kunjungan Anda!';
          final showAddress = parsedReceipt['show_address'] == true || parsedReceipt['show_address'] == 1 || parsedReceipt['show_address'] == null;
          final showPhone = parsedReceipt['show_phone'] == true || parsedReceipt['show_phone'] == 1 || parsedReceipt['show_phone'] == null;
          final showEmail = parsedReceipt['show_email'] == true || parsedReceipt['show_email'] == 1;
          final showCashierName = parsedReceipt['show_cashier_name'] == true || parsedReceipt['show_cashier_name'] == 1 || parsedReceipt['show_cashier_name'] == null;
          final showCustomerName = parsedReceipt['show_customer_name'] == true || parsedReceipt['show_customer_name'] == 1 || parsedReceipt['show_customer_name'] == null;
          final showOrderType = parsedReceipt['show_order_type'] == true || parsedReceipt['show_order_type'] == 1 || parsedReceipt['show_order_type'] == null;
          final showModifiers = parsedReceipt['show_modifiers'] == true || parsedReceipt['show_modifiers'] == 1 || parsedReceipt['show_modifiers'] == null;
          final showItemNotes = parsedReceipt['show_item_notes'] == true || parsedReceipt['show_item_notes'] == 1 || parsedReceipt['show_item_notes'] == null;
          final showTaxDetail = parsedReceipt['show_tax_detail'] == true || parsedReceipt['show_tax_detail'] == 1 || parsedReceipt['show_tax_detail'] == null;
          final showServiceCharge = parsedReceipt['show_service_charge'] == true || parsedReceipt['show_service_charge'] == 1;
          final footerNotes = parsedReceipt['footer_notes']?.toString() ?? 'Barang yang sudah dibeli tidak dapat ditukar atau dikembalikan.';
          final socialMediaInfo = parsedReceipt['social_media_info']?.toString();
          final wifiInfo = parsedReceipt['wifi_info']?.toString();
          final showQrCode = parsedReceipt['show_qr_code'] == true || parsedReceipt['show_qr_code'] == 1;
          final qrType = parsedReceipt['qr_type']?.toString() ?? 'invoice';

          final String? logoUrl = parsedReceipt['logo_url']?.toString() ??
              (data['outlet'] != null ? data['outlet']['logo_url']?.toString() : null);
          String? localLogoPath;

          if (logoUrl != null && logoUrl.isNotEmpty) {
            try {
              final appDir = await getApplicationDocumentsDirectory();
              final logoFile = File(p.join(appDir.path, 'outlet_logo.png'));
              
              final imgRes = await _dioClient.dio.get<List<int>>(
                logoUrl,
                options: Options(responseType: ResponseType.bytes),
              );
              if (imgRes.statusCode == 200 && imgRes.data != null) {
                await logoFile.writeAsBytes(imgRes.data!);
                localLogoPath = logoFile.path;
              }
            } catch (_) {
              localLogoPath = existingLocalLogoPath;
            }
          }

          await _database.into(_database.outletSettings).insert(
            OutletSettingsCompanion.insert(
              id: 'current_outlet_setting',
              taxPercentage: Value(parsedTax),
              serviceChargePercentage: Value(parsedService),
              taxIncludedInPrice: Value(parsedTaxIncluded),
              roundingEnabled: Value(parsedRoundingEnabled),
              roundingMode: Value(parsedRoundingMode),
              paperSize: Value(paperSize),
              autoPrint: Value(autoPrint),
              printKitchenCopy: Value(printKitchenCopy),
              printCheckerCopy: Value(printCheckerCopy),
              showLogo: Value(showLogo),
              customHeaderTitle: Value(customHeaderTitle),
              headerNotes: Value(headerNotes),
              showAddress: Value(showAddress),
              showPhone: Value(showPhone),
              showEmail: Value(showEmail),
              showCashierName: Value(showCashierName),
              showCustomerName: Value(showCustomerName),
              showOrderType: Value(showOrderType),
              showModifiers: Value(showModifiers),
              showItemNotes: Value(showItemNotes),
              showTaxDetail: Value(showTaxDetail),
              showServiceCharge: Value(showServiceCharge),
              footerNotes: Value(footerNotes),
              socialMediaInfo: Value(socialMediaInfo),
              wifiInfo: Value(wifiInfo),
              showQrCode: Value(showQrCode),
              qrType: Value(qrType),
              logoUrl: Value(logoUrl),
              localLogoPath: Value(localLogoPath),
            ),
          );

          // Insert Inventories
          for (final item in inventoryItems) {
            final itemId = item['id'];
            final isInvActive = item['is_active'] == 1 || item['is_active'] == true || item['is_active'] == 'true' || item['is_active'] == null;

            await _database
                .into(_database.inventories)
                .insert(
                  InventoriesCompanion.insert(
                    id: itemId,
                    productId: item['product_id'],
                    name: item['name'],
                    sku: Value(item['sku']),
                    barcode: Value(item['barcode']),
                    trackInventory: Value(
                      item['track_inventory'] == 1 || item['track_inventory'] == true || item['track_inventory'] == 'true',
                    ),
                    isActive: Value(isInvActive),
                    stock: Value(stockByItemId[itemId] ?? 0.0),
                  ),
                );
          }

          // Insert Product Categories
          for (final item in productCategories) {
            await _database.into(_database.productCategories).insert(
              ProductCategoriesCompanion.insert(
                id: item['id'],
                name: item['name'],
                parentId: Value(item['parent_id']),
                sortOrder: Value(int.tryParse(item['sort_order']?.toString() ?? '0') ?? 0),
              ),
            );
          }

          // Insert Variant Groups
          for (final item in variantGroups) {
            await _database.into(_database.variantGroups).insert(
              VariantGroupsCompanion.insert(
                id: item['id'],
                productId: item['product_id'],
                name: item['name'],
              ),
            );
          }

          // Insert Variant Group Options
          for (final item in variantGroupOptions) {
            await _database.into(_database.variantGroupOptions).insert(
              VariantGroupOptionsCompanion.insert(
                id: item['id'],
                variantGroupId: item['variant_group_id'],
                name: item['name'],
              ),
            );
          }

          // Insert Modifier Groups
          for (final item in modifierGroups) {
            await _database.into(_database.modifierGroups).insert(
              ModifierGroupsCompanion.insert(
                id: item['id'],
                name: item['name'],
                type: Value(item['type']),
                minSelected: Value(item['min_selected'] ?? 0),
                maxSelected: Value(item['max_selected'] ?? 0),
              ),
            );
          }

          // Insert Modifier Options
          for (final item in modifierOptions) {
            await _database.into(_database.modifierOptions).insert(
              ModifierOptionsCompanion.insert(
                id: item['id'],
                modifierGroupId: item['modifier_group_id'],
                name: item['name'],
                price: Value(double.tryParse(item['price']?.toString() ?? '0') ?? 0.0),
              ),
            );
          }

          // Insert Product Modifier Groups
          for (final item in productModifierGroups) {
            await _database.into(_database.productModifierGroups).insert(
              ProductModifierGroupsCompanion.insert(
                productId: item['product_id'],
                modifierGroupId: item['modifier_group_id'],
              ),
            );
          }

          // Insert Inventory Item Variant Group Options
          for (final item in inventoryItemVariantGroupOptions) {
            await _database.into(_database.inventoryItemVariantGroupOptions).insert(
              InventoryItemVariantGroupOptionsCompanion.insert(
                inventoryItemId: item['inventory_item_id'],
                variantGroupOptionId: item['variant_group_option_id'],
              ),
            );
          }

          // Insert Product Prices
          for (final item in productPrices) {
            final rawAmount = item['amount'] ?? item['price'];
            final amountVal = double.tryParse(rawAmount?.toString() ?? '0') ?? 0.0;

            await _database.into(_database.productPrices).insert(
              ProductPricesCompanion.insert(
                id: item['id'],
                productId: item['product_id'],
                inventoryItemId: Value(item['inventory_item_id']),
                amount: Value(amountVal),
              ),
            );
          }

          // Insert Promos
          for (final item in promos) {
            final promoType = item['promo_type']?.toString() ?? 'fixed';
            final targetType = item['target_type']?.toString() ?? 'product';
            final discountVal = double.tryParse(item['discount_value']?.toString() ?? '0') ?? 0.0;
            final maxDiscVal = item['max_discount'] != null ? double.tryParse(item['max_discount'].toString()) : null;
            final startDate = item['start_date'] != null ? DateTime.tryParse(item['start_date'].toString()) : null;
            final endDate = item['end_date'] != null ? DateTime.tryParse(item['end_date'].toString()) : null;
            final appliesAll = item['applies_to_all_outlets'] == 1 || item['applies_to_all_outlets'] == true || item['applies_to_all_outlets'] == 'true' || item['applies_to_all_outlets'] == null;

            await _database.into(_database.promos).insert(
              PromosCompanion.insert(
                id: item['id'],
                name: item['name'],
                description: Value(item['description']),
                promoType: promoType,
                targetType: targetType,
                discountValue: discountVal,
                maxDiscount: Value(maxDiscVal),
                appliesToAllOutlets: Value(appliesAll),
                status: Value(item['status']?.toString() ?? 'active'),
                startDate: Value(startDate),
                endDate: Value(endDate),
              ),
            );
          }

          // Insert Customers
          for (final item in customers) {
            await _database.into(_database.customers).insert(
              CustomersCompanion.insert(
                id: item['id'],
                name: item['name'],
                phone: Value(item['phone'] ?? item['phone_number']),
                email: Value(item['email']),
                code: Value(item['code'] ?? item['customer_code']),
              ),
            );
          }
        });
      }
    } on DioException catch (e) {
      throw Exception(
        'Failed to fetch master data: ${e.response?.data['message'] ?? e.message}',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
