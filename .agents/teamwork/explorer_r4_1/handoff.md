# Handoff Report: Milestone R4 & R5 Architecture Investigation (Flutter POS Drift SQLite & Repository)

**Target Workspace:** `/Users/whykrr/Documents/Projects/Flutter/sollu-pos-client`  
**Agent:** Explorer R4 (`explorer_r4_1`)  
**Date:** 2026-10-22  
**Status:** Hard Handoff (Investigation & Architecture Specification Complete)

---

## 1. Observation

### 1.1 Drift SQLite Database Schema & Tables
- **Current Database File:** `lib/core/database/app_database.dart`
  - Line 45: `schemaVersion => 9;`
  - Lines 14-39: `@DriftDatabase(tables: [Products, ProductCategories, VariantGroups, VariantGroupOptions, InventoryItemVariantGroupOptions, ModifierGroups, ProductModifierGroups, ModifierOptions, ProductPrices, Inventories, PaymentMethods, Shifts, ShiftCashLogs, Transactions, TransactionItems, TransactionItemModifiers, TransactionPayments, TransactionPromos, Employees, Promos, Customers, HeldTransactions])`
  - Note: `ProductItems` and `ProductItemVariantGroupOptions` are **not yet defined** or registered in `@DriftDatabase`.
- **Master Data Tables:** `lib/core/database/tables/master_data_tables.dart`
  - Lines 4-17: `Products` table has `id`, `name`, `categoryId`, `sku`, `barcode`, `price`, `isAvailable`, `productType`, `unit`. It lacks `hasVariants`, `hasModifiers`, `hasRecipe`, and `trackInventory`.
  - Lines 50-58: `InventoryItemVariantGroupOptions` table joins `inventoryItemId` (`Inventories`) with `variantGroupOptionId`.
  - Lines 93-102: `ProductPrices` table only references `productId` and `inventoryItemId` (lacks `productItemId`).
  - Lines 104-121: `Inventories` table references `productId` (`Products`). It lacks `productItemId`.
- **Transaction Tables:** `lib/core/database/tables/transaction_tables.dart`
  - Lines 88-108: `TransactionItems` has `productId`, `inventoryItemId`, `variantGroupOptionId`, but lacks `productItemId`.

### 1.2 Sync Pipeline
- **Initial Sync:** `lib/features/pos/data/sync/initial_sync_service.dart`
  - Lines 39-57: Ingests `products`, `product_prices`, `inventory_items`, `inventory_balances`, `variant_groups`, `variant_group_options`, `inventory_item_variant_group_options`.
  - Lines 110-123: Deletes old catalog data in transaction before re-inserting.
  - Does NOT yet ingest `data['product_items']` or `data['product_item_variant_group_options']`.
  - Backend API (`MasterDataSyncService.php` lines 240-264) already returns both `product_items` and `product_item_variant_group_options`.
- **Delta Sync:** `lib/features/pos/data/sync/delta_sync_service.dart`
  - Lines 63, 67: Ingests `updated_product_items` and `deleted_product_item_ids`.
  - Lines 139-175: Currently treats `updated_product_items` as updates to the legacy `inventories` table instead of inserting/updating into `product_items`.

### 1.3 PosRepository & Query Analysis
- **Current Repository:** `lib/features/pos/data/pos_repository.dart`
  - Lines 44-101: `watchVariantModeItems()` executes a legacy `UNION ALL` query:
    1. Query 1: `inventories i INNER JOIN products p ON i.product_id = p.id`
    2. Query 2: `products p WHERE (p.product_type = 'service' OR (SELECT COUNT(id) FROM inventories WHERE product_id = p.id) = 0)`
  - **Defect in Legacy Approach:** Under Unified Item Pattern, products with `track_inventory = false` (or single goods without inventory items) have no records in `inventories`. When variants exist with `track_inventory = false`, Query 2 only sees the parent product, losing variant names, combinations, SKUs, and variant-specific barcodes!
  - Lines 285-412: `findItemByBarcodeOrSku(String query)` executes two sequential queries: first on `inventories`, then fallback on `products`.
  - Lines 415-435: `findInventoryItemIdForVariant(...)` joins `inventories` with `inventory_item_variant_group_options`. For non-inventory variants (`track_inventory = false`), this returns `null`, preventing variant price resolution in `VariantDialogNotifier`.
  - Lines 447-503: `checkCartStockAvailability(...)` only checks stock if `inventory != null && inventory.trackInventory`. However, it relies on resolving `inventoryItemId`.

### 1.4 POS Presentation Providers & Cart Integration
- **Category Filter & Search Provider:** `lib/features/pos/presentation/providers/pos_provider.dart`
  - Lines 66-81: Gathers child category IDs for aggregative category filtering.
  - Lines 89-95: Search query matches `name` and `barcode`, but misses `sku` and `variantCombination`.
