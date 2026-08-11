import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
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
        final List<dynamic> inventoryItems = data['inventory_items'] ?? [];
        final List<dynamic> inventoryBalances = data['inventory_balances'] ?? [];
        
        final List<dynamic> productCategories = data['product_categories'] ?? [];
        final List<dynamic> variantGroups = data['variant_groups'] ?? [];
        final List<dynamic> variantGroupOptions = data['variant_group_options'] ?? [];
        final List<dynamic> productModifierGroups = data['product_modifier_groups'] ?? [];
        final List<dynamic> modifierGroups = data['modifier_groups'] ?? [];
        final List<dynamic> modifierOptions = data['modifier_options'] ?? [];
        final List<dynamic> inventoryItemVariantGroupOptions = data['inventory_item_variant_group_options'] ?? [];

        // Helper map to quickly find price by product_id
        final Map<String, double> priceMap = {};
        for (var p in productPrices) {
          priceMap[p['product_id']] =
              double.tryParse(p['price'].toString()) ?? 0.0;
        }

        // Helper map to quickly find stock by inventory_item_id
        final Map<String, double> stockByItemId = {};
        for (var bal in inventoryBalances) {
          final itemId = bal['inventory_item_id'];
          stockByItemId[itemId] = (stockByItemId[itemId] ?? 0) +
              (double.tryParse(bal['current_stock'].toString()) ?? 0.0);
        }

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

          // Insert Products
          for (final item in products) {
            final productId = item['id'];
            await _database
                .into(_database.products)
                .insert(
                  ProductsCompanion.insert(
                    id: productId,
                    name: item['name'],
                    categoryId: Value(item['category_id']),
                    sku: Value(item['sku']),
                    barcode: Value(item['barcode']),
                    price: priceMap[productId] ?? 0.0,
                    isAvailable: Value(
                      item['is_active'] == 1 || item['is_active'] == true,
                    ),
                  ),
                );
          }

          // Insert Payment Methods
          for (final item in paymentMethods) {
            await _database
                .into(_database.paymentMethods)
                .insert(
                  PaymentMethodsCompanion.insert(
                    id: item['id'],
                    name: item['name'],
                    type: item['type'],
                    isActive: Value(
                      item['is_active'] == 1 || item['is_active'] == true,
                    ),
                  ),
                );
          }

          // Insert Outlet Settings
          for (final item in outletSettings) {
            await _database
                .into(_database.outletSettings)
                .insert(
                  OutletSettingsCompanion.insert(
                    id: item['id'],
                    taxPercentage: Value(
                      double.tryParse(item['tax_rate']?.toString() ?? '0') ??
                          0.0,
                    ),
                    serviceChargePercentage: Value(
                      double.tryParse(
                            item['service_charge']?.toString() ?? '0',
                          ) ??
                          0.0,
                    ),
                    printerMacAddress: Value(item['printer_mac_address']),
                  ),
                );
          }

          // Insert Inventories
          for (final item in inventoryItems) {
            final itemId = item['id'];
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
                      item['track_inventory'] == 1 || item['track_inventory'] == true,
                    ),
                    isActive: Value(
                      item['is_active'] == 1 || item['is_active'] == true,
                    ),
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
            await _database.into(_database.productPrices).insert(
              ProductPricesCompanion.insert(
                id: item['id'],
                productId: item['product_id'],
                inventoryItemId: Value(item['inventory_item_id']),
                amount: Value(double.tryParse(item['amount']?.toString() ?? '0') ?? 0.0),
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
