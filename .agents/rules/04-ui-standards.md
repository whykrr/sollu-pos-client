# 04. UI Standards

## Typography
- Gunakan `GoogleFonts.plusJakartaSansTextTheme()`. Pastikan ukuran font diskalakan berdasarkan ukuran layar jika perlu (hindari hardcode ukuran yang terlalu kecil di layar besar atau terlalu besar di layar kecil).

## Colors (High Contrast & Elegant)
Patuhi `SolluColors` yang telah disesuaikan untuk kontras tinggi dan aman untuk berbagai *color gamut* monitor:
- **Primary (Navy Blue):** `#1E3A8A` (Lebih gelap dari sebelumnya untuk kontras teks putih yang lebih tajam).
- **Secondary (Teal/Turquoise):** `#0F766E` (Mengurangi saturasi berlebih agar tidak ambigu pada monitor lama).
- **Background:** `#F1F5F9` (Slate 100, memberikan batas yang jelas dengan komponen *Surface* `#FFFFFF`).
- **Text:** `#0F172A` (Sangat gelap mendekati hitam untuk memastikan keterbacaan optimal).
- *Catatan:* Hindari penggunaan warna abu-abu muda (`#94A3B8`) pada teks di atas latar belakang putih/terang jika tidak memenuhi standar aksesibilitas WCAG AA (minimal rasio 4.5:1). Gunakan `#475569` untuk teks sekunder.

## Styling & Bentuk
- Border radius: **12px** untuk input/tombol, **20px** untuk cards/dialogs.
- Shadow: Gunakan *ambient shadow* yang sangat tipis dan menyebar (contoh: `blurRadius: 15, color: Colors.black.withValues(alpha: 0.05)`) menggantikan material elevation bawaan agar terlihat lebih modern dan bersih.

## Responsiveness & Adaptive UI
Sesuaikan desain secara responsif untuk layar sentuh (tablet/mobile Android) serta layar desktop (macOS & Windows):
- **Responsive Breakpoints:** 
  - Mobile/Kecil: `< 600px`
  - Tablet/Menengah: `600px - 1024px`
  - Desktop/Besar: `> 1024px`
- Gunakan `LayoutBuilder` atau `MediaQuery` untuk merender layout yang berbeda (misal: *Grid* 2 kolom di tablet, 4 kolom di desktop).
- Jangan gunakan *fixed width/height* secara absolut (`width: 300`) jika bisa menggunakan fleksibilitas layar (`Expanded`, `Flexible`, atau persentase lebar layar).
- Pastikan interaksi layar sentuh (tablet) memiliki ruang bernapas (*padding*) antar elemen untuk mencegah salah sentuh (*fat finger*), pertahankan *tap target* minimal `48x48 dp`.

## Dual-Mode POS & Fast Retail Keyboard Operation
- **Auto-Detection Default:**
  - Desktop (macOS, Windows, Linux) $\rightarrow$ Default ke **Fast Retail Mode** (fokus tabel keranjang ringkas, barcode autofocus terus-menerus, navigasi keyboard penuh).
  - Tablet / Mobile $\rightarrow$ Default ke **Visual Touch Mode** (katalog grid gambar, tap target besar 48x48 dp).
  - Kasir dapat mengubah preferensi secara manual melalui Pengaturan Kasir (*manual override*).
- **Persistent Barcode Autofocus:**
  - Pada mode Fast Retail, field input barcode/pencarian wajib mempertahankan autofocus terus-menerus (`autofocus: true`, `FocusNode(canRequestFocus: true)`).
  - Autofocus tidak boleh merebut fokus saat dialog aktif (modal pembayaran, varian, diskon) terbuka.
- **Standar PPN Inklusif 11% Non-Aditif:**
  - Pada sistem retail Indonesia dengan harga termasuk pajak (PPN Inklusif), pajak diekstraksi dari total kotor:
    $$\text{Pajak} = \text{Subtotal} - \left(\frac{\text{Subtotal}}{1 + \frac{\text{TaxRate}}{100}}\right)$$
  - Pajak **DILARANG** ditambahkan kembali ke grand total. Grand total tetap bernilai subtotal dikurangi diskon.
- **Pembulatan Uang Tunai (Cash Rounding):**
  - Pembulatan ke kelipatan Rp 100 terdekat hanya berlaku untuk metode pembayaran Tunai (`Cash`). Pembayaran non-tunai (QRIS, Kartu, Transfer) tetap menggunakan nominal eksak.
