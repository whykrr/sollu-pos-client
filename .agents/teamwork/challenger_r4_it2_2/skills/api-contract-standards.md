---
name: api-contract-standards
description: Standar penyelarasan endpoint Laravel backend ke Flutter model/repository.
---
# API Contract Standards (Shared Rule/Skill)
Gunakan skill ini untuk memastikan setiap field JSON response atau request body cocok antara backend dan Flutter client app. Termasuk parsing error message standar dari API.

## 1. Sentralisasi Endpoint & Versioning
- **Dilarang Magic String:** Endpoint dilarang ditulis manual langsung di repository atau service.
- **Kelas Terpusat:** Seluruh endpoint wajib didefinisikan di `lib/core/network/api_endpoints.dart` dengan format versioning (misal: `/v1/pos/sync/master`).
- **Base URL:** Base URL di `.env` (`API_BASE_URL`) diset ke root host API (misal `http://api.sollu.test`), sehingga pemanggilan Dio dengan path `/v1/pos/...` tidak memotong segmen versi.

## 2. Standar Respons & Header
- Backend mengirim header `X-API-Version: v1`.
- Jika backend mengembalikan header `Deprecation: true`, aplikasi pada mode debug wajib mencatat log peringatan.
- Response Envelope standar:
  - Sukses: `{ "success": true, "message": "...", "data": { ... } }`
  - Error: `{ "success": false, "message": "...", "error_code": "...", "errors": { ... } }`

## 3. Protokol AI Consultation Gate
- AI dilarang keras mengubah kontrak API atau menaikkan versi API tanpa persetujuan eksplisit dari user.
- Jika terindikasi breaking change pada skema atau payload, AI wajib berhenti dan menanyakan keputusan user terlebih dahulu.