- **Variant Dialog:** `lib/features/pos/presentation/providers/variant_dialog_provider.dart`
  - Lines 155-175: Resolves price by joining `inventories` and `inventory_item_variant_group_options`. When `product_items` has `track_inventory = false`, price resolution fails.
- **Cart Provider:** `lib/features/pos/presentation/providers/cart_provider.dart`
  - Lines 4-33: `CartItem` holds `productId` and `inventoryItemId`, but does NOT hold `productItemId` or `trackInventory`.
  - Lines 125-156: Deduplication logic compares `inventoryItemId` and `productId`, which causes issues when multiple variants share empty inventory IDs.

### 1.5 Tooling, Lint & Tests Baseline
- Command `/Users/whykrr/flutter/bin/flutter test` passed with **38 passed tests** (0 failures).
- Command `/Users/whykrr/flutter/bin/flutter analyze` reported 12 minor style/info warnings in existing files, 0 errors.

---

## 2. Logic Chain

1. **Unified Item Pattern Necessity:**
   - In backend Laravel (`sollu-app`), Milestone R1 and R2 have established that **every product** has 1..N `ProductItem` records. Single products have 1 default `ProductItem` (`variant_combination = null`). Variant products have N `ProductItem` records linked via `product_item_variant_group_options`.
   - Inventory tracking is totally decoupled: `InventoryItem` and `Inventories` records are only created when `track_inventory = true`.
   - Therefore, the POS shelf (catalog) must query from `ProductItems` as the source of truth, left-joining `Inventories` for stock balance and `Products` for category and product metadata. This completely eliminates the need for the brittle legacy `UNION ALL` query.

2. **Schema Migration Strategy (v9 -> v10):**
   - Adding `ProductItems` and `ProductItemVariantGroupOptions` tables to SQLite does not invalidate existing data.
   - Adding `hasVariants`, `hasModifiers`, `hasRecipe`, `trackInventory` to `Products`, and `productItemId` to `Inventories`, `ProductPrices`, and `TransactionItems` preserves full backward compatibility.
   - Incrementing `schemaVersion` to `10` with explicit `MigrationStrategy.onUpgrade` ensures seamless migration without requiring app data wipe.

3. **Multi-Key Omni-Search & Aggregative Category Filter:**
   - By querying `ProductItems pi INNER JOIN Products p ON pi.product_id = p.id LEFT JOIN Inventories i ON i.product_item_id = pi.id`, barcode scanners and search text can match `pi.barcode`, `pi.sku`, `p.barcode`, `p.sku`, `pi.name`, and `pi.variant_combination` in a single indexed query.
   - For aggregative category filtering: Because the system enforces a strict 2-level category hierarchy (Root -> Child), an item matches if `p.category_id IN (SELECT id FROM product_categories WHERE id = ? OR parent_id = ?)`. This cleanly covers both parent and child categories.

4. **Milestone R5 Cart & Variant Dialog Decoupling:**
   - In `VariantDialogNotifier`, resolving the variant item requires matching the selected option IDs in `product_item_variant_group_options`. Using `GROUP BY pi.id HAVING COUNT(DISTINCT piv.variant_group_option_id) = :selectedCount` guarantees exact resolution for 1, 2, or N variant groups.
   - In `CartItem`, binding `productItemId` ensures that each unique variant SKU is distinct in the cart.
   - If `track_inventory = false`, `checkCartStockAvailability` skips the item, stock is displayed as `∞` (infinity), and checkout is never blocked.

---

## 3. Caveats

1. **Flutter CLI Sandboxing:** On macOS, executing `flutter` directly in terminal sandboxes may require `BypassSandbox: true` and specifying the absolute path `/Users/whykrr/flutter/bin/flutter`.
2. **Backward Compatibility:** Some legacy test fixtures or offline sync payloads might have items with `inventory_item_id` but missing `product_item_id`. The schema and sync logic should fallback gracefully (`product_item_id ?? inventory_item_id`).
3. **Milestone Boundary:** Milestone R4 focuses on the database tables, sync pipeline, and PosRepository queries. Milestone R5 focuses on UI widgets (`VariantDialog`, `CartPanel`, and infinite stock `∞` rendering). Full code designs for both are provided below so Worker R4 can complete R4 and seamlessly prepare R5.

---

## 4. Conclusion & Actionable Implementation Design

### 4.1 Drift SQLite Schema Changes (`master_data_tables.dart` & `transaction_tables.dart`)

