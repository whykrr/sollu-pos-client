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
      final response = await _dioClient.dio.get('/pos/sync/master');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data['data'];
        
        final List<dynamic> products = data['products'] ?? [];
        final List<dynamic> productPrices = data['product_prices'] ?? [];
        final List<dynamic> paymentMethods = data['payment_methods'] ?? [];
        final List<dynamic> outletSettings = data['outlet_settings'] ?? [];
        final List<dynamic> inventoryItems = data['inventory_items'] ?? [];
        final List<dynamic> inventoryBalances = data['inventory_balances'] ?? [];

        // Helper map to quickly find price by product_id
        final Map<String, double> priceMap = {};
        for (var p in productPrices) {
          priceMap[p['product_id']] = double.tryParse(p['price'].toString()) ?? 0.0;
        }

        // Helper map to quickly find stock by product_id
        final Map<String, String> itemToProductMap = {};
        for (var item in inventoryItems) {
          itemToProductMap[item['id']] = item['product_id'];
        }

        final Map<String, double> stockMap = {};
        for (var bal in inventoryBalances) {
          final productId = itemToProductMap[bal['inventory_item_id']];
          if (productId != null) {
            stockMap[productId] = (stockMap[productId] ?? 0) + (double.tryParse(bal['current_stock'].toString()) ?? 0.0);
          }
        }

        await _database.transaction(() async {
          // Clear old data
          await _database.delete(_database.products).go();
          await _database.delete(_database.paymentMethods).go();
          await _database.delete(_database.outletSettings).go();
          await _database.delete(_database.inventories).go();
          
          // Insert Products
          for (final item in products) {
            final productId = item['id'];
            await _database.into(_database.products).insert(
              ProductsCompanion.insert(
                id: productId,
                name: item['name'],
                categoryId: Value(item['category_id']),
                sku: Value(item['sku']),
                barcode: Value(item['barcode']),
                price: priceMap[productId] ?? 0.0,
                isAvailable: Value(item['is_active'] == 1 || item['is_active'] == true),
              ),
            );
          }

          // Insert Payment Methods
          for (final item in paymentMethods) {
            await _database.into(_database.paymentMethods).insert(
              PaymentMethodsCompanion.insert(
                id: item['id'],
                name: item['name'],
                type: item['type'],
                isActive: Value(item['is_active'] == 1 || item['is_active'] == true),
              ),
            );
          }

          // Insert Outlet Settings
          for (final item in outletSettings) {
            await _database.into(_database.outletSettings).insert(
              OutletSettingsCompanion.insert(
                id: item['id'],
                taxPercentage: Value(double.tryParse(item['tax_rate']?.toString() ?? '0') ?? 0.0),
                serviceChargePercentage: Value(double.tryParse(item['service_charge']?.toString() ?? '0') ?? 0.0),
                printerMacAddress: Value(item['printer_mac_address']),
              ),
            );
          }

          // Insert Inventories
          for (final entry in stockMap.entries) {
            await _database.into(_database.inventories).insert(
              InventoriesCompanion.insert(
                productId: entry.key,
                stock: Value(entry.value),
              ),
            );
          }
        });
      }
    } on DioException catch (e) {
      throw Exception('Failed to fetch master data: ${e.response?.data['message'] ?? e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
