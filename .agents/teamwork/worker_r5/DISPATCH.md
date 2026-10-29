## 2026-10-22T15:25:14Z
You are Worker R5 (worker_r5).
Your working directory is: /Users/whykrr/Documents/Projects/Flutter/sollu-pos-client/.agents/teamwork/worker_r5/
Target Workspace: /Users/whykrr/Documents/Projects/Flutter/sollu-pos-client

MANDATORY INTEGRITY WARNING:
DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A teamwork_preview_auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.

Read and follow:
- Authoritative User Request: /Users/whykrr/Documents/Projects/Flutter/sollu-pos-client/.agents/teamwork/ORIGINAL_REQUEST.md (§ R5)
- Explorer 1 Blueprint (Variant Dialog & Options): /Users/whykrr/Documents/Projects/Flutter/sollu-pos-client/.agents/teamwork/explorer_r5_1/handoff.md
- Explorer 2 Blueprint (Cart Domain & Transaction Persistence): /Users/whykrr/Documents/Projects/Flutter/sollu-pos-client/.agents/teamwork/explorer_r5_2/handoff.md
- Explorer 3 Blueprint (POS UI & Stock Visualization): /Users/whykrr/Documents/Projects/Flutter/sollu-pos-client/.agents/teamwork/explorer_r5_3/handoff.md
- Guidelines: /Users/whykrr/Documents/Projects/Flutter/sollu-pos-client/AGENTS.md

Scope of Work for Milestone R5 (Variant Dialog & Cart Integration):

1. Cart Domain Entity (`lib/features/cart/domain/cart_item.dart` & `cart_provider.dart`):
   - Create `lib/features/cart/domain/cart_item.dart` per Explorer 2 blueprint with:
     - `String id`
     - `String productId`
     - `String? productItemId` (Unified item ID)
     - `String inventoryItemId` (defaults to '' if null)
     - `String? variantGroupOptionId`
     - `String? variantCombination`
     - `bool trackInventory` (defaults to true)
     - `String name`, `double price`, `int qty`, `discountType`, `discountValue`, `notes`
     - `Map<String, String> selectedVariants`
     - `Map<String, List<String>> selectedModifiers`
     - `copyWith`, `toMap`, `fromMap`, `totalPrice`, etc.
   - Re-export `CartItem` in `lib/features/pos/presentation/providers/cart_provider.dart`.
   - Update `CartNotifier.addItem`: deduplicate by `productItemId` and matching modifier selections (order-insensitive set comparison).

2. Refactor `VariantDialogNotifier` & `VariantDialog` (`variant_dialog_provider.dart` & `variant_dialog.dart`):
   - Refactor `VariantDialogNotifier`:
     - Safe initialization without crashing if `inventory == null`.
     - In `_updateVariantPrice()`: call `PosRepository.findProductItemIdForVariants(productId, selectedOptionIds)` using the new `product_item_variant_group_options` table.
     - Look up resolved `ProductItem` price, SKU, barcode, and availability.
     - Calculate total price: base variant price + selected modifier prices.
     - Set `isCombinationAvailable` and warning messages for invalid combinations.
   - In `variant_dialog.dart`:
     - Display stock badge (showing `∞` when `trackInventory == false` or `stock == null`).
     - Disable "Tambah ke Keranjang" button when required modifier groups are missing or variant combination is invalid.
     - When adding to cart, create `CartItem` with `productItemId: state.selectedProductItemId`, `variantCombination: state.variantCombination`, `trackInventory: state.trackInventory`.

3. POS Catalog UI & Decoupled Stock Visualization:
   - In `lib/features/pos/presentation/widgets/product_grid.dart` (`_ProductCard`):
     - Display stock status badge on top-left:
       - If `!product.trackInventory` or `product.stock == null`: display `Stok: ∞` (`\u221E`).
       - If `product.trackInventory`: display `Stok: ${_formatStock(product.stock)}`.
   - In `lib/features/pos/presentation/pages/products_screen.dart`:
     - List View & Card View: when `!item.trackInventory` or `item.stock == null`, display `Stok: ∞` instead of `Stok: 0 Pcs`.

4. Barcode Scanning & Omni-Search Differentiation:
   - In `lib/features/pos/data/pos_repository.dart` (`findItemByBarcodeOrSku`):
     - Add aliases `p.name as product_name`, `p.barcode as product_barcode`, `p.sku as product_sku` to differentiate parent product barcode from specific variant barcode.
   - In `lib/features/pos/presentation/pages/pos_layout.dart` (`_handleBarcodeScanned` and search submit):
     - If the scanned query matches parent product barcode/SKU AND `matchedItem.hasVariants == true`:
       Pop up `VariantDialog.show(context, parentPosItem)`.
     - If the scan matches a specific variant barcode/SKU OR a single product:
       Add directly to cart with resolved `productItemId` and `trackInventory`.

5. Transaction Persistence (`lib/features/pos/data/transaction_repository.dart`):
   - In `TransactionRepository.createTransaction`:
     - Populate `productItemId: Value(item.productItemId)` when creating `TransactionItemsCompanion`.
     - When `item.trackInventory == false`, bypass local stock decrement.

6. Automated Tests & Code Quality:
   - Write comprehensive unit tests in:
     `test/features/pos/presentation/variant_dialog_test.dart`
     `test/features/cart/cart_provider_test.dart`
   - Run tests with BypassSandbox: true:
     ```bash
     /Users/whykrr/flutter/bin/flutter test
     ```
   - Run linter with BypassSandbox: true:
     ```bash
     /Users/whykrr/flutter/bin/flutter analyze
     ```
   - Ensure 100% of tests pass with 0 failures, and 0 linter errors.

7. Deliverables:
   - Write detailed handoff report to `/Users/whykrr/Documents/Projects/Flutter/sollu-pos-client/.agents/teamwork/worker_r5/handoff.md`.
   - Send completion message back via send_message.