#### `lib/core/database/tables/master_data_tables.dart`
```dart
import 'package:drift/drift.dart';

@DataClassName('Product')
class Products extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get name => text()();
  TextColumn get categoryId => text().nullable()();
  TextColumn get sku => text().nullable()();
  TextColumn get barcode => text().nullable()();
  RealColumn get price => real().withDefault(const Constant(0.0))();
  BoolColumn get isAvailable => boolean().withDefault(const Constant(true))();
  TextColumn get productType => text().withDefault(const Constant('basic'))();
  TextColumn get unit => text().withDefault(const Constant('Pcs'))();
  BoolColumn get hasVariants => boolean().withDefault(const Constant(false))();
  BoolColumn get hasModifiers => boolean().withDefault(const Constant(false))();
  BoolColumn get hasRecipe => boolean().withDefault(const Constant(false))();
  BoolColumn get trackInventory => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ProductItem')
class ProductItems extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get productId => text().references(Products, #id)();
  TextColumn get name => text()();
  TextColumn get variantCombination => text().nullable()();
  TextColumn get sku => text().nullable()();
  TextColumn get barcode => text().nullable()();
  BoolColumn get trackInventory => boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  BoolColumn get sellable => boolean().withDefault(const Constant(true))();
  TextColumn get unit => text().withDefault(const Constant('Pcs'))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ProductItemVariantGroupOption')
class ProductItemVariantGroupOptions extends Table {
  TextColumn get productItemId => text().references(ProductItems, #id)();
  TextColumn get variantGroupOptionId =>
      text().references(VariantGroupOptions, #id)();

  @override
  Set<Column> get primaryKey => {productItemId, variantGroupOptionId};
}

// Preserve InventoryItemVariantGroupOptions for backward compatibility if needed
@DataClassName('InventoryItemVariantGroupOption')
class InventoryItemVariantGroupOptions extends Table {
  TextColumn get inventoryItemId => text().references(Inventories, #id)();
  TextColumn get variantGroupOptionId =>
      text().references(VariantGroupOptions, #id)();

  @override
  Set<Column> get primaryKey => {inventoryItemId, variantGroupOptionId};
}

@DataClassName('Inventories') // DataClassName: Inventory
class Inventories extends Table {
  TextColumn get id => text()(); // UUID dari inventory_item_id
  TextColumn get productId => text().nullable().references(Products, #id)();
  TextColumn get productItemId =>
      text().nullable().references(ProductItems, #id)();
  TextColumn get name => text()();
  TextColumn get sku => text().nullable()();
  TextColumn get barcode => text().nullable()();
  BoolColumn get trackInventory =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  RealColumn get stock => real().withDefault(const Constant(0.0))();
  TextColumn get unit => text().withDefault(const Constant('Pcs'))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ProductPrice')
class ProductPrices extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get productId => text().references(Products, #id)();
  TextColumn get productItemId =>
      text().nullable().references(ProductItems, #id)();
  TextColumn get inventoryItemId =>
      text().nullable().references(Inventories, #id)();
  RealColumn get amount => real().withDefault(const Constant(0.0))();

  @override
  Set<Column> get primaryKey => {id};
}
```

#### `lib/core/database/tables/transaction_tables.dart`
```dart
@DataClassName('TransactionItem')
class TransactionItems extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get transactionId => text().references(Transactions, #id)();
  TextColumn get productId => text().nullable()();
  TextColumn get productItemId => text().nullable()(); // NEW
  TextColumn get inventoryItemId => text().nullable()();
  TextColumn get variantGroupOptionId => text().nullable()();
  TextColumn get productName => text()(); // Denormalized
  RealColumn get price => real()();
  RealColumn get qty => real()();
  TextColumn get discountType => text().nullable()();
  RealColumn get discountValue => real().nullable()();
  RealColumn get discountAmount => real().withDefault(const Constant(0.0))();
  TextColumn get promoName => text().nullable()();
  RealColumn get subtotal => real()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
```

