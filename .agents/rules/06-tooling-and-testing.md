# 06. Tooling & Testing

- **Linting:** Pastikan lolos `flutter analyze` berdasarkan `flutter_lints` tanpa warning.
- **Testing:** 
  - Gunakan `mocktail` untuk 100% mocking HTTP dan dependensi eksternal.
  - Gunakan `ProviderContainer` atau `ProviderScope(overrides: [...])` untuk testing Riverpod.
- **DoD (Definition of Done):** Fitur selesai jika sudah memiliki unit test untuk logic dan repository.
- **MCP Integration:** Agen AI harus mengutamakan `filesystem` MCP untuk manajemen direktori (membuat, memindah, memeriksa) dan mencari struktur file di dalam workspace, serta `flutter-tools` (bila tersedia) untuk analisa widget.
