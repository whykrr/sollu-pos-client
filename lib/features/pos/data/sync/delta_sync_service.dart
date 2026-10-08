import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/database/app_database.dart';
import 'initial_sync_service.dart';

class DeltaSyncService {
  final DioClient _dioClient;
  final AppDatabase _database;
  final SharedPreferences? _prefs;
  final InitialSyncService? _initialSyncService;

  DeltaSyncService(
    this._dioClient,
    this._database, [
    this._prefs,
    this._initialSyncService,
  ]);

  /// Jalankan Delta Sync berbasis timestamp terakhir.
  /// Jika belum pernah sinkronisasi, secara otomatis melakukan fallback ke InitialSyncService.
  Future<DateTime> syncDeltaCatalog({DateTime? since}) async {
    final DateTime? effectiveSince = since ?? _getLastSyncedAt();

    if (effectiveSince == null) {
      debugPrint('[DeltaSync] No previous sync timestamp found. Delegating to InitialSync.');
      if (_initialSyncService != null) {
        return await _initialSyncService.syncInitialSnapshot();
      }
      throw Exception('Belum ada riwayat sinkronisasi dan InitialSyncService tidak tersedia.');
    }

    try {
      final response = await _dioClient.dio.get(
        ApiEndpoints.syncDelta,
        queryParameters: {
          'updated_since': effectiveSince.toIso8601String(),
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      final Map<String, dynamic> data = response.data['data'] ?? {};
      final String? syncedAtStr = data['synced_at']?.toString();
      final DateTime syncedAt = syncedAtStr != null
          ? DateTime.tryParse(syncedAtStr) ?? DateTime.now()
          : DateTime.now();

      final List<dynamic> updatedProducts = data['updated_products'] ?? [];
      final List<dynamic> updatedProductItems = data['updated_product_items'] ?? [];
      final List<dynamic> updatedPrices = data['updated_prices'] ?? [];
      final List<dynamic> updatedBalances = data['updated_inventory_balances'] ?? [];
      final List<dynamic> deletedProductIds = data['deleted_product_ids'] ?? [];
      final List<dynamic> deletedProductItemIds = data['deleted_product_item_ids'] ?? [];

      debugPrint(
        '[DeltaSync] Fetched delta: ${updatedProducts.length} products, '
        '${updatedProductItems.length} items, ${updatedPrices.length} prices, '
        '${updatedBalances.length} balances, ${deletedProductIds.length} deleted products, '
        '${deletedProductItemIds.length} deleted items.',
      );

      await _database.transaction(() async {
        // 1. Tangani Soft-Deleted / Disabled Product Items
        if (deletedProductItemIds.isNotEmpty) {
          final stringItemIds = deletedProductItemIds.map((e) => e.toString()).toList();
          await (_database.delete(_database.productPrices)
                ..where((t) => t.inventoryItemId.isIn(stringItemIds)))
              .go();
          await (_database.delete(_database.inventories)
                ..where((t) => t.id.isIn(stringItemIds)))
              .go();
        }

        // 2. Tangani Soft-Deleted / Disabled Products
        if (deletedProductIds.isNotEmpty) {
          final stringProductIds = deletedProductIds.map((e) => e.toString()).toList();
          await (_database.delete(_database.productPrices)
                ..where((t) => t.productId.isIn(stringProductIds)))
              .go();
          await (_database.delete(_database.inventories)
                ..where((t) => t.productId.isIn(stringProductIds)))
              .go();
          await (_database.delete(_database.products)
                ..where((t) => t.id.isIn(stringProductIds)))
              .go();
        }

        // 3. Upsert Updated Products
        for (final item in updatedProducts) {
          final productId = item['id']?.toString() ?? '';
          if (productId.isEmpty) continue;

          final isShow =
              item['is_show'] == 1 ||
              item['is_show'] == true ||
              item['is_show'] == 'true' ||
              item['is_show'] == null;

          final rawPrice = item['price'];
          final priceVal = double.tryParse(rawPrice?.toString() ?? '0') ?? 0.0;

          await _database.into(_database.products).insertOnConflictUpdate(
                ProductsCompanion(
                  id: Value(productId),
                  name: Value(item['name']?.toString() ?? ''),
                  categoryId: Value(
                    item['product_category_id']?.toString() ??
                        item['category_id']?.toString(),
                  ),
                  sku: Value(item['sku']?.toString()),
                  barcode: Value(item['barcode']?.toString()),
                  price: Value(priceVal),
                  isAvailable: Value(isShow),
                  productType: Value(item['product_type']?.toString() ?? 'basic'),
                  unit: Value(
                    item['unit']?.toString() ??
                        item['uom']?.toString() ??
                        'Pcs',
                  ),
                ),
              );
        }

        // 4. Upsert Updated Product Items (Varian & Item Standalone)
        for (final item in updatedProductItems) {
          final invItem = item['inventory_item'];
          final invId = (invItem != null && invItem['id'] != null)
              ? invItem['id'].toString()
              : item['id']?.toString() ?? '';
          final prodId = item['product_id']?.toString() ?? '';

          if (invId.isEmpty || prodId.isEmpty) continue;

          final isTrack =
              item['track_inventory'] == 1 ||
              item['track_inventory'] == true ||
              item['track_inventory'] == 'true';

          final isActive =
              item['is_active'] == 1 ||
              item['is_active'] == true ||
              item['is_active'] == 'true' ||
              item['is_active'] == null;

          final uomName = item['uom'] != null
              ? item['uom']['name']?.toString() ?? 'Pcs'
              : 'Pcs';

          await _database.into(_database.inventories).insertOnConflictUpdate(
                InventoriesCompanion(
                  id: Value(invId),
                  productId: Value(prodId),
                  name: Value(item['name']?.toString() ?? ''),
                  sku: Value(item['sku']?.toString()),
                  barcode: Value(item['barcode']?.toString()),
                  trackInventory: Value(isTrack),
                  isActive: Value(isActive),
                  unit: Value(uomName),
                ),
              );
        }

        // 5. Upsert Updated Prices
        for (final p in updatedPrices) {
          final priceId = p['id']?.toString() ?? '';
          final prodId = p['product_id']?.toString() ?? '';
          if (priceId.isEmpty || prodId.isEmpty) continue;

          final rawAmount = p['amount'] ?? p['price'];
          final amountVal = double.tryParse(rawAmount?.toString() ?? '0') ?? 0.0;
          final invItemId = p['inventory_item_id']?.toString();

          await _database.into(_database.productPrices).insertOnConflictUpdate(
                ProductPricesCompanion(
                  id: Value(priceId),
                  productId: Value(prodId),
                  inventoryItemId: Value(invItemId),
                  amount: Value(amountVal),
                ),
              );
        }

        // 6. Update Mutated Inventory Balances
        for (final bal in updatedBalances) {
          final itemId = bal['inventory_item_id']?.toString() ?? '';
          if (itemId.isEmpty) continue;

          final rawStock = bal['current_stock'] ?? bal['stock'];
          final stockVal = double.tryParse(rawStock?.toString() ?? '0') ?? 0.0;

          await (_database.update(_database.inventories)
                ..where((t) => t.id.equals(itemId)))
              .write(
                InventoriesCompanion(
                  stock: Value(stockVal),
                ),
              );
        }
      });

      // Simpan synced_at baru ke SharedPreferences
      if (_prefs != null) {
        await _prefs.setString('last_sync_at', syncedAt.toIso8601String());
        await _prefs.setString('last_synced_at', syncedAt.toIso8601String());
      }

      return syncedAt;
    } on DioException catch (e) {
      throw Exception(
        'Failed to fetch delta catalog: ${e.response?.data?['message'] ?? e.message}',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred during delta sync: $e');
    }
  }

  DateTime? _getLastSyncedAt() {
    if (_prefs == null) return null;
    final stored = _prefs.getString('last_sync_at') ?? _prefs.getString('last_synced_at');
    if (stored != null) {
      return DateTime.tryParse(stored);
    }
    return null;
  }
}
