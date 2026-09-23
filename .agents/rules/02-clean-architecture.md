# 02. Clean Architecture & Feature-First

Aplikasi wajib menggunakan **Clean Architecture** berbasis *Feature-First*.
Struktur direktori di `lib/features/`:
- `feature_name/`
  - `presentation/` (Pages, Widgets, Riverpod Controllers)
  - `domain/` (Entities, Repository Interfaces)
  - `data/` (Models, Repository Implementations, Data Sources)

- **Dependency Injection:** Gunakan Riverpod Providers untuk menyediakan repository ke controller/usecase.
- **Anti-Overfetching:** Jangan memuat relasi data yang tidak ditampilkan di layar.
