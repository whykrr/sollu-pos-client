---
name: drift-database
description: Comprehensive best practices for Drift SQLite local database, schemaVersion increments, onUpgrade migration handlers, and backward compatibility.
---

# Drift Database & Schema Evolution Guidelines

Panduan baku pengelolaan basis data lokal SQLite menggunakan **Drift** pada **Sollu POS Client**. Dirancang untuk menjamin persistensi data offline kasir dan kompatibilitas skema lintas rilis Git Tag aplikasi.

---

## 1. Arsitektur Database Lokal & Parameter Rilis Git Tag

Aplikasi kasir Sollu POS berjalan pada berbagai platform (Android, macOS, Windows) dengan mode **Offline-First**. Transaksi penjualan, pergeseran kas kasir (*cash movements*), sesi shift, dan katalog produk disimpan di database lokal SQLite (`AppDatabase`).

1. **Git Tag sebagai Parameter Rilis Klien:**
   - Setiap rilis binary aplikasi ke merchant ditandai dengan Git Tag rilis SemVer (misal: `v1.1.5`, `v1.1.7`).
   - Perangkat kasir di lapangan dapat meng-upgrade aplikasi dari versi lama kapan saja saat online.
2. **Prinsip Immutabilitas Migrasi Drift:**
   - Blok penanganan migrasi versi historis (`if (from < X) { ... }`) pada `MigrationStrategy.onUpgrade` **BERSIFAT IMMUTABLE**.
   - Dilarang keras memodifikasi atau menghapus logika migrasi versi terdahulu yang telah dirilis pada git tag sebelumnya, karena perangkat merchant yang meng-upgrade dari versi lama memerlukan setiap tahapan DDL tersebut untuk bertransisi dengan mulus.

---

## 2. Alur Penyesuaian Skema (Schema Evolution Protocol)

Setiap kali ada penambahan tabel, penambahan kolom, atau perubahan indeks:

### Langkah 1: Modifikasi Definisi Tabel
Perbarui atau buat file tabel di folder modul terkait (misal: `lib/features/pos/data/database/tables/` atau `lib/core/database/tables/`).
- Gunakan tipe data Drift yang presisi (`TextColumn`, `IntColumn`, `RealColumn`, `BoolColumn`, `DateTimeColumn`).
- Kolom baru pada tabel transaksional yang sudah ada **wajib bersifat nullable** atau memiliki `.withDefault(...)`.

### Langkah 2: Naikkan `schemaVersion`
Buka `lib/core/database/app_database.dart` dan naikkan getter `schemaVersion` secara berurutan:
```dart
@override
int get schemaVersion => 12; // Misal naik dari 11 ke 12
```

### Langkah 3: Tambahkan Handler di `onUpgrade`
Tuliskan DDL spesifik untuk versi baru di dalam `MigrationStrategy`:
```dart
@override
MigrationStrategy get migration {
  return MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      // 1. Pertahankan seluruh handler migrasi historis (from < 2 .. from < 11)
      if (from < 11) {
        await m.createTable(productItemVariantGroupOptions);
      }
      
      // 2. Tambahkan handler untuk versi baru (from < 12)
      if (from < 12) {
        await m.addColumn(transactions, transactions.voidReason);
        await m.addColumn(transactions, transactions.voidAuthorizerId);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON;');
    },
  );
}
```

### Langkah 4: Larangan Operasi Destruktif
- **DILARANG KERAS** menjalankan `DROP TABLE` pada tabel aktif: `transactions`, `shifts`, `cash_movements`, `cart_items`.
- Menghapus tabel tersebut akan menghilangkan transaksi kasir yang belum tersinkronisasi (*unsynced offline queue*) dan menyebabkan kerugian finansial pada merchant.

---

## 3. Kompilasi & Verifikasi Kode

Setelah mengubah definisi tabel atau migrasi `AppDatabase`:

1. **Jalankan Code Generator:**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
2. **Verifikasi Static Analysis:**
   ```bash
   flutter analyze
   ```
3. **Uji Pengujian Unit / Database:**
   ```bash
   flutter test
   ```