#### `lib/core/database/app_database.dart`
```dart
@DriftDatabase(
  tables: [
    Products,
    ProductCategories,
    VariantGroups,
    VariantGroupOptions,
    ProductItems, // NEW
    ProductItemVariantGroupOptions, // NEW
    InventoryItemVariantGroupOptions,
    ModifierGroups,
    ProductModifierGroups,
    ModifierOptions,
    ProductPrices,
    Inventories,
    PaymentMethods,
    Shifts,
    ShiftCashLogs,
    Transactions,
    TransactionItems,
    TransactionItemModifiers,
    TransactionPayments,
    TransactionPromos,
    Employees,
    Promos,
    Customers,
    HeldTransactions,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 10;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
      },
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          await m.addColumn(productCategories, productCategories.sortOrder);
        }
        if (from < 3) {
          await customStatement('DROP TABLE IF EXISTS outlet_settings;');
        }
        if (from < 4) {
          await m.addColumn(employees, employees.permissions);
        }
        if (from < 5) {
          await m.addColumn(products, products.productType);
          await m.addColumn(products, products.unit);
          await m.addColumn(inventories, inventories.unit);
        }
        if (from < 6) {
          await m.addColumn(employees, employees.isRootUser);
        }
        if (from < 7) {
          await m.createTable(heldTransactions);
        }
        if (from < 8) {
          await m.addColumn(transactions, transactions.syncStatus);
          await m.addColumn(transactions, transactions.syncAttempts);
          await m.addColumn(transactions, transactions.lastSyncError);
          await m.addColumn(transactions, transactions.lastSyncAttemptAt);
        }
        if (from < 9) {
          await m.addColumn(transactions, transactions.type);
        }
        if (from < 10) {
          await m.createTable(productItems);
          await m.createTable(productItemVariantGroupOptions);
          await m.addColumn(products, products.hasVariants);
          await m.addColumn(products, products.hasModifiers);
          await m.addColumn(products, products.hasRecipe);
          await m.addColumn(products, products.trackInventory);
          await m.addColumn(inventories, inventories.productItemId);
          await m.addColumn(productPrices, productPrices.productItemId);
          await m.addColumn(transactionItems, transactionItems.productItemId);
        }
      },
    );
  }
...
```

---

### 4.2 Sync Pipeline Updates

#### In `lib/features/pos/data/sync/initial_sync_service.dart`
```dart
      final List<dynamic> products = data['products'] ?? [];
      final List<dynamic> productItems = data['product_items'] ?? []; // NEW
      final List<dynamic> productItemVariantGroupOptions =
          data['product_item_variant_group_options'] ?? []; // NEW
      final List<dynamic> productPrices = data['product_prices'] ?? [];
      final List<dynamic> inventoryItems = data['inventory_items'] ?? [];
...
      await _database.transaction(() async {
        // Clear old catalog data in strict FK safe order
        await _database.delete(_database.productItemVariantGroupOptions).go();
        await _database.delete(_database.inventoryItemVariantGroupOptions).go();
        await _database.delete(_database.productModifierGroups).go();
        await _database.delete(_database.modifierOptions).go();
        await _database.delete(_database.modifierGroups).go();
        await _database.delete(_database.variantGroupOptions).go();
        await _database.delete(_database.variantGroups).go();
        await _database.delete(_database.productPrices).go();
        await _database.delete(_database.inventories).go();
        await _database.delete(_database.productItems).go(); // Delete items before products
        await _database.delete(_database.products).go();
        await _database.delete(_database.productCategories).go();
        await _database.delete(_database.paymentMethods).go();
        await _database.delete(_database.promos).go();
        await _database.delete(_database.customers).go();

        // 1. Insert Products
        for (final item in products) {
          final productId = item['id'];
          final isShow = item['is_show'] == 1 || item['is_show'] == true || item['is_show'] == null;
          final isAvailableAtOutlet = outletProductAvailability.containsKey(productId)
              ? outletProductAvailability[productId]!
              : true;
          final isAvailable = isShow && isAvailableAtOutlet;

          await _database.into(_database.products).insert(
            ProductsCompanion.insert(
              id: productId,
              name: item['name'],
              categoryId: Value(item['product_category_id'] ?? item['category_id']),
              sku: Value(item['sku']),
              barcode: Value(item['barcode']),
              price: Value((item['price'] != null ? double.tryParse(item['price'].toString()) : null) ?? priceMap[productId] ?? 0.0),
              isAvailable: Value(isAvailable),
              productType: Value(item['product_type']?.toString() ?? 'basic'),
              unit: Value(item['unit']?.toString() ?? item['uom']?.toString() ?? 'Pcs'),
              hasVariants: Value(item['has_variant'] == 1 || item['has_variant'] == true),
              hasModifiers: Value(item['has_modifier'] == 1 || item['has_modifier'] == true),
              hasRecipe: Value(item['has_recipe'] == 1 || item['has_recipe'] == true),
              trackInventory: Value(item['track_inventory'] == 1 || item['track_inventory'] == true),
            ),
          );
        }

        // 2. Insert Product Items
        for (final item in productItems) {
          final itemId = item['id'];
          final isTrack = item['track_inventory'] == 1 || item['track_inventory'] == true;
          final isShow = item['is_show'] == 1 || item['is_show'] == true || item['is_show'] == null;
          final sellable = item['sellable'] == 1 || item['sellable'] == true || item['sellable'] == null;
          final isActive = item['is_active'] == 1 || item['is_active'] == true || item['is_active'] == null;

          await _database.into(_database.productItems).insert(
            ProductItemsCompanion.insert(
              id: itemId,
              productId: item['product_id'],
              name: item['name'] ?? '',
              variantCombination: Value(item['variant_combination']),
              sku: Value(item['sku']),
              barcode: Value(item['barcode']),
              trackInventory: Value(isTrack),
              isActive: Value(isActive && isShow && sellable),
              sellable: Value(sellable),
              unit: Value(item['unit']?.toString() ?? item['uom']?.toString() ?? 'Pcs'),
            ),
          );
        }

        // 3. Insert Variant Groups & Options
        for (final item in variantGroups) { ... }
        for (final item in variantGroupOptions) { ... }

        // 4. Insert Product Item Variant Group Options
        for (final item in productItemVariantGroupOptions) {
          final pItemId = item['product_item_id'];
          final vOptId = item['variant_group_option_id'];
          if (pItemId != null && vOptId != null) {
            await _database.into(_database.productItemVariantGroupOptions).insert(
              ProductItemVariantGroupOptionsCompanion.insert(
                productItemId: pItemId.toString(),
                variantGroupOptionId: vOptId.toString(),
              ),
              mode: InsertMode.insertOrReplace,
            );
          }
        }

        // 5. Insert Inventories (with productItemId)
        for (final item in inventoryItems) {
          final itemId = item['id'];
          await _database.into(_database.inventories).insert(
            InventoriesCompanion.insert(
              id: itemId,
              productId: Value(item['product_id']),
              productItemId: Value(item['product_item_id']),
              name: item['name'],
              sku: Value(item['sku']),
              barcode: Value(item['barcode']),
              trackInventory: Value(item['track_inventory'] == 1 || item['track_inventory'] == true),
              isActive: Value(item['is_active'] == 1 || item['is_active'] == true || item['is_active'] == null),
              stock: Value(stockByItemId[itemId] ?? 0.0),
              unit: Value(item['unit']?.toString() ?? item['uom']?.toString() ?? 'Pcs'),
            ),
          );
        }

        // 6. Insert Product Prices (with productItemId)
        for (final item in productPrices) {
          final rawAmount = item['amount'] ?? item['price'];
          final amountVal = double.tryParse(rawAmount?.toString() ?? '0') ?? 0.0;
          await _database.into(_database.productPrices).insert(
            ProductPricesCompanion.insert(
              id: item['id'],
              productId: item['product_id'],
              productItemId: Value(item['product_item_id']),
              inventoryItemId: Value(item['inventory_item_id']),
              amount: Value(amountVal),
            ),
          );
        }
```

