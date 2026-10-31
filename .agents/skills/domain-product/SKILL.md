---
name: domain-product
description: >-
    Knowledge and standards for Product, POS Catalog & Payment Domain in Sollu POS Client. Covers Drift SQLite
    schema v12 (ProductItems, PaymentMethods, @TableIndex), PosRepository omni-search,
    deterministic industry-standard payment priority, aggregative parent-child category filter,
    VariantDialogNotifier SQLite pivot resolution, CartItem & CartProvider modifier deduplication,
    decoupled infinite stock (Stok: ∞), Fast Retail keyboard shortcuts, and supervisor void.
    Activate whenever working on POS catalog, product search, variant dialog, cart, payment methods, or sync absorption.
---

# Domain Skill: Modul Produk, Katalog POS & Metode Pembayaran

Panduan arsitektur dan aturan baku untuk **Modul Produk, Katalog Kasir, dan Metode Pembayaran** pada **Sollu POS Client** (Flutter, Drift SQLite, Riverpod).

---

## 1. Skema Database Lokal Drift (v12)

Tabel master data didefinisikan di `lib/core/database/tables/master_data_tables.dart`:

```
┌────────────────────────────────────────────────────────────────────────┐
│                         Drift SQLite Schema                            │
├──────────────────────────────┼─────────────────────────────────────────┤
│ Products                     │ Data produk induk (name, category_id)   │
│ ProductItems                 │ Unit item: barcode, sku, price, combi   │
│ ProductItemVariantGroup...   │ Pivot item_id <-> variant_group_opt_id  │
│ VariantGroups                │ Kelompok varian (Ukuran, Level)         │
│ VariantGroupOptions          │ Nilai opsi (S, M, Pedas, Manis)         │
│ ModifierGroups (+Options)    │ Add-ons & opsi tambahan                 │
│ Categories                   │ Kategori induk & anak                   │
│ Inventories                  │ Saldo stok lokal (left joined)          │
│ PaymentMethods (v12)         │ Metode pembayaran kasir (aturan industri)│
└──────────────────────────────┴─────────────────────────────────────────┘
```

### Karakteristik Kunci
- `ProductItems.variantCombination`: Berisi string kombinasi (e.g. `"Merah, XL"`) untuk produk varian, atau `null` untuk produk single.
- Skema v10 menambahkan tabel `ProductItems` dan `ProductItemVariantGroupOptions` dengan foreign key non-destructive migration di `app_database.dart`.
- Skema v11 menambahkan indeks `@TableIndex` pada foreign keys utama (`product_id`, `sku`, `barcode`).
- **Skema v12 (Payment Methods Standar Industri):**
  - Kolom legacy `sort_order` dan `local_sort_order` dihapus total dari tabel `PaymentMethods`.
  - Penambahan kolom operasional: `provider`, `account_number`, `account_name`, `reference_policy` ('optional' | 'mandatory' | 'hidden'), `open_cash_drawer`, `instructions`, `qr_image_url`, dan `is_system`.
  - **Urutan Deterministik Standar Industri:** Seluruh tombol pembayaran kasir diurutkan secara otomatis melalui `activePaymentMethodsProvider`:
    $$\text{CASH (1)} \rightarrow \text{QRIS (2)} \rightarrow \text{EDC (3)} \rightarrow \text{EWALLET (4)} \rightarrow \text{BANK\_TRANSFER (5)} \rightarrow \text{CUSTOM (6)}$$
    Di dalam kelompok yang sama, diurutkan berdasarkan $\text{isSystem DESC} \rightarrow \text{name ASC}$.
  - Kasir UX:
    - `CASH`: Kembalian cepat, pembukaan laci kasir mengikuti konfigurasi `openCashDrawer`.
    - `QRIS`: Tampilan QR Statis visual dengan tap-to-zoom modal.
    - `BANK_TRANSFER`: Kartu informasi rekening lengkap dengan tombol 1-tap "Salin Rekening".
    - `EDC / EWALLET`: Tampilan provider dan validasi wajib nomor referensi jika `referencePolicy == 'mandatory'`.

---

