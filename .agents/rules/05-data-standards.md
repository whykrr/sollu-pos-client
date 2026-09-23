# 05. Data Standards

- **API Client:** Gunakan `Dio` lengkap dengan interceptor untuk autentikasi dan error handling.
- **Local DB:** Wajib menggunakan `Drift` untuk ORM SQLite.
- **Repository Pattern:** Semua akses data (baik dari API atau Drift) harus melalui Repository interface di layer Domain.