#### In `lib/features/pos/data/sync/delta_sync_service.dart`
```dart
        // 1. Handle Deleted Product Items
        if (deletedProductItemIds.isNotEmpty) {
          final stringItemIds = deletedProductItemIds.map((e) => e.toString()).toList();
          await (_database.delete(_database.productItemVariantGroupOptions)
                ..where((t) => t.productItemId.isIn(stringItemIds)))
              .go();
          await (_database.delete(_database.productPrices)
                ..where((t) => t.productItemId.isIn(stringItemIds) | t.inventoryItemId.isIn(stringItemIds)))
              .go();
          await (_database.delete(_database.inventories)
                ..where((t) => t.productItemId.isIn(stringItemIds) | t.id.isIn(stringItemIds)))
              .go();
          await (_database.delete(_database.productItems)
                ..where((t) => t.id.isIn(stringItemIds)))
              .go();
        }

        // 2. Handle Deleted Products
        if (deletedProductIds.isNotEmpty) {
          final stringProductIds = deletedProductIds.map((e) => e.toString()).toList();
          await (_database.delete(_database.productPrices)
                ..where((t) => t.productId.isIn(stringProductIds)))
              .go();
          await (_database.delete(_database.inventories)
                ..where((t) => t.productId.isIn(stringProductIds)))
              .go();
          await (_database.delete(_database.productItems)
                ..where((t) => t.productId.isIn(stringProductIds)))
              .go();
          await (_database.delete(_database.products)
                ..where((t) => t.id.isIn(stringProductIds)))
              .go();
        }

        // 3. Upsert Updated Products
        for (final item in updatedProducts) {
          ...
          await _database.into(_database.products).insertOnConflictUpdate(
            ProductsCompanion(
              id: Value(productId),
              name: Value(item['name']?.toString() ?? ''),
              categoryId: Value(item['product_category_id']?.toString() ?? item['category_id']?.toString()),
              sku: Value(item['sku']?.toString()),
              barcode: Value(item['barcode']?.toString()),
              price: Value(priceVal),
              isAvailable: Value(isShow),
              productType: Value(item['product_type']?.toString() ?? 'basic'),
              unit: Value(item['unit']?.toString() ?? item['uom']?.toString() ?? 'Pcs'),
              hasVariants: Value(item['has_variant'] == 1 || item['has_variant'] == true),
              hasModifiers: Value(item['has_modifier'] == 1 || item['has_modifier'] == true),
              hasRecipe: Value(item['has_recipe'] == 1 || item['has_recipe'] == true),
              trackInventory: Value(item['track_inventory'] == 1 || item['track_inventory'] == true),
            ),
          );
        }

        // 4. Upsert Updated Product Items
        for (final item in updatedProductItems) {
          final itemId = item['id']?.toString() ?? '';
          final prodId = item['product_id']?.toString() ?? '';
          if (itemId.isEmpty || prodId.isEmpty) continue;

          final isTrack = item['track_inventory'] == 1 || item['track_inventory'] == true;
          final isShow = item['is_show'] == 1 || item['is_show'] == true || item['is_show'] == null;
          final sellable = item['sellable'] == 1 || item['sellable'] == true || item['sellable'] == null;
          final isActive = item['is_active'] == 1 || item['is_active'] == true || item['is_active'] == null;

          await _database.into(_database.productItems).insertOnConflictUpdate(
            ProductItemsCompanion(
              id: Value(itemId),
              productId: Value(prodId),
              name: Value(item['name']?.toString() ?? ''),
              variantCombination: Value(item['variant_combination']?.toString()),
              sku: Value(item['sku']?.toString()),
              barcode: Value(item['barcode']?.toString()),
              trackInventory: Value(isTrack),
              isActive: Value(isActive && isShow && sellable),
              sellable: Value(sellable),
              unit: Value(item['unit']?.toString() ?? item['uom']?.toString() ?? 'Pcs'),
            ),
          );

          if (item['inventory_item'] != null) {
            final inv = item['inventory_item'];
            final invId = inv['id']?.toString() ?? '';
            if (invId.isNotEmpty) {
              await _database.into(_database.inventories).insertOnConflictUpdate(
                InventoriesCompanion(
                  id: Value(invId),
                  productId: Value(prodId),
                  productItemId: Value(itemId),
                  name: Value(item['name']?.toString() ?? ''),
                  sku: Value(item['sku']?.toString()),
                  barcode: Value(item['barcode']?.toString()),
                  trackInventory: Value(isTrack),
                  isActive: Value(isActive),
                  unit: Value(item['unit']?.toString() ?? 'Pcs'),
                ),
              );
            }
          }
        }
```

