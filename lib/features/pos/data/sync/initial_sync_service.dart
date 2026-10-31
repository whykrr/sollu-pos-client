import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/services/outlet_settings_service.dart';

class InitialSyncService {
  final DioClient _dioClient;
  final AppDatabase _database;
  final OutletSettingsService _outletSettingsService;
  final SharedPreferences? _prefs;

  InitialSyncService(
    this._dioClient,
    this._database,
    this._outletSettingsService, [
    this._prefs,
  ]);

  /// Unduh snapshot master data penuh (Initial Sync) dan simpan ke Drift SQLite.
  /// Menyimpan synced_at ke SharedPreferences agar sinkronisasi berikutnya berupa Delta Sync.
  Future<DateTime> syncInitialSnapshot() async {
    try {
      final response = await _dioClient.dio.get(ApiEndpoints.syncInitial);

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final Map<String, dynamic> data = response.data['data'] ?? {};
      final String? syncedAtStr = data['synced_at']?.toString();
      final DateTime syncedAt = syncedAtStr != null
          ? DateTime.tryParse(syncedAtStr) ?? DateTime.now()
          : DateTime.now();

      final List<dynamic> products = data['products'] ?? [];
      final List<dynamic> productItems = data['product_items'] ?? [];
      final List<dynamic> productItemVariantGroupOptions =
          data['product_item_variant_group_options'] ?? [];
      final List<dynamic> productPrices = data['product_prices'] ?? [];
      final List<dynamic> paymentMethods = data['payment_methods'] ?? [];
      final List<dynamic> rawEmployees = data['employees'] ?? [];
      final List<dynamic> outletProducts = data['outlet_products'] ?? [];
      final List<dynamic> inventoryItems = data['inventory_items'] ?? [];
      final List<dynamic> inventoryBalances = data['inventory_balances'] ?? [];

      final List<dynamic> productCategories = data['product_categories'] ?? [];
      final List<dynamic> variantGroups = data['variant_groups'] ?? [];
      final List<dynamic> variantGroupOptions = data['variant_group_options'] ?? [];
      final List<dynamic> productModifierGroups = data['product_modifier_groups'] ?? [];
      final List<dynamic> modifierGroups = data['modifier_groups'] ?? [];
      final List<dynamic> modifierOptions = data['modifier_options'] ?? [];
      final List<dynamic> inventoryItemVariantGroupOptions =
          data['inventory_item_variant_group_options'] ?? [];
      final List<dynamic> promos = data['promos'] ?? [];
      final List<dynamic> customers = data['customers'] ?? [];

      // Helper map to quickly find price by product_id
      final Map<String, double> priceMap = {};
      for (var p in productPrices) {
        final prodId = p['product_id'];
        if (prodId != null) {
          final rawAmount = p['amount'] ?? p['price'];
          final amountVal = double.tryParse(rawAmount?.toString() ?? '0') ?? 0.0;
          if (amountVal > 0 &&
              (!priceMap.containsKey(prodId) || p['inventory_item_id'] == null)) {
            priceMap[prodId] = amountVal;
          }
        }
      }

      // Helper map to check outlet product availability & enabled status
      final Map<String, bool> outletProductAvailability = {};
      for (var op in outletProducts) {
        final prodId = op['product_id'];
        if (prodId != null) {
          final isEnabled =
              op['is_enabled'] == 1 ||
              op['is_enabled'] == true ||
              op['is_enabled'] == 'true' ||
              op['is_enabled'] == null;
          final isAvailable =
              op['is_available'] == 1 ||
              op['is_available'] == true ||
              op['is_available'] == 'true' ||
              op['is_available'] == null;
          outletProductAvailability[prodId] = isEnabled && isAvailable;
        }
      }

      // Helper map to quickly find stock by inventory_item_id
      final Map<String, double> stockByItemId = {};
      for (var bal in inventoryBalances) {
        final itemId = bal['inventory_item_id'];
        stockByItemId[itemId] =
            (stockByItemId[itemId] ?? 0) +
            (double.tryParse(bal['current_stock'].toString()) ?? 0.0);
      }

      await _database.transaction(() async {
        // Clear old catalog data in FK safe order
        await _database.delete(_database.productItemVariantGroupOptions).go();
        await _database.delete(_database.inventoryItemVariantGroupOptions).go();
        await _database.delete(_database.productModifierGroups).go();
        await _database.delete(_database.modifierOptions).go();
        await _database.delete(_database.modifierGroups).go();
        await _database.delete(_database.variantGroupOptions).go();
        await _database.delete(_database.variantGroups).go();
        await _database.delete(_database.productPrices).go();
        await _database.delete(_database.inventories).go();
        await _database.delete(_database.productItems).go();
        await _database.delete(_database.products).go();
        await _database.delete(_database.productCategories).go();
        await _database.delete(_database.paymentMethods).go();
        await _database.delete(_database.promos).go();
        await _database.delete(_database.customers).go();

        // 1. Insert Products
        for (final item in products) {
          final productId = item['id'];
          final isShow =
              item['is_show'] == 1 ||
              item['is_show'] == true ||
              item['is_show'] == 'true' ||
              item['is_show'] == null;
          final isAvailableAtOutlet =
              outletProductAvailability.containsKey(productId)
                  ? outletProductAvailability[productId]!
                  : true;
          final isAvailable = isShow && isAvailableAtOutlet;

          await _database.into(_database.products).insert(
                ProductsCompanion.insert(
                  id: productId,
                  name: item['name'],
                  categoryId: Value(
                    item['product_category_id'] ?? item['category_id'],
                  ),
                  sku: Value(item['sku']),
                  barcode: Value(item['barcode']),
                  price: Value((item['price'] != null
                          ? double.tryParse(item['price'].toString())
                          : null) ??
                      priceMap[productId] ??
                      0.0),
                  isAvailable: Value(isAvailable),
                  productType: Value(
                    item['product_type']?.toString() ?? 'basic',
                  ),
                  unit: Value(
                    item['unit']?.toString() ??
                        item['uom']?.toString() ??
                        'Pcs',
                  ),
                  hasVariants: Value(
                    item['has_variant'] == 1 ||
                        item['has_variant'] == true ||
                        item['has_variants'] == 1 ||
                        item['has_variants'] == true,
                  ),
                  hasModifiers: Value(
                    item['has_modifier'] == 1 ||
                        item['has_modifier'] == true ||
                        item['has_modifiers'] == 1 ||
                        item['has_modifiers'] == true,
                  ),
                  hasRecipe: Value(
                    item['has_recipe'] == 1 || item['has_recipe'] == true,
                  ),
                  trackInventory: Value(
                    item['track_inventory'] == 1 ||
                        item['track_inventory'] == true,
                  ),
                ),
              );
        }

        // 1b. Insert Product Items
        for (final item in productItems) {
          final itemId = item['id']?.toString() ?? '';
          final prodId = item['product_id']?.toString() ?? '';
          if (itemId.isEmpty || prodId.isEmpty) continue;

          final isTrack =
              item['track_inventory'] == 1 || item['track_inventory'] == true;
          final isShow =
              item['is_show'] == 1 ||
              item['is_show'] == true ||
              item['is_show'] == 'true' ||
              item['is_show'] == null;
          final sellable =
              item['sellable'] == 1 ||
              item['sellable'] == true ||
              item['sellable'] == 'true' ||
              item['sellable'] == null;
          final isActive =
              item['is_active'] == 1 ||
              item['is_active'] == true ||
              item['is_active'] == 'true' ||
              item['is_active'] == null;

          await _database.into(_database.productItems).insert(
                ProductItemsCompanion.insert(
                  id: itemId,
                  productId: prodId,
                  name: item['name']?.toString() ?? '',
                  variantCombination:
                      Value(item['variant_combination']?.toString()),
                  sku: Value(item['sku']?.toString()),
                  barcode: Value(item['barcode']?.toString()),
                  trackInventory: Value(isTrack),
                  isActive: Value(isActive && isShow && sellable),
                  sellable: Value(sellable),
                  unit: Value(
                    item['unit']?.toString() ??
                        item['uom']?.toString() ??
                        'Pcs',
                  ),
                ),
              );
        }

        // 2. Insert Payment Methods
        for (final item in paymentMethods) {
          final methodId = item['id']?.toString() ?? '';
          if (methodId.isEmpty) continue;

          await _database.into(_database.paymentMethods).insert(
                PaymentMethodsCompanion.insert(
                  id: methodId,
                  name: item['name']?.toString() ?? '',
                  type: item['type']?.toString() ?? 'cash',
                  provider: Value(item['provider']?.toString()),
                  accountNumber: Value(item['account_number']?.toString()),
                  accountName: Value(item['account_name']?.toString()),
                  referencePolicy: Value(
                    item['reference_policy']?.toString() ?? 'optional',
                  ),
                  openCashDrawer: Value(
                    item['open_cash_drawer'] == 1 ||
                        item['open_cash_drawer'] == true ||
                        item['open_cash_drawer'] == 'true',
                  ),
                  instructions: Value(item['instructions']?.toString()),
                  qrImageUrl: Value(item['qr_image_url']?.toString()),
                  isSystem: Value(
                    item['is_system'] == 1 ||
                        item['is_system'] == true ||
                        item['is_system'] == 'true',
                  ),
                  isActive: Value(
                    item['is_active'] == 1 ||
                        item['is_active'] == true ||
                        item['is_active'] == 'true' ||
                        item['is_active'] == null,
                  ),
                ),
              );
        }

        // 3. Insert Employees
        if (rawEmployees.isNotEmpty) {
          await _database.delete(_database.employees).go();
          for (final emp in rawEmployees) {
            final rawPerms = emp['permissions'];
            final String? permsJson = rawPerms is List
                ? jsonEncode(rawPerms)
                : (rawPerms is String ? rawPerms : null);
            final bool isRoot =
                emp['is_root_user'] == true ||
                emp['is_root_user'] == 1 ||
                emp['role'] == 'Akun Utama';
            final String role =
                emp['role'] ?? (isRoot ? 'Akun Utama' : 'Kasir');

            await _database.into(_database.employees).insert(
                  EmployeesCompanion.insert(
                    id: emp['id'],
                    name: emp['name'],
                    email: Value(emp['email']),
                    pin: Value(emp['pin']),
                    photo: Value(emp['photo']),
                    role: Value(role),
                    permissions: Value(permsJson),
                    isRootUser: Value(isRoot),
                  ),
                );
          }
        }

        // 4. Insert Outlet Settings & Receipts
        await _outletSettingsService.syncSettingsPayload(
          data: data,
          dioClient: _dioClient,
        );

        // 5. Insert Inventories
        for (final item in inventoryItems) {
          final itemId = item['id'];
          final isInvActive =
              item['is_active'] == 1 ||
              item['is_active'] == true ||
              item['is_active'] == 'true' ||
              item['is_active'] == null;

          await _database.into(_database.inventories).insert(
                InventoriesCompanion.insert(
                  id: itemId,
                  productId: item['product_id'],
                  productItemId: Value(item['product_item_id']?.toString()),
                  name: item['name'],
                  sku: Value(item['sku']),
                  barcode: Value(item['barcode']),
                  trackInventory: Value(
                    item['track_inventory'] == 1 ||
                        item['track_inventory'] == true ||
                        item['track_inventory'] == 'true',
                  ),
                  isActive: Value(isInvActive),
                  stock: Value(stockByItemId[itemId] ?? 0.0),
                  unit: Value(
                    item['unit']?.toString() ??
                        item['uom']?.toString() ??
                        'Pcs',
                  ),
                ),
              );
        }

        // 6. Insert Product Categories
        for (final item in productCategories) {
          await _database.into(_database.productCategories).insert(
                ProductCategoriesCompanion.insert(
                  id: item['id'],
                  name: item['name'],
                  parentId: Value(item['parent_id']),
                  sortOrder: Value(
                    int.tryParse(item['sort_order']?.toString() ?? '0') ?? 0,
                  ),
                ),
              );
        }

        // 7. Insert Variant Groups
        for (final item in variantGroups) {
          await _database.into(_database.variantGroups).insert(
                VariantGroupsCompanion.insert(
                  id: item['id'],
                  productId: item['product_id'],
                  name: item['name'],
                ),
              );
        }

        // 8. Insert Variant Group Options
        for (final item in variantGroupOptions) {
          await _database.into(_database.variantGroupOptions).insert(
                VariantGroupOptionsCompanion.insert(
                  id: item['id'],
                  variantGroupId: item['variant_group_id'],
                  name: item['name'],
                ),
              );
        }

        // 8b. Insert Product Item Variant Group Options
        for (final item in productItemVariantGroupOptions) {
          final pItemId = item['product_item_id']?.toString();
          final vOptId = item['variant_group_option_id']?.toString();
          if (pItemId != null &&
              vOptId != null &&
              pItemId.isNotEmpty &&
              vOptId.isNotEmpty) {
            await _database
                .into(_database.productItemVariantGroupOptions)
                .insert(
                  ProductItemVariantGroupOptionsCompanion.insert(
                    productItemId: pItemId,
                    variantGroupOptionId: vOptId,
                  ),
                  mode: InsertMode.insertOrReplace,
                );
          }
        }

        // 9. Insert Modifier Groups
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

        // 10. Insert Modifier Options
        for (final item in modifierOptions) {
          await _database.into(_database.modifierOptions).insert(
                ModifierOptionsCompanion.insert(
                  id: item['id'],
                  modifierGroupId: item['modifier_group_id'],
                  name: item['name'],
                  price: Value(
                    double.tryParse(item['price']?.toString() ?? '0') ?? 0.0,
                  ),
                ),
              );
        }

        // 11. Insert Product Modifier Groups
        for (final item in productModifierGroups) {
          await _database.into(_database.productModifierGroups).insert(
                ProductModifierGroupsCompanion.insert(
                  productId: item['product_id'],
                  modifierGroupId: item['modifier_group_id'],
                ),
              );
        }

        // 12. Insert Inventory Item Variant Group Options
        for (final item in inventoryItemVariantGroupOptions) {
          await _database.into(_database.inventoryItemVariantGroupOptions).insert(
                InventoryItemVariantGroupOptionsCompanion.insert(
                  inventoryItemId: item['inventory_item_id'],
                  variantGroupOptionId: item['variant_group_option_id'],
                ),
              );
        }

        // 13. Insert Product Prices
        for (final item in productPrices) {
          final rawAmount = item['amount'] ?? item['price'];
          final amountVal = double.tryParse(rawAmount?.toString() ?? '0') ?? 0.0;

          await _database.into(_database.productPrices).insert(
                ProductPricesCompanion.insert(
                  id: item['id'],
                  productId: item['product_id'],
                  productItemId: Value(item['product_item_id']?.toString()),
                  inventoryItemId: Value(item['inventory_item_id']?.toString()),
                  amount: Value(amountVal),
                ),
              );
        }

        // 14. Insert Promos
        for (final item in promos) {
          final promoType = item['promo_type']?.toString() ?? 'fixed';
          final targetType = item['target_type']?.toString() ?? 'product';
          final discountVal =
              double.tryParse(item['discount_value']?.toString() ?? '0') ?? 0.0;
          final maxDiscVal = item['max_discount'] != null
              ? double.tryParse(item['max_discount'].toString())
              : null;
          final startDate = item['start_date'] != null
              ? DateTime.tryParse(item['start_date'].toString())
              : null;
          final endDate = item['end_date'] != null
              ? DateTime.tryParse(item['end_date'].toString())
              : null;
          final appliesAll =
              item['applies_to_all_outlets'] == 1 ||
              item['applies_to_all_outlets'] == true ||
              item['applies_to_all_outlets'] == 'true' ||
              item['applies_to_all_outlets'] == null;

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

        // 15. Insert Customers
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

      // Simpan synced_at ke SharedPreferences (SSOT: last_sync_at)
      if (_prefs != null) {
        await _prefs.setString('last_sync_at', syncedAt.toIso8601String());
        await _prefs.remove('last_synced_at');
      }

      return syncedAt;
    } on DioException catch (e) {
      throw Exception(
        'Failed to fetch initial master data: ${e.response?.data?['message'] ?? e.message}',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred during initial sync: $e');
    }
  }
}
