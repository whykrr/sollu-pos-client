# Handoff Report: Empirical Challenge Milestone R4 (Drift Migration & Sync Pipeline)

**Working Directory:** `/Users/whykrr/Documents/Projects/Flutter/sollu-pos-client/.agents/teamwork/challenger_r4_2`  
**Agent:** Empirical Challenger 2 (`challenger_r4_2`)  
**Verdict:** ❌ **REQUEST_CHANGES**  
**Date:** 2026-10-22  

---

## 1. Observation

1. **Targeted Test Execution:**
   - Ran command:
     ```bash
     /Users/whykrr/flutter/bin/flutter test test/features/pos/data/sync_pipeline_product_items_test.dart
     ```
   - Result:
     ```text
     00:04 +2: All tests passed!
     ```
     `sync_pipeline_product_items_test.dart` passes (2 passed tests).

2. **Full Test Suite Execution (Regression Failure Detected):**
   - Ran command:
     ```bash
     /Users/whykrr/flutter/bin/flutter test
     ```
   - Result:
     ```text
     00:08 +47 -1: /Users/whykrr/Documents/Projects/Flutter/sollu-pos-client/test/features/pos/data/sync_pipeline_and_migration_stress_test.dart: Stress & Edge Case Harness: Delta Sync Upsert and Cascade Delta sync handles deleted_product_ids cascade cleanly [E]
       Expected: empty
         Actual: [
                   ProductItemVariantGroupOption:ProductItemVariantGroupOption(productItemId: item-del-1, variantGroupOptionId: vgo-del-1)
                 ]
       package:matcher expect
       test/features/pos/data/sync_pipeline_and_migration_stress_test.dart 581:7
     ...
     00:10 +76 -1: Some tests failed.
     Command exited with code 1.
     ```

3. **Empirical Reproduction Harness (`challenger_r4_2_stress_test.dart`):**
   - Created and executed empirical test file `test/features/pos/data/challenger_r4_2_stress_test.dart`:
     ```bash
     /Users/whykrr/flutter/bin/flutter test test/features/pos/data/challenger_r4_2_stress_test.dart
     ```
   - Result:
     ```text
     00:04 +0 -1: Challenger Empirical Tests: Sync Pipeline & PosRepository Empirical Test 1: DeltaSync deleted_product_ids must cascade delete product_item_variant_group_options [E]
       Expected: empty
         Actual: [
                   ProductItemVariantGroupOption:ProductItemVariantGroupOption(productItemId: item-test-1, variantGroupOptionId: vgo-test-1)
                 ]
       product_item_variant_group_options pivot rows must be cascade deleted when a product is deleted
       test/features/pos/data/challenger_r4_2_stress_test.dart 130:7

     00:04 +0 -2: Challenger Empirical Tests: Sync Pipeline & PosRepository Empirical Test 2: findProductItemIdForVariants partial selection must NOT false-positive match multi-variant item [E]
       Expected: null
         Actual: 'item-combo-large-ice'
       findProductItemIdForVariants should return null when only a subset of options is provided, but item requires all options
       test/features/pos/data/challenger_r4_2_stress_test.dart 174:7

     00:04 +1 -2: Some tests failed.
     ```

4. **Code Inspection of Failure 1 (`delta_sync_service.dart`):**
   - In `lib/features/pos/data/sync/delta_sync_service.dart`, lines 94–109:
     ```dart
     // 2. Tangani Soft-Deleted / Disabled Products
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
     ```
   - Verbatim observation: `deletedProductIds` deletes `productItems` belonging to those products, but NEVER deletes from `productItemVariantGroupOptions`. Because `product_item_variant_group_options` only references `product_item_id` and does not have SQLite native foreign key cascade enabled, pivot entries are permanently orphaned.

5. **Code Inspection of Failure 2 (`pos_repository.dart`):**
   - In `lib/features/pos/data/pos_repository.dart`, lines 604–612:
     ```dart
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
     ```
   - Verbatim observation: The HAVING condition checks `HAVING COUNT(DISTINCT piv.variant_group_option_id) = ?` against `variantGroupOptionIds.length`. When a product has items with 2 options (e.g., Size=Large, Temp=Ice) and the caller only passes 1 option (Size=Large), the grouped row for that item contains 1 distinct option from the IN filter, which equals `1`. The query therefore returns a false-positive match (`item-combo-large-ice`) for a partial variant selection.

---

## 2. Logic Chain