---

### 4.3 PosRepository & Query Design (`pos_repository.dart`)

#### Clean Unified Query for `watchVariantModeItems`:
```dart
  Stream<List<PosItem>> watchVariantModeItems() {
    return _database
        .customSelect(
          '''
      SELECT 
        pi.id as id,
        pi.product_id as product_id,
        pi.name as name,
        pi.variant_combination as variant_combination,
        pi.sku as sku,
        pi.barcode as barcode,
        pi.track_inventory as track_inventory,
        pi.is_active as item_is_active,
        pi.sellable as item_sellable,
        COALESCE(i.stock, 0.0) as stock,
        COALESCE(pi.unit, p.unit, 'Pcs') as unit,
        p.category_id as category_id,
        COALESCE(p.product_type, 'basic') as product_type,
        p.is_available as product_is_available,
        p.has_variants as product_has_variants,
        p.has_modifiers as product_has_modifiers,
        (SELECT COUNT(id) FROM variant_groups WHERE product_id = p.id) as variant_count,
        (SELECT COUNT(modifier_group_id) FROM product_modifier_groups WHERE product_id = p.id) as modifier_count,
        COALESCE(
          (SELECT amount FROM product_prices WHERE product_item_id = pi.id LIMIT 1),
          (SELECT amount FROM product_prices WHERE inventory_item_id = i.id LIMIT 1),
          (SELECT amount FROM product_prices WHERE product_id = p.id AND product_item_id IS NULL AND inventory_item_id IS NULL LIMIT 1),
          (SELECT amount FROM product_prices WHERE product_id = p.id LIMIT 1),
          p.price,
          0.0
        ) as item_price,
        i.id as inventory_id
      FROM product_items pi
      INNER JOIN products p ON pi.product_id = p.id
      LEFT JOIN inventories i ON i.product_item_id = pi.id OR (i.product_id = p.id AND pi.variant_combination IS NULL)
      WHERE p.is_available = 1 AND pi.is_active = 1 AND pi.sellable = 1
      ORDER BY pi.name COLLATE NOCASE ASC
      ''',
          readsFrom: {
            _database.productItems,
            _database.products,
            _database.inventories,
            _database.variantGroups,
            _database.productModifierGroups,
            _database.productPrices,
          },
        )
        .watch()
        .map((rows) {
          return rows.map((row) {
            final id = row.read<String>('id');
            final productId = row.read<String>('product_id');
            final name = row.read<String>('name');
            final variantCombination = row.read<String?>('variant_combination');
            final sku = row.read<String?>('sku');
            final barcode = row.read<String?>('barcode');
            final trackInventory = row.read<bool>('track_inventory');
            final isItemActive = row.read<bool>('item_is_active');
            final isProductAvailable = row.read<bool>('product_is_available');
            final stock = row.read<double>('stock');
            final unit = row.read<String>('unit');
            final categoryId = row.read<String?>('category_id');
            final productType = row.read<String>('product_type');
            final variantCount = row.read<int>('variant_count');
            final modifierCount = row.read<int>('modifier_count');
            final itemPrice = row.read<double>('item_price');
            final inventoryId = row.read<String?>('inventory_id');

            return PosItem(
              id: id,
              name: name,
              categoryId: categoryId,
              price: itemPrice,
              stock: stock,
              unit: unit,
              productType: productType,
              isActive: isItemActive && isProductAvailable,
              hasVariants: variantCount > 0,
              hasModifiers: modifierCount > 0,
              isProductMode: false,
              productItemId: id,
              variantCombination: variantCombination,
              sku: sku,
              barcode: barcode,
              trackInventory: trackInventory,
              inventory: inventoryId != null
                  ? Inventory(
                      id: inventoryId,
                      productId: productId,
                      productItemId: id,
                      name: name,
                      sku: sku,
                      barcode: barcode,
                      trackInventory: trackInventory,
                      isActive: isItemActive,
                      stock: stock,
                      unit: unit,
                    )
                  : null,
              product: Product(
                id: productId,
                name: name,
                categoryId: categoryId,
                sku: sku,
                barcode: barcode,
                price: itemPrice,
                isAvailable: isProductAvailable,
                productType: productType,
                unit: unit,
                hasVariants: variantCount > 0,
                hasModifiers: modifierCount > 0,
                trackInventory: trackInventory,
              ),
            );
          }).toList();
        });
  }
```

