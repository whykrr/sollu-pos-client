# Original User Request

## 2026-10-22T09:24:05Z

Implementasi perombakan arsitektur Modul Produk terpadu pada backend Laravel 12 (`sollu-app`) dan Flutter POS client (`sollu-pos-client`) sesuai spesifikasi `product_module_architecture_plan.md` dan panduan ketat `AGENTS.md`. Mengimplementasikan Unified Item Pattern (Shopify/Square standard), pemisahan total modul inventaris, SaaS feature gating 4-tier (`basic_product`, `product_variant`, `product_bom`, `product_modifier`), integrasi hirarkis kategori 2-level, sub-menu bahan baku & template resep, serta multi-key omni-search pada kasir POS.

Working directory: 
- `/Users/whykrr/Documents/Projects/Laravel/sollu-app`
- `/Users/whykrr/Documents/Projects/Flutter/sollu-pos-client`

Integrity mode: development

Reference:
- Specification Plan: `/Users/whykrr/.gemini/antigravity/brain/ecda9398-3367-4ba5-9cb2-b6ef132e7a7f/product_module_architecture_plan.md`
- Guidelines Backend: `/Users/whykrr/Documents/Projects/Laravel/sollu-app/AGENTS.md`
- Guidelines Flutter POS: `/Users/whykrr/Documents/Projects/Flutter/sollu-pos-client/AGENTS.md`

## Requirements

### R1. Backend Database Foundation, Seeders & Data Normalization (`sollu-app`)
- Buat migrasi tabel pivot normalisasi `product_item_variant_group_options` (`product_item_id`, `variant_group_option_id`).
- Tambahkan kolom `product_item_id` pada tabel `recipe_versions` untuk mendukung BOM spesifik per varian.
- Tambahkan GIN Fulltext & composite search index pada `product_items` (`name`, `variant_combination`, `sku`, `barcode`).
- Daftarkan dan aktifkan feature flag `basic_product`, `product_variant`, `product_bom` (`recipe_management`), dan `product_modifier` (`product_modifiers`) pada `FeatureEnum` dan `SubscriptionPlanSeeder`.
- Tulis migration backfill untuk memastikan semua produk single yang ada memiliki 1 default baris `product_items` sehingga barcode dan SKU tidak hilang.
- Verifikasi simetri rollback: `php artisan migrate:rollback --step=1 && php artisan migrate`.

### R2. Backend Service Layer, Feature Gating & Sync API (`sollu-app`)
- Refactor `ProductService`:
  - Enforce aturan dependensi: `sellable = false` secara mutlak mengatur `is_show = false`.
  - Unified Item Pattern: Selalu buat minimal 1 `ProductItem`. Produk single memiliki default item; produk varian memiliki N item terhubung via pivot.
  - Total Decoupling: Hanya buat baris `inventory_items` dan saldo `inventory_balances` jika `track_inventory = true`.
- Implementasikan controller, request, dan service untuk:
  - `RawMaterialController` (`/master/raw-materials`) dengan `item_type = 'raw_material'`, `sellable = false`, `is_show = false`, `track_inventory = true`.
  - `RecipeTemplateController` (`/master/recipes`) untuk manajemen template resep dan versi BOM.
  - Aktifkan rute `ModifierGroupController` (`/master/modifiers`).
- Lindungi seluruh rute dengan middleware `plan.feature:...` (`product_variant`, `product_bom`, `product_modifier`).
- Update `MasterDataSyncService` untuk mengekspor `product_items` dan `product_item_variant_group_options` ke Flutter POS client.

### R3. Admin Web UI/UX Inertia Vue 3 (`sollu-app`)
- Update `CreateEdit.vue` pada Produk Barang:
  - Watcher dua arah pada `sellable`: mematikan `sellable` otomatis mematikan dan mendisabled switch `is_show`.
  - Tab 2 Seksi Varian dibungkus `<FeatureLock :feature="$enums.FeatureEnum.PRODUCT_VARIANTS">`.
  - Tab 4 Resep Bahan Baku (BOM) dibungkus `<FeatureLock :feature="$enums.FeatureEnum.RECIPE_MANAGEMENT">`.
  - Tab 5 Modifier dibungkus `<FeatureLock :feature="$enums.FeatureEnum.PRODUCT_MODIFIERS">`.
