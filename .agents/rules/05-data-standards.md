# 05. Data Standards

- **API Client:** Gunakan `Dio` lengkap dengan interceptor untuk autentikasi dan error handling.
- **Local DB:** Wajib menggunakan `Drift` untuk ORM SQLite.
- **Repository Pattern:** Semua akses data (baik dari API atau Drift) harus melalui Repository interface di layer Domain.

---

## Standar Migrasi Skema SQLite (Drift) & Backward Compatibility

- **Parameter Rilis & Immutabilitas Drift:**
  - Setiap rilis aplikasi ke toko aplikasi atau deployment kasir dikendalikan oleh **Git Tag rilis** (contoh: `v1.1.5`, `v1.1.7`).
  - Database SQLite lokal pada perangkat kasir memegang data historis dan transaksi offline yang belum tersinkronisasi.
  - **DILARANG KERAS** mengubah atau menghapus penanganan migrasi versi historis (`if (from < X)`) pada `MigrationStrategy` yang sudah dirilis di git tag sebelumnya.
- **Kenaikan `schemaVersion` Wajib:**
  - Setiap penambahan kolom, tabel baru, atau perubahan indeks Drift **WAJIB menaikkan `schemaVersion`** secara berurutan di `lib/core/database/app_database.dart` (contoh: dari `11` menjadi `12`).
- **Strategi `MigrationStrategy.onUpgrade` Non-Destruktif & Batas Ganda (Double-Bounded):**
  - **Batas Ganda Versi Wajib:** Untuk mencegah eksekusi penambahan kolom secara prematur saat test harness melakukan migrasi parsial berjenjang (misalnya migrasi bertahap dari v10 ke v11: `onUpgrade(migrator, 10, 11)`), setiap penanganan migrasi versi baru **WAJIB menggunakan batas ganda** `if (from < X && to >= X)`.
  - **Pengecekan Defensif Tabel SQLite:** Sebelum memanggil `m.addColumn()`, selalu pastikan tabel target telah eksis di database (cek `sqlite_master`) guna menghindari `SqliteException: no such table` pada instansiasi mock test harness.
  - Seluruh perubahan skema wajib di-handle secara bertahap per versi:
    ```dart
    onUpgrade: (m, from, to) async {
      // Step migrasi historis tetap dipertahankan utuh
      if (from < 11 && to >= 11) {
        await m.createTable(productItemVariantGroupOptions);
      }
      // Step versi baru dengan batas ganda dan cek defensif
      if (from < 12 && to >= 12) {
        final tableExists = await customSelect("SELECT 1 FROM sqlite_master WHERE type='table' AND name='payment_methods'").get();
        if (tableExists.isNotEmpty) {
          await m.addColumn(paymentMethods, paymentMethods.provider);
        }
      }
    }
    ```
  - **Larangan Drop Tabel Destruktif:** Dilarang keras melakukan `DROP TABLE` pada tabel operasional kasir (`transactions`, `shifts`, `cash_movements`, `cart_items`) saat upgrade, guna mencegah hilangnya transaksi offline yang belum terunggah ke backend.
- **Code Generation Wajib:** Setiap modifikasi tabel Drift wajib diuji dan dikompilasi ulang:
  ```bash
  flutter pub run build_runner build --delete-conflicting-outputs
  ```

---

## Standar Parsing Pengaturan Sinkronisasi Outlet & Default Values

- **Fallback Default False untuk Pengaturan Sensitif:**
  - Pengaturan keamanan kasir atau otorisasi tambahan (seperti `enable_supervisor_pin`) WAJIB memiliki fallback default `false` di seluruh lapisan: SharedPreferences, service parser, dan Riverpod Provider.
  - Parser `syncSettingsPayload` wajib memeriksa variasi tipe data (`true`, `1`, `'true'`, `'1'`) dan secara tegas fallback ke `false` jika data null/absen:
    ```dart
    final bool enableSupervisorPin =
        structuredSettings['enable_supervisor_pin'] == true ||
        structuredSettings['enable_supervisor_pin'] == 1 ||
        structuredSettings['enable_supervisor_pin'] == 'true' ||
        structuredSettings['enable_supervisor_pin'] == '1' ||
        (structuredSettings['enable_supervisor_pin'] == null && (existingSettings?['enableSupervisorPin'] == true));
    ```
- **Pengecekan di Antarmuka Kasir:**
  - Sebelum menampilkan modal challenge/dialog supervisor, antarmuka kasir wajib memeriksa provider pengaturan terlebih dahulu. Jika fitur supervisor guard dimatikan merchant, kasir berhak memproses aksi tanpa pemblokiran PIN.
