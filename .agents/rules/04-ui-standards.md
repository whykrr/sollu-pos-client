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
