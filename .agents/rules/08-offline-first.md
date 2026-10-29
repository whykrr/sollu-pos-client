# 08. Offline-First Mandate

- **Wajib Offline-First:** Seluruh fitur transaksi dan inventori HARUS didesain agar dapat bekerja sepenuhnya tanpa koneksi internet.
- **Data Flow:** Aplikasi membaca dan menulis HANYA ke database SQLite lokal (`Drift`).
- **Pengecualian:** Pengecualian offline-first HANYA berlaku untuk proses autentikasi pertama, konfigurasi/pairing device, atau pengambilan data master awal.
- **Isolasi Device Auth & Error Handling Invariants:**
  - Token sesi perangkat dan basis data Drift lokal **DILARANG KERAS DIHAPUS / DI-UNPAIR** ketika menerima respon HTTP `403` (`OUTLET_INACTIVE`) atau HTTP `402` (`SUBSCRIPTION_EXPIRED`).
  - **HANYA** respon HTTP `401` dengan `error_code: DEVICE_UNPAIRED` yang diizinkan untuk membersihkan kredensial lokal.
  - Untuk status outlet dinonaktifkan (`OUTLET_INACTIVE`), kunci tampilan kasir secara elegan menggunakan modal non-dismissible `OutletInactiveDialog` yang dilengkapi panduan operasional kasir serta tombol interaktif periksa status (`GET /v1/pos/device/status`).
