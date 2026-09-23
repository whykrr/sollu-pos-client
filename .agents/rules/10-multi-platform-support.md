# 10. Multi-Platform Support (Android, macOS, Windows)

- **Cross-Platform Compatibility:** Seluruh kode (termasuk fitur, *package*/dependensi, dan UI) HARUS dijamin kompatibel untuk di-build dan berjalan lancar di **Android**, **macOS**, dan **Windows**.
- **Adaptive UI:** Gunakan layout yang responsif (seperti `LayoutBuilder`, `MediaQuery`, atau grid responsif) agar antarmuka tetap optimal, baik digunakan pada layar sentuh (*mobile/tablet* Android) maupun layar desktop lebar (macOS & Windows).
- **Platform-Specific Code:** Hindari *package* yang hanya mensupport satu platform. Jika mutlak dibutuhkan (misalnya untuk integrasi printer *hardware* spesifik), pastikan Anda membungkus *logic* tersebut dengan pengecekan platform (`Platform.isWindows`, `Platform.isAndroid`, dsb) atau menggunakan teknik isolasi *interface* agar proses kompilasi (*build*) di platform lain tidak rusak.
