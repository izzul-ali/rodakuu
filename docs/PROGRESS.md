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
| M2  | lulus   | 27 Oktober 2026        | Backend (SQL 0001_init, seed, README); review silang kolom, RPC, enum & batas 30 hari konsisten |
| M3  | lulus   | 27 Oktober 2026        | Auth, router, shell, debug APK terbukti lulus (13.5s) |
| M4  | lulus   | 31 Oktober 2026        | Kendaraan: daftar, filter, detail, tests T-UT-07..08,11 & T-WT-05..09 |
| M5  | lulus   | 31 Oktober 2026        | Pemesanan & riwayat: form, kalkulator, riwayat, detail, pembatalan, debug APK lulus (27.5s) |
| M6  | lulus   | 31 Oktober 2026        | Profil: avatar, lihat profil, ubah profil, keluar; test T-WT-15 lulus, seluruh stub layar tuntas diganti nyata |
| M7  | lulus   | 31 Oktober 2026        | Polesan: audit responsif 6 ukuran x 2 skala teks (T-RS-01 lulus), audit aksesibilitas, audit teks dan anti-AI-slop |
| M8  | lulus   | 31 Oktober 2026        | QA akhir & release build: seluruh 9 skrip audit lulus, debug APK (11.4s) dan release APK (87.7s, 59.6MB) sukses dibangun |

## Keterlacakan FR

| FR         | File implementasi     | Test                   | Status |
| ---------- | --------------------- | ---------------------- | ------ |
| FR-AUTH-01 | lib/features/auth/presentation/screens/register_screen.dart | test/features/auth/register_screen_test.dart | lulus  |
| FR-AUTH-02 | lib/features/auth/presentation/screens/login_screen.dart    | test/features/auth/login_screen_test.dart    | lulus  |
| FR-AUTH-03 | lib/features/auth/data/supabase_auth_repository.dart       | test/features/auth/login_screen_test.dart    | lulus  |
| FR-AUTH-04 | lib/features/shell/main_shell_screen.dart                  | test/features/auth/login_screen_test.dart    | lulus  |
| FR-AUTH-05 | lib/core/router/app_router.dart                            | test/features/auth/login_screen_test.dart    | lulus  |
| FR-VEH-01 | lib/features/vehicles/presentation/widgets/vehicle_card.dart        | test/features/vehicles/vehicle_list_screen_test.dart   | lulus  |
| FR-VEH-02 | lib/features/vehicles/presentation/screens/vehicle_list_screen.dart | test/features/vehicles/vehicle_list_screen_test.dart   | lulus  |
| FR-VEH-03 | lib/features/vehicles/presentation/widgets/vehicle_filter_sheet.dart | test/features/vehicles/vehicle_filter_test.dart        | lulus  |
| FR-VEH-04 | lib/features/vehicles/presentation/widgets/vehicle_filter_sheet.dart | test/features/vehicles/vehicle_filter_test.dart        | lulus  |
| FR-VEH-05 | lib/features/vehicles/presentation/screens/vehicle_list_screen.dart | test/features/vehicles/vehicle_list_screen_test.dart   | lulus  |
| FR-VEH-06 | lib/features/vehicles/presentation/screens/vehicle_detail_screen.dart| test/features/vehicles/vehicle_detail_screen_test.dart | lulus  |
| FR-BKG-01 | lib/features/bookings/presentation/screens/booking_form_screen.dart   | test/features/bookings/booking_form_screen_test.dart    | lulus  |
| FR-BKG-02 | lib/features/bookings/presentation/widgets/date_range_field.dart     | test/features/bookings/booking_form_screen_test.dart    | lulus  |
| FR-BKG-03 | lib/features/bookings/presentation/widgets/price_summary.dart        | test/features/bookings/booking_calculator_test.dart     | lulus  |
| FR-BKG-04 | lib/features/bookings/presentation/providers/booking_form_controller.dart | test/features/bookings/booking_form_screen_test.dart | lulus  |
| FR-BKG-05 | lib/features/bookings/presentation/screens/booking_detail_screen.dart | test/features/bookings/booking_history_screen_test.dart | lulus  |
| FR-BKG-06 | lib/features/bookings/presentation/screens/booking_detail_screen.dart | test/features/bookings/booking_history_screen_test.dart | lulus  |
| FR-HIS-01 | lib/features/bookings/presentation/screens/booking_history_screen.dart| test/features/bookings/booking_history_screen_test.dart | lulus  |
| FR-HIS-02 | lib/features/bookings/presentation/widgets/booking_card.dart          | test/features/bookings/booking_history_screen_test.dart | lulus  |
| FR-PRF-01 | lib/features/profile/presentation/screens/profile_screen.dart         | test/features/profile/edit_profile_screen_test.dart   | lulus  |
| FR-PRF-02 | lib/features/profile/presentation/screens/edit_profile_screen.dart    | test/features/profile/edit_profile_screen_test.dart   | lulus  |
| FR-PRF-03 | lib/features/profile/presentation/screens/profile_screen.dart         | test/features/profile/edit_profile_screen_test.dart   | lulus  |

## Keputusan

- 27 Oktober 2026 — Scaffold project id.rodakuu.rodakuu — Sesuai PRD 12.1.
- 27 Oktober 2026 — Versi paket mengikuti hasil resolusi pub add — Kompatibel Flutter 3.47 dan Dart 3.13.
- 27 Oktober 2026 — Review silang SQL 0001_init.sql & seed.sql — Kolom seed diselaraskan dengan 10 nilai (image_url default null) agar lolos validasi Postgres tanpa syntax error.
- 27 Oktober 2026 — SQL belum dieksekusi ke Supabase karena belum ada kredensial remote dari pengguna.
- 31 Oktober 2026 — Implementasi M6 (Profil) selesai — Semua fitur lihat dan ubah profil serta keluar akun selesai, lulus verifikasi analyzer dan widget test.
- 31 Oktober 2026 — Implementasi M7 (Polesan) selesai — Seluruh 9 layar lulus audit responsif T-RS-01 pada 6 ukuran layar x 2 skala teks (108 varian uji), audit aksesibilitas (seluruh IconButton bertooltip, gambar ber-semantics), dan audit teks UI.
- 31 Oktober 2026 — Implementasi M8 (QA akhir & build) selesai — Format bersih, analyzer 0 issue, 51 test lulus, audit 9 skrip bersih (tanpa pola terlarang, tanpa file yatim, semua layar terdaftar, separasi layer bersih, manifest lengkap), debug APK & release APK sukses terkompilasi.

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

- SQL belum dieksekusi ke backend Supabase nyata karena berkas env.json dan kredensial Supabase remote belum disediakan oleh pengguna (tersedia env.example.json). Aplikasi siap terhubung begitu kredensial diisi.

## Saran lanjutan (di luar lingkup)

- Payment gateway terintegrasi (Midtrans / Xendit).
- Aplikasi manajemen armada terpisah untuk Admin.
- Login sosial (Google / Apple OAuth).
- Notifikasi push (FCM) pembaruan status pesanan.
- Peta / GPS untuk penentuan lokasi penjemputan armada.
- Pagination tak terbatas untuk katalog kendaraan skala besar (> 200 armada).