- Buat halaman antarmuka baru:
  - `Master/Product/RawMaterial/Index.vue` & drawer form bahan baku.
  - `Master/Product/Recipe/Index.vue` & drawer form template resep.
- Tambahkan sub-menu "Bahan Baku", "Template Resep", dan "Opsi Tambahan" pada navigasi sidebar di bawah kelompok Master Produk, dengan visualisasi `v-feature.lock`.
- Form Kategori (`CategoryForm.vue`) secara tegas membatasi kedalaman maksimal 2 tingkat (Root -> Child).

### R4. Flutter POS Local Database & Repository (`sollu-pos-client`)
- Tambahkan tabel Drift SQLite `ProductItems` dan `ProductItemVariantGroupOptions` di `master_data_tables.dart`.
- Jalankan build runner: `flutter pub run build_runner build --delete-conflicting-outputs`.
- Refactor `InitialSyncService` dan `DeltaSyncService` untuk menyerap payload `product_items` dan `product_item_variant_group_options`.
- Refactor `PosRepository`:
  - Gantikan query UNION lama dengan query bersih berbasis `ProductItems` left join `Inventories`.
  - Implementasikan Omni-Search instan mencocokkan `barcode`, `sku`, `name`, dan `variant_combination`.
  - Filter kategori agregatif: memilih kategori induk otomatis memunculkan produk induk dan seluruh sub-kategorinya.

### R5. Flutter POS Variant Dialog & Cart Integration (`sollu-pos-client`)
- Refactor `VariantDialogNotifier`:
  - Resolusi harga dan ketersediaan varian menggunakan tabel pivot `ProductItemVariantGroupOptions` di SQLite.
  - Dukungan penambahan modifier ke item keranjang.
- Perbarui `CartItem` dan `CartProvider` agar terikat ke `product_item_id`.
- Decoupled stock behavior: Produk dengan `track_inventory = false` menampilkan ikon tak terhingga (`∞`) dan checkout kasir tidak pernah diblokir oleh pengecekan stok.

## Acceptance Criteria

### Backend Verification & Integrity
- [ ] `php artisan migrate:rollback --step=1 && php artisan migrate` sukses tanpa error constraint.
- [ ] Automated feature test `ProductManagementTest` berhasil (create/update single, variant, service, and inventory link).
- [ ] Automated feature test `ProductFeatureGatingTest` memverifikasi proteksi HTTP 403 `feature_locked` untuk paket yang tidak memiliki izin fitur.
- [ ] Automated feature test `MasterDataSyncTest` memverifikasi `product_items` dan `product_item_variant_group_options` terekspor dengan benar.
- [ ] `vendor/bin/pint --dirty --format agent` lolos tanpa menyisakan syntax/style issues.
- [ ] `npm run lint` pada `sollu-app` lolos dengan zero error.

### Flutter POS Client Verification & Integrity
- [ ] `flutter pub run build_runner build --delete-conflicting-outputs` selesai tanpa konflik schema SQLite.
- [ ] `flutter analyze` menghasilkan zero issues / errors.
- [ ] Automated widget/unit tests pada `PosRepository` dan `VariantDialogNotifier` berhasil dijalankan (`flutter test`).
- [ ] Hardware scan listener dan text search pada kasir POS dapat menemukan item berdasarkan barcode fisik maupun SKU varian.
- [ ] Produk tanpa pelacakan stok (`track_inventory = false`) dapat diselesaikan hingga pembayaran tanpa error kekurangan stok.


## 2026-10-22T12:55:21Z

