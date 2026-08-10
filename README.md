# Sollu POS App

Aplikasi Kasir (Point of Sale) berbasis Flutter yang dirancang dengan pendekatan *offline-first* menggunakan SQLite. Aplikasi ini dirancang khusus untuk kecepatan dan kemudahan penggunaan operasional toko dengan dukungan integrasi hardware lokal dan sinkronisasi ke cloud (backend Laravel).

## Fitur Utama

- **Offline-First**: Aplikasi beroperasi sepenuhnya secara lokal (SQLite), sehingga transaksi tetap bisa berjalan tanpa internet.
- **Auto-Sync**: Transaksi yang dilakukan secara offline akan tersinkronisasi ke server secara asinkron di *background*.
- **Manajemen Shift**: Buka/tutup shift kasir beserta pencatatan *cash in* dan *cash out*.
- **Dukungan Hardware**: Siap terhubung ke *barcode scanner* (via event keyboard cepat), *cash drawer*, dan *thermal printer*.
- **Pembayaran Fleksibel**: Mendukung pembayaran tunai (termasuk kalkulasi kembalian), QRIS, Transfer Bank, EDC, dan *Split Payment*.
- **Hold Order**: Fitur untuk menahan pesanan pelanggan (*hold order*) tanpa memotong stok, untuk dilanjutkan nanti.
- **Shortcuts Kasir**: Dioptimasi untuk penggunaan keyboard guna mempercepat navigasi kasir (F1 - F12).

## Tech Stack

- **Framework**: Flutter
- **State Management**: Riverpod
- **Local Database**: Drift (SQLite)
- **Routing**: GoRouter
- **HTTP Client**: Dio

## Cara Menjalankan Aplikasi

*(Catatan: Langkah ini dapat berubah seiring pengembangan fitur lebih lanjut)*

1. Pastikan Anda telah menginstal Flutter SDK di mesin Anda.
2. Clone atau buka repositori ini di VS Code atau Android Studio.
3. Jalankan `flutter pub get` untuk mengunduh seluruh dependensi.
4. Karena proyek ini menggunakan Drift (code generation), jalankan *build runner* untuk meng-generate file-file database:
   ```bash
   dart run build_runner build -d
   ```
5. Jalankan aplikasi menggunakan perintah:
   ```bash
   flutter run
   ```

## Struktur Direktori

Aplikasi ini menggunakan arsitektur berbasis fitur (*Feature-First*), dengan struktur umum sebagai berikut:

- `lib/core/`: Layanan inti (networking, konfigurasi database, tema, utils).
- `lib/shared/`: Komponen UI dan *widgets* yang digunakan bersama.
- `lib/features/`: Modul/layar aplikasi yang dipisah berdasarkan fitur:
  - `auth/`: Autentikasi dan *pairing device*.
  - `pos/`: Layar utama transaksi kasir.
  - `shift/`: Layar manajemen shift.
  - `payment/`: Modul dan *popup* pembayaran.
  - `history/`: Modul riwayat transaksi.

---
*Dokumen ini akan terus diperbarui selama proses implementasi.*