## 2. Kueri Katalog `PosRepository` & Omni-Search

Pencarian produk kasir di `lib/features/pos/data/pos_repository.dart` berpusat pada `ProductItems` yang di-inner join ke `Products` dan left join ke `Inventories`.

### Hirarki Prioritas Omni-Search
Pencocokan multi-kunci instan mengevaluasi prioritas:
$$\text{Barcode Item} \rightarrow \text{SKU Item} \rightarrow \text{Barcode Induk} \rightarrow \text{SKU Induk} \rightarrow \text{Nama Produk} \rightarrow \text{Kombinasi Varian}$$

### Filter Kategori Agregatif
Pemilihan kategori induk (`parent_id = null`) secara otomatis mengikutsertakan seluruh sub-kategori di bawahnya melalui ekspresi rekursif Drift SQLite:
```dart
category_id IN (parent_id, child_id_1, child_id_2...)
```

### Resolusi Varian Kardinalitas Tepat (`findProductItemIdForVariants`)
Untuk mencegah *false-positive* saat kombinasi varian baru dipilih sebagian, kueri SQLite mewajibkan:
$$\text{COUNT}(variant\_group\_option\_id) = \text{jumlah opsi yang dipilih}$$

---

## 3. Alur Dialog Varian & Keranjang Kasir

### Dynamic Variant Resolution (`VariantDialogNotifier`)
- Mengambil opsi terpilih dan memanggil `posRepo.findProductItemIdForVariants(productId, selectedOptionIds)`.
- Jika valid $\rightarrow$ memperbarui harga, SKU, dan ketersediaan stok, serta menyetel `clearErrorMessage: true`.
- Jika kombinasi tidak valid $\rightarrow$ menampilkan banner pesan error `"Kombinasi varian ini tidak tersedia"`.

### Normalisasi Modifier & Deduplikasi Keranjang (`CartProvider`)
- Penambahan item ke keranjang belanja menggabungkan item jika `productItemId` identik dan komposisi modifier sama.
- Fungsi `_modifiersEqual` menggunakan `DeepCollectionEquality.unordered()` dengan menyingkirkan kelompok list kosong (`e.value.isNotEmpty`), sehingga `{}` dan `{'Topping': []}` dianggap identik.

### Penanganan Stok Decoupled (`track_inventory = false`)
- Produk tanpa pelacakan stok menampilkan badge visual **`Stok: ∞`** (`Icons.all_inclusive_rounded`).
- Validasi stok kasir dan `TransactionRepository` tidak pernah memblokir checkout untuk item non-inventori.

---

## 4. Matriks Shortcut Keyboard Kasir Fast Retail
| Shortcut | Fungsi Operasional Kasir |
| :--- | :--- |
| `F1` | Fokus Barcode / Buka Dialog Pencarian Katalog |
| `F2` | Ubah Kuantitas Item Aktif |
| `F3` | Pilih / Tambah Pelanggan (CRM) |
| `F4` | Terapkan Diskon / Promo Transaksi |
| `F8` | Quick Exact Cash (Bayar Tunai Pas, Cetak & Buka Laci) |
| `F9` | Tahan Transaksi (Park Bill) |
| `F10` | Panggil Transaksi Tertahan (Recall Bill) |
| `F12` / `Enter` | Buka Menu Pembayaran / Selesaikan Transaksi |
| `Space` | Buka Laci Kasir Manual (Cash Drawer) |
| `Esc` | Bersihkan Keranjang / Tutup Dialog Aktif |
| `+` / `-` | Tambah / Kurangi Qty Item Terpilih |
| `1` – `3` | Shortcut Cepat Metode Pembayaran (Tunai, QRIS, EDC) |

---

## 5. Void Transaksi & Sinkronisasi Multi-Tender & Modifiers JSON
- Transaksi kasir menyertakan seluruh detail array `payments` (multi-tender) dan `modifiers` JSON per item.
- Modul Void Transaksi: Memerlukan otorisasi PIN supervisor, membatalkan transaksi hari berjalan pada shift kasir aktif, serta memulihkan saldo inventori dan layer FIFO di cloud.