#### Instant Multi-Key Omni-Search (`findItemByBarcodeOrSku`):
```dart
  Future<PosItem?> findItemByBarcodeOrSku(String query) async {
    final rows = await _database
        .customSelect(
          '''
      SELECT 
        pi.id as id,
        pi.product_id as product_id,
        pi.name as name,
        pi.variant_combination as variant_combination,
        pi.sku as sku,
        pi.barcode as barcode,
        pi.track_inventory as track_inventory,
        pi.is_active as item_is_active,
        pi.sellable as item_sellable,
        COALESCE(i.stock, 0.0) as stock,
        COALESCE(pi.unit, p.unit, 'Pcs') as unit,
        p.category_id as category_id,
        COALESCE(p.product_type, 'basic') as product_type,
        p.is_available as product_is_available,
        (SELECT COUNT(id) FROM variant_groups WHERE product_id = p.id) as variant_count,
        (SELECT COUNT(modifier_group_id) FROM product_modifier_groups WHERE product_id = p.id) as modifier_count,
        COALESCE(
          (SELECT amount FROM product_prices WHERE product_item_id = pi.id LIMIT 1),
          (SELECT amount FROM product_prices WHERE inventory_item_id = i.id LIMIT 1),
          (SELECT amount FROM product_prices WHERE product_id = p.id AND product_item_id IS NULL AND inventory_item_id IS NULL LIMIT 1),
          (SELECT amount FROM product_prices WHERE product_id = p.id LIMIT 1),
          p.price,
          0.0
        ) as item_price,
        i.id as inventory_id
      FROM product_items pi
      INNER JOIN products p ON pi.product_id = p.id
      LEFT JOIN inventories i ON i.product_item_id = pi.id OR (i.product_id = p.id AND pi.variant_combination IS NULL)
      WHERE (
        pi.barcode = ? OR 
        pi.sku = ? OR 
        p.barcode = ? OR 
        p.sku = ?
      ) AND pi.is_active = 1 AND pi.sellable = 1 AND p.is_available = 1
      LIMIT 1
      ''',
          variables: [
            Variable.withString(query),
            Variable.withString(query),
            Variable.withString(query),
            Variable.withString(query),
          ],
        )
        .get();

    if (rows.isNotEmpty) {
      final row = rows.first;
      // map to PosItem exactly as above
      return ...;
    }
    return null;
  }
```

