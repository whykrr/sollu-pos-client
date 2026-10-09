# Sollu POS Client - AI Agent Guidelines

## 1. Project Context & Stack
- **Framework:** Flutter (Dart 3)
- **Architecture:** Clean Architecture (Feature-first: lib/features/)
- **State Management:** Riverpod (`flutter_riverpod`)
- **Local Database:** Drift (SQLite)
- **Networking:** Dio
- **Routing:** GoRouter

## 2. Core Rules Hierarchy (`.agents/rules/`)
Before designing or modifying code, ensure compliance with the standing rules:
- `01-ux-and-wording.md`: Mobile UX, tap targets, offline states, tone of voice.
- `02-clean-architecture.md`: Presentation, Domain, Data layers, Riverpod DI.
- `03-auth-and-enums.md`: Dart Enums SSOT, secure storage, local PIN auth.
- `04-ui-standards.md`: SolluColors, Plus Jakarta Sans, widget styling.
- `05-data-standards.md`: Dio repositories, Drift local database.
- `06-tooling-and-testing.md`: `flutter_lints`, Mocktail, widget tests.
- `07-git-and-changelog.md`: SemVer, Conventional Commits.
- `08-offline-first.md`: Mandatory offline-first design using local DB.
- `09-api-contract-standards.md`: Syncing models with Laravel backend endpoints.
- `10-multi-platform-support.md`: Code compatibility across Android, macOS, and Windows.

## 3. On-Demand Domain Skills (`.agents/skills/`)
- `sollu-client`: Main reference for the POS client architecture.
- `riverpod-development`: State management, caching, Riverpod best practices.
- `drift-database`: SQLite, DAO, and schema migrations.
- `domain-offline-sync`: Queueing, retry mechanisms, resolving conflicts.
- `domain-pos-printing`: Thermal printing over Bluetooth/USB.
- `api-contract-standards`: Shared guide for syncing backend and frontend data.

## 4. Essential Commands & Verification
- **Code Generation:** `flutter pub run build_runner build --delete-conflicting-outputs`
- **Linter:** `flutter analyze`
- **Testing:** `flutter test`

## 5. Scratchpad / Planning / Context & Active Clarification

- Untuk tugas yang memodifikasi lebih dari satu komponen atau melibatkan logika bisnis baru, buat planning/spec artifact terlebih dahulu. Tuliskan asumsi, dependency yang terdampak, dan batasan arsitektur sebelum menghasilkan implementasi.
- Jika ada informasi kritis, API contract, atau edge case yang ambigu, jangan menebak atau mengasumsikan implementasi. Kumpulkan pertanyaan tersebut dalam daftar poin terstruktur dan berikan rekomendasi opsi terbaik untuk dikonfirmasi sebelum melanjutkan. 
