# 09. API Contract Standards

- **Sinkronisasi Otomatis:** Setiap perubahan *Endpoint* API pada `sollu-app` (Laravel) HARUS diiringi dengan penyesuaian `Model`, `Repository`, dan konstanta `ApiEndpoints` di `sollu-pos-client`.
- **API Versioning & Sentralisasi Endpoint:**
  - Dilarang keras menulis *magic string* path URL di repository. Seluruh endpoint wajib didefinisikan secara terpusat di `lib/core/network/api_endpoints.dart` dengan format versioned (misal: `/v1/pos/...`).
  - Base URL di `.env` dan `AppConfig.apiBaseUrl` diset ke root domain API tanpa suffix modul (misal: `http://api.sollu.test`), sehingga resolusi path Dio dengan leading slash selalu akurat dan tidak menghapus segmen versi.
- **Data Class:** Selalu gunakan `freezed` atau `json_serializable` untuk pembuatan model.
- Pastikan tipe data serasi (misal, `String` untuk `BigDecimal` atau format ISO 8601 untuk `DateTime`).
- **Penanganan Breaking Change & AI Gate:** Klien harus mendeteksi respons error atau header `Deprecation` dari backend, serta AI wajib berkonsultasi ke user jika terindikasi perubahan skema breaking.
