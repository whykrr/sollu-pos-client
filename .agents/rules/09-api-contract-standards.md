# 09. API Contract Standards & Backward Compatibility

- **Sinkronisasi Otomatis:** Setiap perubahan *Endpoint* API pada `sollu-app` (Laravel) HARUS diiringi dengan penyesuaian `Model`, `Repository`, dan konstanta `ApiEndpoints` di `sollu-pos-client`.
- **API Versioning & Sentralisasi Endpoint:**
  - Dilarang keras menulis *magic string* path URL di repository. Seluruh endpoint wajib didefinisikan secara terpusat di `lib/core/network/api_endpoints.dart` dengan format versioned (misal: `/v1/pos/...`).
  - Base URL di `.env` dan `AppConfig.apiBaseUrl` diset ke root domain API tanpa suffix modul (misal: `http://api.sollu.test`), sehingga resolusi path Dio dengan leading slash selalu akurat dan tidak menghapus segmen versi.
- **Data Class & Model Resilience (Backward & Forward Compatibility):**
  - Selalu gunakan `freezed` atau `json_serializable` untuk pembuatan model.
  - **Toleransi Kolom Baru:** Model JSON klien wajib dirancang tahan terhadap penambahan field baru dari backend (gunakan tipe nullable `?` atau default fallback `@Default(...)`). Deserialisasi dilarang crash hanya karena backend mengirimkan field tambahan yang belum dikenal klien.
  - Pastikan tipe data serasi (misal, `String` untuk `BigDecimal` atau format ISO 8601 untuk `DateTime`).
- **Resiliensi Sinkronisasi Offline:**
  - Struktur payload transaksi offline yang tersimpan di antrean Drift SQLite lokal wajib tetap dapat diproses oleh backend (backward compatible), meskipun aplikasi baru saja di-update atau backend mengalami update versi.
- **Penanganan Breaking Change & AI Gate:**
  - Klien harus mendeteksi respons error atau header `Deprecation` dari backend (RFC 8594).
  - AI dilarang keras mengubah format payload aktif tanpa memverifikasi backward compatibility pada kedua sisi (`sollu-app` dan `sollu-pos-client`).