Implementasi perombakan arsitektur Modul Produk terpadu pada backend Laravel 12 (`sollu-app`) dan Flutter POS client (`sollu-pos-client`) sesuai spesifikasi `product_module_architecture_plan.md` dan panduan ketat `AGENTS.md`. Melanjutkan eksekusi dari handoff Sentinel (`.agents/teamwork/sentinel/handoff.md`).

Working directory: 
- `/Users/whykrr/Documents/Projects/Laravel/sollu-app`
- `/Users/whykrr/Documents/Projects/Flutter/sollu-pos-client`

Integrity mode: development

Reference:
- Specification Plan: `/Users/whykrr/.gemini/antigravity/brain/ecda9398-3367-4ba5-9cb2-b6ef132e7a7f/product_module_architecture_plan.md`
- Previous Handoff: `/Users/whykrr/Documents/Projects/Flutter/sollu-pos-client/.agents/teamwork/sentinel/handoff.md`
- Guidelines Backend: `/Users/whykrr/Documents/Projects/Laravel/sollu-app/AGENTS.md`
- Guidelines Flutter POS: `/Users/whykrr/Documents/Projects/Flutter/sollu-pos-client/AGENTS.md`

## Current Progress & Resume Context
- **Milestone R1 (Database Foundation, Seeders & Normalization):** SELESAI & LULUS MUTLAK (Gate: PASS). 5 migrasi aktif di PostgreSQL, data disanitasi, rollback symmetry lolos.
- **Milestone R2 (Backend Service Layer, Feature Gating & Sync API):** KODE 100% IMPLEMENTED & PASSING UNIT TESTS. Hanya perlu verifikasi gate akhir (penyesuaian urutan deaktivasi inventory di `deleteProduct` dan delegasi `deleteService`).
- **Focus Milestones to Complete:**
  - R2: Selesaikan verifikasi gate R2.
  - R3: Admin Web UI/UX Inertia Vue 3 (`sollu-app`).
  - R4: Flutter POS Local Database (Drift SQLite) & Repository (`sollu-pos-client`).
  - R5: Flutter POS Variant Dialog & Cart Integration (`sollu-pos-client`).

## Requirements

### R1. Backend Database Foundation, Seeders & Data Normalization (`sollu-app`) [COMPLETED & VERIFIED]
- Migrasi tabel pivot `product_item_variant_group_options`, kolom `product_item_id` pada `recipe_versions`, indeks GIN fulltext & B-tree komposit, feature flag di `FeatureEnum`, dan backfill data telah selesai dan diverifikasi.

### R2. Backend Service Layer, Feature Gating & Sync API (`sollu-app`) [NEARLY COMPLETE]
- Refactor `ProductService`:
  - Enforce aturan dependensi: `sellable = false` secara mutlak mengatur `is_show = false`.
  - Unified Item Pattern: Selalu buat minimal 1 `ProductItem`. Produk single memiliki default item; produk varian memiliki N item terhubung via pivot.
  - Total Decoupling: Hanya buat baris `inventory_items` dan saldo `inventory_balances` jika `track_inventory = true`.
  - Selesaikan 2 penyesuaian minor: Urutan penonaktifan `inventoryItems` sebelum penghapusan `productItems` di `ProductService::deleteProduct`, dan delegasi `deleteService` di `ServiceProductController::destroy`.
- Endpoint & Controller:
  - `RawMaterialController` (`/master/raw-materials`) dengan `item_type = 'raw_material'`, `sellable = false`, `is_show = false`, `track_inventory = true`.
  - `RecipeTemplateController` (`/master/recipes`) untuk manajemen template resep dan versi BOM.
  - Aktifkan rute `ModifierGroupController` (`/master/modifiers`).
- Lindungi seluruh rute dengan middleware `plan.feature:...` (`product_variant`, `product_bom`, `product_modifier`).
- `MasterDataSyncService` mengekspor `product_items` dan `product_item_variant_group_options` ke Flutter POS client.

