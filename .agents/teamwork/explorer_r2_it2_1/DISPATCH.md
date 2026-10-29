## 2026-10-22T11:57:04Z
You are explorer_r2_it2_1 for Milestone R2 Iteration 2 (Challenger 1 Defects Investigation).
Your working directory is:
/Users/whykrr/Documents/Projects/Flutter/sollu-pos-client/.agents/teamwork/explorer_r2_it2_1/

Target workspace: /Users/whykrr/Documents/Projects/Laravel/sollu-app

Read:
- ORIGINAL_REQUEST.md: /Users/whykrr/Documents/Projects/Flutter/sollu-pos-client/.agents/teamwork/ORIGINAL_REQUEST.md
- Challenger 1 Handoff Report: /Users/whykrr/Documents/Projects/Flutter/sollu-pos-client/.agents/teamwork/challenger_r2_1/handoff.md
- Worker R2 Handoff Report: /Users/whykrr/Documents/Projects/Flutter/sollu-pos-client/.agents/teamwork/worker_r2/handoff.md
- Target File: app/Services/App/Master/ProductService.php

Investigation Tasks:
1. Examine Defect A (Zombie Active Inventory Items on Product Deletion):
   - In `ProductService::deleteProduct` lines 809–822, `$product->productItems()->delete()` soft-deletes child `ProductItem`s first, causing the subsequent `$product->inventoryItems()->update(['is_active' => false])` (a `HasManyThrough` relationship) to find 0 rows due to soft delete scope `WHERE product_items.deleted_at IS NULL`.
   - Formulate the exact fix: fetch child item IDs first and update `InventoryItem::whereIn('product_item_id', $productItemIds)->update(['is_active' => false])` BEFORE or during soft delete.
2. Examine Defect B (Parent-to-Child Causality Invariant Leak on Variant Product Update):
   - In `ProductService::updateProduct`, when parent product is updated with `sellable = false` or `is_show = false`, existing child `ProductItem`s are not updated if `$data['variants']` is omitted or does not alter child rows.
   - Formulate the exact fix in `ProductService::updateProduct`:
     `if (! $sellable) { $product->productItems()->update(['sellable' => false, 'is_show' => false]); } elseif (! $isShow) { $product->productItems()->update(['is_show' => false]); }`.
3. Write your findings and fix blueprint to:
   `/Users/whykrr/Documents/Projects/Flutter/sollu-pos-client/.agents/teamwork/explorer_r2_it2_1/handoff.md`
   Then notify caller (62e974db-fa87-4f68-ab0a-9c5953d6dc72) via send_message.
