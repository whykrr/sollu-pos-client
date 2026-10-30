---
name: api-contract-standards
description: Standards for aligning Laravel backend API endpoints and Flutter POS client data models with strict backward compatibility.
---

# API Contract Standards & Backward Compatibility

Pedoman penyelarasan kontrak endpoint antara **Sollu App (Laravel Backend)** dan **Sollu POS Client (Flutter)** untuk menjamin kelancaran komunikasi data dan backward compatibility.

---

## 1. Sentralisasi Endpoint & Versioning
- **Dilarang Magic String:** Endpoint dilarang ditulis manual langsung di repository atau service.
- **Kelas Terpusat:** Seluruh endpoint wajib didefinisikan di `lib/core/network/api_endpoints.dart` dengan format versioning (misal: `/v1/pos/sync/master`).
- **Base URL:** Base URL di `.env` (`API_BASE_URL`) diset ke root host API (misal `http://api.sollu.test`), sehingga pemanggilan Dio dengan path `/v1/pos/...` tidak memotong segmen versi.

---

## 2. Standar Respons, Header & Deprecations (RFC 8594)
- Backend mengirim header `X-API-Version: v1`.
- Jika backend mengembalikan header `Deprecation: true`, aplikasi pada mode debug wajib mencatat log peringatan.
- Response Envelope standar:
  - Sukses: `{ "success": true, "message": "...", "data": { ... } }`
  - Error: `{ "success": false, "message": "...", "error_code": "...", "errors": { ... } }`

---

## 3. Resiliensi Model Data & Backward Compatibility
- **Toleransi Kolom Tambahan:**
  - Backend Laravel dapat menambahkan field baru pada resource JSON kapan saja.
  - Model Flutter (menggunakan Freezed / JSON Serializable) **wajib mendefinisikan field baru sebagai nullable (`?`)** atau menyediakan `@Default(...)` agar tidak mengalami exception format parsing saat backend merilis field baru terlebih dahulu.
- **Resiliensi Antrean Offline:**
  - Transaksi yang di-buffer di SQLite lokal saat kasir offline harus memiliki struktur payload yang dapat dipahami backend, bahkan setelah backend melakukan update versi minor.
  - Hindari penghapusan field request yang esensial pada endpoint sinkronisasi POS tanpa siklus deprecasi bertahap.

---

## 4. Protokol AI Consultation Gate
- AI dilarang keras mengubah kontrak API atau memaksakan breaking change tanpa persetujuan eksplisit dari user.
- Jika terindikasi breaking change pada skema, header, atau payload, AI **WAJIB BERHENTI**, memaparkan analisis dampak, dan menyajikan opsi solusi kepada user terlebih dahulu.
