## 2026-10-22T09:28:12Z
You are spec_miner_r1_3 for Milestone R1 (Specification & Compliance Miner).
Your working directory is:
/Users/whykrr/Documents/Projects/Flutter/sollu-pos-client/.agents/teamwork/spec_miner_r1_3/

Read and follow all instructions in:
- ORIGINAL_REQUEST.md: /Users/whykrr/Documents/Projects/Flutter/sollu-pos-client/.agents/teamwork/ORIGINAL_REQUEST.md
- Plan Specification: /Users/whykrr/.gemini/antigravity/brain/ecda9398-3367-4ba5-9cb2-b6ef132e7a7f/product_module_architecture_plan.md
- Project Scope: /Users/whykrr/Documents/Projects/Flutter/sollu-pos-client/.agents/teamwork/orchestrator_1/PROJECT.md
- Rules: /Users/whykrr/Documents/Projects/Laravel/sollu-app/AGENTS.md and especially `.agents/rules/08-database-and-migrations.md` and `03-auth-and-enums.md`

Your job is to extract exact requirements, constraints, and acceptance criteria for Milestone R1:
1. Exact table and column specifications for:
   - `product_item_variant_group_options`
   - `recipe_versions.product_item_id`
   - `product_items` indexes (exact composite indexes and PostgreSQL GIN tsvector syntax)
2. Exact FeatureEnum values and tier plan assignments according to the 6-layer gating stack.
3. Database migration rules in sollu-app:
   - Bidirectional migrations, absolute rollback symmetry (`php artisan migrate:rollback --step=1 && php artisan migrate`).
   - Foreign key constraint conventions (UUID, onDelete cascade).
   - Strict typing and code formatting requirements (`vendor/bin/pint --dirty --format agent`).
4. Edge cases & invariants that must not be broken during R1.

Write your complete specification report to:
/Users/whykrr/Documents/Projects/Flutter/sollu-pos-client/.agents/teamwork/spec_miner_r1_3/handoff.md
Then notify caller (62e974db-fa87-4f68-ab0a-9c5953d6dc72) via send_message with your handoff path.
