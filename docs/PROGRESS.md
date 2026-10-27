# PROGRESS — RodaKuu

## Lingkungan

- Flutter: 3.47.6 • channel stable • revision 5fc346839b
- Dart: 3.13.5
- Java: OpenJDK 17.0.10
- Android SDK: 36.1.0 (all licenses accepted)
- Tanggal mulai: 27 Oktober 2026

## Milestone

| M   | Status  | Gerbang lulus (tanggal) | Catatan |
| --- | ------- | ----------------------- | ------- |
| M0  | lulus   | 27 Oktober 2026        | Scaffold & toolchain; debug APK terbentuk |
| M1  | lulus   | 27 Oktober 2026        | Core (env, error, theme, utils, widgets, tests T-UT-01..04,09,10) |
| M2  | belum   |                         | Backend (SQL) |
| M3  | belum   |                         | Auth, router, shell |
| M4  | belum   |                         | Kendaraan |
| M5  | belum   |                         | Pemesanan & riwayat |
| M6  | belum   |                         | Profil |
| M7  | belum   |                         | Polesan |
| M8  | belum   |                         | QA akhir & release build |

## Keterlacakan FR

| FR         | File implementasi     | Test                   | Status |
| ---------- | --------------------- | ---------------------- | ------ |
| FR-AUTH-01 | lib/features/auth/... | test/features/auth/... | belum  |
| FR-AUTH-02 | lib/features/auth/... | test/features/auth/... | belum  |
| FR-AUTH-03 | lib/features/auth/... | test/features/auth/... | belum  |
| FR-AUTH-04 | lib/features/auth/... | test/features/auth/... | belum  |
| FR-AUTH-05 | lib/core/router/...   | test/features/auth/... | belum  |
| FR-VEH-01 | lib/features/vehicles | test/features/vehicles | belum  |
| FR-VEH-02 | lib/features/vehicles | test/features/vehicles | belum  |
| FR-VEH-03 | lib/features/vehicles | test/features/vehicles | belum  |
| FR-VEH-04 | lib/features/vehicles | test/features/vehicles | belum  |
| FR-VEH-05 | lib/features/vehicles | test/features/vehicles | belum  |
| FR-VEH-06 | lib/features/vehicles | test/features/vehicles | belum  |
| FR-BKG-01 | lib/features/bookings | test/features/bookings | belum  |
| FR-BKG-02 | lib/features/bookings | test/features/bookings | belum  |
| FR-BKG-03 | lib/features/bookings | test/features/bookings | belum  |
| FR-BKG-04 | lib/features/bookings | test/features/bookings | belum  |
| FR-BKG-05 | lib/features/bookings | test/features/bookings | belum  |
| FR-BKG-06 | lib/features/bookings | test/features/bookings | belum  |
| FR-HIS-01 | lib/features/bookings | test/features/bookings | belum  |
| FR-HIS-02 | lib/features/bookings | test/features/bookings | belum  |
| FR-PRF-01 | lib/features/profile  | test/features/profile  | belum  |
| FR-PRF-02 | lib/features/profile  | test/features/profile  | belum  |
| FR-PRF-03 | lib/features/profile  | test/features/profile  | belum  |

## Keputusan

- 27 Oktober 2026 — Scaffold project id.rodakuu.rodakuu — Sesuai PRD 12.1.
- 27 Oktober 2026 — Versi paket mengikuti hasil resolusi pub add — Kompatibel Flutter 3.47 dan Dart 3.13.

## Versi paket terpasang (hasil flutter pub add)

- material_ui: 1.8.0
- supabase_flutter: 2.18.3
- flutter_riverpod: 3.4.3
- riverpod: 3.4.3
- go_router: 18.1.1
- google_fonts: 9.0.0
- cached_network_image: 4.0.5
- intl: 0.20.3
- flutter_lints: 6.0.0

## Hambatan

- Tidak ada.

## Saran lanjutan (di luar lingkup)

- Belum ada.