### R3. Admin Web UI/UX Inertia Vue 3 (`sollu-app`)
- Update `CreateEdit.vue` pada Produk Barang:
  - Watcher dua arah pada `sellable`: mematikan `sellable` otomatis mematikan dan mendisabled switch `is_show`.
  - Tab 2 Seksi Varian dibungkus `<FeatureLock :feature="$enums.FeatureEnum.PRODUCT_VARIANTS">`.
  - Tab 4 Resep Bahan Baku (BOM) dibungkus `<FeatureLock :feature="$enums.FeatureEnum.RECIPE_MANAGEMENT">`.
  - Tab 5 Modifier dibungkus `<FeatureLock :feature="$enums.FeatureEnum.PRODUCT_MODIFIERS">`.
- Buat halaman antarmuka baru:
  - `Master/Product/RawMaterial/Index.vue` & drawer form bahan baku.
  - `Master/Product/Recipe/Index.vue` & drawer form template resep.
- Tambahkan sub-menu "Bahan Baku", "Template Resep", dan "Opsi Tambahan" pada navigasi sidebar di bawah kelompok Master Produk, dengan visualisasi `v-feature.lock`.
- Form Kategori (`CategoryForm.vue`) secara tegas membatasi kedalaman maksimal 2 tingkat (Root -> Child).

### R4. Flutter POS Local Database & Repository (`sollu-pos-client`)
- Tambahkan tabel Drift SQLite `ProductItems` dan `ProductItemVariantGroupOptions` di `master_data_tables.dart`.
- Jalankan build runner: `flutter pub run build_runner build --delete-conflicting-outputs`.
- Refactor `InitialSyncService` dan `DeltaSyncService` untuk menyerap payload `product_items` dan `product_item_variant_group_options`.
- Refactor `PosRepository`:
  - Gantikan query UNION lama dengan query bersih berbasis `ProductItems` left join `Inventories`.
  - Implementasikan Omni-Search instan mencocokkan `barcode`, `sku`, `name`, dan `variant_combination`.
  - Filter kategori agregatif: memilih kategori induk otomatis memunculkan produk induk dan seluruh sub-kategorinya.

### R5. Flutter POS Variant Dialog & Cart Integration (`sollu-pos-client`)
- Refactor `VariantDialogNotifier`:
  - Resolusi harga dan ketersediaan varian menggunakan tabel pivot `ProductItemVariantGroupOptions` di SQLite.
  - Dukungan penambahan modifier ke item keranjang.
- Perbarui `CartItem` dan `CartProvider` agar terikat ke `product_item_id`.
- Decoupled stock behavior: Produk dengan `track_inventory = false` menampilkan ikon tak terhingga (`∞`) dan checkout kasir tidak pernah diblokir oleh pengecekan stok.

## Acceptance Criteria

### Backend Verification & Integrity
- [ ] `php artisan migrate:rollback --step=1 && php artisan migrate` sukses tanpa error constraint.
- [ ] Automated feature test `ProductManagementTest` berhasil (create/update single, variant, service, and inventory link).
- [ ] Automated feature test `ProductFeatureGatingTest` memverifikasi proteksi HTTP 403 `feature_locked` untuk paket yang tidak memiliki izin fitur.
- [ ] Automated feature test `MasterDataSyncTest` memverifikasi `product_items` dan `product_item_variant_group_options` terekspor dengan benar.
- [ ] `vendor/bin/pint --dirty --format agent` lolos tanpa menyisakan syntax/style issues.
- [ ] `npm run lint` pada `sollu-app` lolos dengan zero error.

### Flutter POS Client Verification & Integrity
- [ ] `flutter pub run build_runner build --delete-conflicting-outputs` selesai tanpa konflik schema SQLite.
- [ ] `flutter analyze` menghasilkan zero issues / errors.
- [ ] Automated widget/unit tests pada `PosRepository` dan `VariantDialogNotifier` berhasil dijalankan (`flutter test`).
- [ ] Hardware scan listener dan text search pada kasir POS dapat menemukan item berdasarkan barcode fisik maupun SKU varian.
- [ ] Produk tanpa pelacakan stok (`track_inventory = false`) dapat diselesaikan hingga pembayaran tanpa error kekurangan stok.