1. **Premise 1 (Database Consistency):** When a product is removed during delta sync via `deleted_product_ids`, all associated downstream entities (`product_items`, `inventories`, `product_prices`, and pivot links `product_item_variant_group_options`) must be cleaned up to avoid orphan records and stale joins.
2. **Step 1 -> Observation 2 & 4:** In `DeltaSyncService.syncDeltaCatalog`, `deleted_product_item_ids` explicitly removes pivot rows (`await (_database.delete(_database.productItemVariantGroupOptions)..where((t) => t.productItemId.isIn(stringItemIds))).go();`). However, `deleted_product_ids` does not resolve the product's item IDs and does not delete from `productItemVariantGroupOptions`. Consequently, any product deleted via delta sync leaves orphaned rows in `product_item_variant_group_options`. This causes `sync_pipeline_and_migration_stress_test.dart` and `challenger_r4_2_stress_test.dart` to fail.
3. **Premise 2 (Variant Resolution Exactness):** In POS checkout, selecting a subset of variant groups must never resolve to an item that requires additional unselected variant options.
4. **Step 2 -> Observation 3 & 5:** `findProductItemIdForVariants` only checks that the count of matching options in the provided list equals the list's length. It lacks a check ensuring that the total option count of the matched `product_item_id` also equals the list's length. When a 2-option item exists and only 1 option is searched, the item passes the `HAVING COUNT = 1` filter and is returned.
5. **Step 3 -> Acceptance Criteria:** Acceptance criterion: "Automated widget/unit tests on PosRepository and VariantDialogNotifier berhasil dijalankan (`flutter test`)", and full regression suite must pass with 0 failures. Because `flutter test` currently exits with code 1 (`76 passed, 1 failed`), changes must be requested before Milestone R4 can be approved.

---

## 3. Caveats

1. The Drift SQLite v10 schema definition and migration (`onUpgrade` from version 9 to 10) themselves are properly defined and pass unit verification.
2. The `watchVariantModeItems` query and multi-key omni-search in `findItemByBarcodeOrSku` pass all 20 empirical stress tests in `pos_repository_empirical_challenge_test.dart`.
3. The remaining failures are confined strictly to:
   - `DeltaSyncService.syncDeltaCatalog` (handling `deleted_product_ids` cascade).
   - `PosRepository.findProductItemIdForVariants` (cardinality constraint for exact variant combination matching).

---

## 4. Conclusion

**Verdict: REQUEST_CHANGES**

Worker R4 needs to fix two specific defects:

1. **Fix `DeltaSyncService` Deletion Cascade:**
   In `lib/features/pos/data/sync/delta_sync_service.dart`, when processing `deletedProductIds`, retrieve the product item IDs belonging to those products and delete from `productItemVariantGroupOptions` before deleting `productItems`:
   ```dart
   final itemIdsForProducts = await (_database.selectOnly(_database.productItems)
         ..addColumns([_database.productItems.id])
         ..where(_database.productItems.productId.isIn(stringProductIds)))
       .map((row) => row.read(_database.productItems.id)!)
       .get();
   if (itemIdsForProducts.isNotEmpty) {
     await (_database.delete(_database.productItemVariantGroupOptions)
           ..where((t) => t.productItemId.isIn(itemIdsForProducts)))
         .go();
   }
   ```

2. **Fix `PosRepository.findProductItemIdForVariants` Cardinality Matching:**
   In `lib/features/pos/data/pos_repository.dart`, update the query in `findProductItemIdForVariants` to ensure the item has exactly the same number of options in total:
   ```sql
   SELECT piv.product_item_id
   FROM product_item_variant_group_options piv
   INNER JOIN product_items pi ON pi.id = piv.product_item_id
   WHERE pi.product_id = ? AND piv.variant_group_option_id IN ($inClause)
   GROUP BY piv.product_item_id
   HAVING COUNT(DISTINCT piv.variant_group_option_id) = ?
     AND (SELECT COUNT(*) FROM product_item_variant_group_options WHERE product_item_id = piv.product_item_id) = ?
   LIMIT 1
   ```
   (and pass `Variable.withInt(variantGroupOptionIds.length)` to both count placeholders).

---

## 5. Verification Method

1. **Run full project test suite:**
   ```bash
   /Users/whykrr/flutter/bin/flutter test
   ```
   *Expected once fixed:* All tests pass with exit code 0.

2. **Run targeted empirical stress tests:**
   ```bash
   /Users/whykrr/flutter/bin/flutter test test/features/pos/data/sync_pipeline_and_migration_stress_test.dart
   /Users/whykrr/flutter/bin/flutter test test/features/pos/data/challenger_r4_2_stress_test.dart
   ```
   *Expected once fixed:* All tests in both files pass with 0 failures.
