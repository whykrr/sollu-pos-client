# 09. API Contract Standards

- **Sinkronisasi Otomatis:** Setiap perubahan *Endpoint* API pada `sollu-app` (Laravel) HARUS diiringi dengan penyesuaian `Model` dan `Repository` di `sollu-pos-client`.
- **Data Class:** Selalu gunakan `freezed` atau `json_serializable` untuk pembuatan model.
- Pastikan tipe data serasi (misal, `String` untuk `BigDecimal` atau format ISO 8601 untuk `DateTime`).
