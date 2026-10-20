# 06. Tooling & Testing

## 1. Clean Architecture Test Mirroring (Anti-Sprawl)
- **Larangan Keras File Ad-hoc di Root `test/`:**
  - Dilarang menaruh file uji ad-hoc atau per-prompt langsung di direktori root `test/` (misal: `unpair_timestamp_purge_test.dart`, `delta_sync_test.dart`).
  - Seluruh file test **WAJIB mencerminkan struktur folder `lib/` (Mirroring Pattern)**:
    - `lib/features/<feature>/data/<repo>.dart` $\rightarrow$ `test/features/<feature>/data/<repo>_test.dart`
    - `lib/features/<feature>/presentation/...` $\rightarrow$ `test/features/<feature>/presentation/...`
    - `lib/core/services/<service>.dart` $\rightarrow$ `test/core/services/<service>_test.dart`
    - `lib/core/database/...` $\rightarrow$ `test/core/database/...`
- **Augment over Proliferate:**
  - Jika mengubah atau menambah logic pada repository, service, atau provider eksisting, **WAJIB menambahkan skenario baru ke dalam file test eksisting** untuk class tersebut.
  - File test baru hanya dibuat jika memang membuat class/widget/service baru.

---

## 2. Mocking & State Management Standards
- **Mocktail:** Gunakan `mocktail` untuk 100% mocking HTTP (Dio) dan platform channel yang tidak didukung saat unit test.
- **Riverpod State Testing:** Gunakan `ProviderContainer` untuk pengujian business logic/Notifiers, dan `ProviderScope(overrides: [...])` untuk Widget/Presentation tests.
- **Drift In-Memory Database:** Untuk pengujian repository lokal yang berinteraksi dengan SQLite, gunakan `AppDatabase.forTesting(NativeDatabase.memory())` agar query SQL dan integritas skema Drift terverifikasi nyata.

---

## 3. Protokol Alur Kerja TDD & Test Blast Radius
Saat melakukan pengembangan dengan pendekatan TDD (Test-Driven Development):

### A. Protokol Dual-Loop (Inner vs Outer Loop)
1. **Inner Loop (Micro-Cycle: Red $\rightarrow$ Green):**
   - Tulis failing test di suite yang relevan.
   - Agen **diizinkan** menjalankan test spesifik secara cepat:
     `flutter test test/features/<feature>/data/<repo>_test.dart --name="nama_skenario"`
   - Tulis kode implementasi minimal hingga test menjadi hijau (*Green*).
2. **Outer Loop (Refactor & Verification - WAJIB Sebelum Selesai):**
   - **DILARANG KERAS** mengklaim tugas selesai hanya berdasarkan 1 test tunggal.
   - Sebelum tugas diselesaikan, agen **WAJIB menjalankan Test Blast Radius**:
     a. Seluruh test dalam folder fitur/modul terkait: `flutter test test/features/<feature>/`
     b. Jika menyentuh transaksi, antrean, atau sinkronisasi, WAJIB menjalankan integration test POS & FIFO queue: `flutter test test/features/pos/`
     c. Pastikan tidak ada *legacy test* yang rusak.

---

## 4. Definition of Done (DoD)
Fitur atau perbaikan bug dinyatakan selesai (*Done*) HANYA JIKA:
1. Lolos `flutter analyze` berdasarkan `flutter_lints` tanpa warning maupun error.
2. Seluruh automated test dalam Test Blast Radius lolos 100% (`flutter test`).
3. Tidak ada penumpukan file test ad-hoc baru di root `test/`.
4. Kode terformat rapi sesuai konvensi Dart/Flutter.

