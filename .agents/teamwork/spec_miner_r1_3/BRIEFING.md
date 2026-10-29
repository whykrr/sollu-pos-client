# BRIEFING — 2026-10-22T09:37:30Z

## Mission
Extract exact specification, constraints, database schemas, enum tier gating, and compliance rules for Milestone R1 of the Product & Recipe Architecture revamp.

## 🔒 My Identity
- Archetype: Specification Miner
- Roles: Specification Mining, Compliance Analysis, Schema & Gating Validation
- Working directory: /Users/whykrr/Documents/Projects/Flutter/sollu-pos-client/.agents/teamwork/spec_miner_r1_3/
- Original parent: 62e974db-fa87-4f68-ab0a-9c5953d6dc72
- Milestone: Milestone R1 (Specification & Compliance Miner)

## 🔒 Key Constraints
- Read-only miner: Do NOT implement anything.
- Do NOT skip any feature, no matter how obscure.
- Enforce bidirectional migrations with absolute rollback symmetry (`php artisan migrate:rollback --step=1 && php artisan migrate`).
- Enforce UUID foreign key conventions, cascading rules, and PostgreSQL GIN index tsvector syntax.
- Enforce Spatie/FeatureEnum tier plan assignments per the 6-layer gating stack.
- Comply with all sollu-app architectural standards (Pint, PHP 8.3, strict types).

## Current Parent
- Conversation ID: 62e974db-fa87-4f68-ab0a-9c5953d6dc72
- Updated: 2026-10-22T09:37:30Z

## Task Summary
- **What to build**: Full specification report (`handoff.md`) covering Milestone R1 database schema details (`product_item_variant_group_options`, `recipe_versions.product_item_id`, `product_items` indexes), FeatureEnum values and tier plan assignments, migration standards, and edge cases/invariants.
- **Success criteria**: Exhaustive, accurate specification report containing all exact definitions, SQL/Laravel schema definitions, enum values, plan mappings, migration rollback patterns, and edge case matrix.
- **Interface contracts**: `/Users/whykrr/Documents/Projects/Flutter/sollu-pos-client/.agents/teamwork/orchestrator_1/PROJECT.md`
- **Code layout**: Laravel Backend (`/Users/whykrr/Documents/Projects/Laravel/sollu-app`)

## Loaded Skills
- **Source**: `/Users/whykrr/Documents/Projects/Laravel/sollu-app/.agents/skills/domain-access-and-feature-gating/SKILL.md`
  - **Local copy**: `skills/domain-access-and-feature-gating.md`
  - **Core methodology**: 6-layer gating stack (Tenant Lifecycle, BusinessType, SaaS Plan, Personalization, Outlet Guards, RBAC), fast-path cache.
- **Source**: `/Users/whykrr/Documents/Projects/Laravel/sollu-app/.agents/skills/sollu/SKILL.md`
  - **Local copy**: `skills/sollu.md`
  - **Core methodology**: Comprehensive Laravel 12 / Vue 3 / Inertia / Clean Architecture standards.

## Key Decisions Made
- PostgreSQL GIN tsvector expression index must be guarded with `if (DB::getDriverName() !== 'sqlite')` in both `up()` and `down()` to preserve SQLite compatibility for automated tests.
- Composite PK on `product_item_variant_group_options` must specify a custom short constraint name (`piv_prod_item_vgo_primary`) to prevent PostgreSQL 63-byte truncation.
- FeatureEnum values mapped: `product_catalog` (Micro), `product_variants` (Basic), `recipe_management` (Pro), `product_modifiers` (Pro).

## Artifact Index
- `handoff.md` — Final 5-component handoff specification report for orchestrator and implementers.