#### Multi-Attribute Variant Matcher (`findProductItemForVariants`):
```dart
  Future<String?> findProductItemIdForVariants(
    String productId,
    List<String> variantGroupOptionIds,
  ) async {
    if (variantGroupOptionIds.isEmpty) return null;

    final inClause = List.filled(variantGroupOptionIds.length, '?').join(',');
    final query = '''
      SELECT piv.product_item_id
      FROM product_item_variant_group_options piv
      INNER JOIN product_items pi ON pi.id = piv.product_item_id
      WHERE pi.product_id = ? AND piv.variant_group_option_id IN ($inClause)
      GROUP BY piv.product_item_id
      HAVING COUNT(DISTINCT piv.variant_group_option_id) = ?
      LIMIT 1
    ''';

    final variables = <Variable>[
      Variable.withString(productId),
      ...variantGroupOptionIds.map((id) => Variable.withString(id)),
      Variable.withInt(variantGroupOptionIds.length),
    ];

    final row = await _database.customSelect(query, variables: variables).getSingleOrNull();
    return row?.read<String>('product_item_id');
  }
```

#### Aggregative Category Filter (`watchItemsByCategory`):
```dart
  Stream<List<PosItem>> watchItemsByCategory({String? categoryId}) {
    if (categoryId == null) {
      return watchVariantModeItems();
    }

    return _database
        .customSelect(
          '''
      SELECT 
        pi.id as id,
        ...
      FROM product_items pi
      INNER JOIN products p ON pi.product_id = p.id
      LEFT JOIN inventories i ON i.product_item_id = pi.id OR (i.product_id = p.id AND pi.variant_combination IS NULL)
      WHERE p.category_id IN (
        SELECT id FROM product_categories WHERE id = ? OR parent_id = ?
      ) AND p.is_available = 1 AND pi.is_active = 1 AND pi.sellable = 1
      ORDER BY pi.name COLLATE NOCASE ASC
      ''',
          variables: [
            Variable.withString(categoryId),
            Variable.withString(categoryId),
          ],
          readsFrom: {
            _database.productItems,
            _database.products,
            _database.inventories,
            _database.productCategories,
            _database.productPrices,
          },
        )
        .watch()
        .map(...);
  }
```

---

### 4.4 Milestone R5 Dependencies Preview & Binding

1. **`VariantDialogNotifier`:**
   - Instead of checking `inventory_item_variant_group_options`, query `product_item_variant_group_options`.
   - Pass all selected option IDs to `findProductItemIdForVariants(productId, state.selectedVariants.values.toList())`.
   - Read the resolved price from `product_prices` where `product_item_id = resolvedId`.
   - Resolve stock and trackInventory directly from `ProductItems` and `Inventories`.

2. **`CartItem` & `CartProvider`:**
   - Update `CartItem`:
     ```dart
     class CartItem {
       final String id;
       final String productId;
       final String? productItemId; // NEW
       final String inventoryItemId;
       final String? variantGroupOptionId;
       final String name;
       final double price;
       final int qty;
       final String? discountType;
       final double? discountValue;
       final String? notes;
       final bool trackInventory; // NEW
       final Map<String, String> selectedVariants;
       final Map<String, List<String>> selectedModifiers;
     ...
     ```
   - In `addItem`:
     Compare `productItemId == item.productItemId` in addition to modifiers and variants.

3. **Decoupled Stock Behavior (`track_inventory = false`):**
   - In `checkCartStockAvailability`:
     ```dart
     for (final item in items) {
       if (item.trackInventory == false) {
         continue; // Infinite stock: never block checkout
       }
       ...
     }
     ```
   - In UI: When `trackInventory == false`, display `∞` instead of `0`.

---

## 5. Verification Method

To verify the implementation once executed by Worker R4:

1. **Code Generation:**
   ```bash
   /Users/whykrr/flutter/bin/flutter pub run build_runner build --delete-conflicting-outputs
   ```
   *Expected Result:* Clean completion without conflict in `app_database.g.dart`.

2. **Linter:**
   ```bash
   /Users/whykrr/flutter/bin/flutter analyze
   ```
   *Expected Result:* Zero errors / no new issues introduced.

3. **PosRepository & Sync Automated Tests:**
   Create and run `test/features/pos/data/pos_repository_unified_items_test.dart`:
   ```bash
   /Users/whykrr/flutter/bin/flutter test test/features/pos/data/pos_repository_unified_items_test.dart
   ```
   *Test Cases:*
   - `watchVariantModeItems` returns both single items (1 default `ProductItem`) and multi-variant items from `ProductItems`.
   - `findItemByBarcodeOrSku` matches by item barcode, item SKU, product barcode, and product SKU.
   - `watchItemsByCategory` returns parent category items and all sub-category items when parent category is selected.
   - Initial & Delta Sync correctly populate `product_items` and `product_item_variant_group_options`.

4. **All POS Tests:**
   ```bash
   /Users/whykrr/flutter/bin/flutter test
   ```
   *Expected Result:* All 38+ tests pass.
