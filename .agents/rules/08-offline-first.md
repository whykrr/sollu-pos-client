# 08. Offline-First Mandate

- **Wajib Offline-First:** Seluruh fitur transaksi dan inventori HARUS didesain agar dapat bekerja sepenuhnya tanpa koneksi internet.
- **Data Flow:** Aplikasi membaca dan menulis HANYA ke database SQLite lokal (`Drift`).
- **Pengecualian:** Pengecualian offline-first HANYA berlaku untuk proses autentikasi pertama, konfigurasi/pairing device, atau pengambilan data master awal.
