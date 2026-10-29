# 05. Data Standards

- **API Client:** Gunakan `Dio` lengkap dengan interceptor untuk autentikasi dan error handling.
- **Local DB:** Wajib menggunakan `Drift` untuk ORM SQLite.
- **Repository Pattern:** Semua akses data (baik dari API atau Drift) harus melalui Repository interface di layer Domain.

---

## Standar Parsing Pengaturan Sinkronisasi Outlet & Default Values

- **Fallback Default False untuk Pengaturan Sensitif:**
  - Pengaturan keamanan kasir atau otorisasi tambahan (seperti `enable_supervisor_pin`) WAJIB memiliki fallback default `false` di seluruh lapisan: SharedPreferences, service parser, dan Riverpod Provider.
  - Parser `syncSettingsPayload` wajib memeriksa variasi tipe data (`true`, `1`, `'true'`, `'1'`) dan secara tegas fallback ke `false` jika data null/absen:
    ```dart
    final bool enableSupervisorPin =
        structuredSettings['enable_supervisor_pin'] == true ||
        structuredSettings['enable_supervisor_pin'] == 1 ||
        structuredSettings['enable_supervisor_pin'] == 'true' ||
        structuredSettings['enable_supervisor_pin'] == '1' ||
        (structuredSettings['enable_supervisor_pin'] == null && (existingSettings?['enableSupervisorPin'] == true));
    ```
- **Pengecekan di Antarmuka Kasir:**
  - Sebelum menampilkan modal challenge/dialog supervisor, antarmuka kasir wajib memeriksa provider pengaturan terlebih dahulu. Jika fitur supervisor guard dimatikan merchant, kasir berhak memproses aksi tanpa pemblokiran PIN.
