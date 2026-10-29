# 03. Auth & Enums

- **Enums as SSOT:** Gunakan fitur Enum Dart 3. Sinkronkan nama enum dengan yang ada di Laravel (terutama `PermissionEnum` dan `FeatureEnum`).
- **Auth Layer:** Token API perangkat POS disimpan di `flutter_secure_storage`.
- **Local PIN & Offline Cashier Auth:** Login cepat kasir menggunakan PIN 6 digit yang divalidasi terhadap hash lokal di Drift SQLite / Secure Storage.
- **Synced Permissions & No Wildcards:**
  - Daftar kasir dan permission disinkronkan dari endpoint server (`pos:outlet:{id}:employees`) ke database lokal.
  - DILARANG KERAS menggunakan wildcard permission (`.*`). Seluruh permission kasir tersimpan dan divalidasi sebagai izin eksplisit.
- **Tiered Gating & Supervisor Verification:**
  - Kasir POS beroperasi dalam konteks outlet yang terikat paket langganan (fitur `pos`, `shift_cashier`, `double_authorization`).
  - Aksi sensitif (void transaksi, override harga/diskon di luar batas kasir biasa, buka drawer manual) memverifikasi izin kasir lokal (`is_root_user` atau kode permission terkait).
  - Jika aksi memerlukan otorisasi supervisor (fitur `double_authorization`), tampilkan dialog PIN supervisor dan validasi terhadap staf yang memiliki permission `transaction.validation_supervision`.
  - Jika outlet dinonaktifkan (`is_active = false`), server mengembalikan HTTP 403 `OUTLET_INACTIVE` yang wajib direspons dengan layar peringatan outlet nonaktif.
  - Rujukan arsitektur pembatasan fitur bertingkat lengkap: lihat domain skill `domain-access-and-feature-gating` di backend repository.
