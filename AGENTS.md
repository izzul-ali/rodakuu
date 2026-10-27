---
name: rodakuu-implementation
description: Panduan eksekusi bertahap untuk mengimplementasikan PRD aplikasi Android RodaKuu (Flutter 3.47.x, Supabase, Riverpod 3) sampai APK dapat dijalankan tanpa error. Gunakan saat diminta membangun, melanjutkan, memperbaiki, atau memverifikasi proyek RodaKuu.
---

# SKILL — Implementasi RodaKuu

Skill ini mengarahkan AI Agent mengeksekusi `docs/PRD.md` **sampai tuntas**: semua fitur lengkap, tidak ada import/file/fitur yang terlewat, tidak ada API karangan, dan APK dapat dibangun serta dijalankan tanpa error.

**Pembagian peran dokumen:** PRD menentukan _apa_ yang dibangun. Skill ini menentukan _bagaimana_ mengerjakannya. Jika keduanya bertentangan atau PRD ambigu pada hal yang mengubah hasil, catat di `docs/PROGRESS.md` bagian "Keputusan" beserta alasan, pilih opsi paling sederhana yang memenuhi acceptance criteria, lalu lanjut.

---

## 1. Aturan Emas (tidak bisa ditawar)

1. **Baca seluruh `docs/PRD.md` sebelum menulis satu baris kode.** Bagian 4 (FR), 6.2 (catatan kritis), 7 (arsitektur), 8–9 (database dan integrasi), 10 (UI) wajib dipahami.
2. **Kerjakan per milestone (bagian 5), berurutan.** Jangan mulai milestone berikutnya sebelum gerbang (gate) milestone saat ini lulus dengan output perintah nyata.
3. **Tulis file secara utuh.** Dilarang `// ...`, "sisanya sama", "implementasi serupa", atau kerangka kosong. Setiap file yang disebut di PRD 7.3 harus berisi kode lengkap dan terpakai.
4. **Jangan mengarang API.** Nama class, method, parameter, dan tipe milik pustaka harus ditemukan di source paket terpasang atau dokumentasi resmi (bagian 2). Ingatan Anda adalah sumber kebenaran **paling rendah**.
5. **Analyzer, test, dan build adalah hakim.** Klaim "sudah benar" tanpa output perintah tidak diterima.
6. **Tidak ada pekerjaan tersembunyi.** Dilarang `TODO`, `FIXME`, data dummy di UI, fitur setengah jadi, `catch` kosong, atau fallback yang menyembunyikan error.
7. **Jangan menambah fitur di luar PRD (PRD 2.2).** Ide tambahan masuk "Saran lanjutan" di `PROGRESS.md`.
8. **Laporan harus jujur.** Pisahkan dengan tegas apa yang _terbukti_ (ada output perintah) dan apa yang _belum diverifikasi_ (mis. backend nyata tanpa `env.json`). Dilarang menulis "seharusnya berjalan".
9. **Jangan mengubah hal yang bukan milik Anda:** versi AGP/Kotlin/Gradle dan `compileSdk/targetSdk/minSdk` dari template `flutter create`, serta `pubspec.lock` secara manual.
10. **Jika benar-benar terblokir oleh lingkungan** (tidak ada SDK, tidak ada jaringan, tidak ada kredensial), berhenti di titik itu, selesaikan semua yang bisa diselesaikan, dan laporkan hambatan dengan tepat. Jangan memalsukan keberhasilan.

---

## 2. Hierarki Sumber Kebenaran dan Protokol Anti-Halusinasi

Urutan dipercaya (atas = paling kuat):

1. Output compiler/analyzer/test/build di mesin ini.
2. **Source paket terpasang** di pub cache.
3. Dokumentasi resmi: `pub.dev/documentation/<paket>/latest/`, `docs.flutter.dev`, `supabase.com/docs`.
4. Potongan kode di PRD (pola acuan, tetap diverifikasi terhadap 1–3).
5. Ingatan model. **Tidak boleh dipakai sendirian untuk signature API.**

### 2.1 Menemukan source paket terpasang

Setelah `flutter pub get`:

```bash
python3 - <<'EOF'
import json
cfg = json.load(open('.dart_tool/package_config.json'))
wanted = {'supabase_flutter','supabase','postgrest','gotrue','flutter_riverpod','riverpod',
          'go_router','material_ui','google_fonts','cached_network_image','intl'}
for p in cfg['packages']:
    if p['name'] in wanted:
        print(p['name'], '->', p['rootUri'])
EOF
```

Lalu cari simbol langsung di source:

```bash
grep -rn "class ProviderScope" <path-flutter_riverpod>/lib | head
grep -rn "retry" <path-flutter_riverpod>/lib/src --include=*.dart | head
grep -rn "publishableKey" <path-supabase_flutter>/lib | head
grep -rn "class StatefulShellRoute" <path-go_router>/lib | head
```

### 2.2 Wajib verifikasi sebelum dipakai (daftar titik rawan)

| Hal                                                                                                                                                                                                    | Cek di                                                           |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ---------------------------------------------------------------- |
| Parameter `ProviderScope(retry: …)` dan tipe `Override` (mungkin perlu `package:flutter_riverpod/misc.dart`)                                                                                           | source `flutter_riverpod`                                        |
| Ada tidaknya `ref.mounted` pada `Notifier`                                                                                                                                                             | source `riverpod`                                                |
| `Supabase.initialize(url:, publishableKey:)`                                                                                                                                                           | source `supabase_flutter`                                        |
| Tipe exception: `AuthException` (+ field `code`/`statusCode`), `AuthRetryableFetchException`, `PostgrestException` (`code`, `message`)                                                                 | source `gotrue`, `postgrest`                                     |
| Bentuk hasil `rpc(...)` untuk fungsi yang `returns public.bookings` (Map atau List)                                                                                                                    | uji nyata bila ada backend; kode parsing harus menerima keduanya |
| `PostgrestFilterBuilder` vs `PostgrestTransformBuilder` (urutan `.eq`/`.order`/`.limit`)                                                                                                               | source `postgrest`                                               |
| Nama tipe tema: `CardThemeData`, `DialogThemeData`, `AppBarTheme`/`AppBarThemeData`, `InputDecorationTheme`/`InputDecorationThemeData`, `NavigationBarThemeData`, `ChipThemeData`, `SnackBarThemeData` | source `material_ui` / pesan analyzer                            |
| `GlobalMaterialLocalizations.delegates`                                                                                                                                                                | source `material_ui`                                             |
| `StatefulShellRoute.indexedStack`, `goBranch`, `GoRouterState.pathParameters`                                                                                                                          | source `go_router`                                               |
| `GoogleFonts.plusJakartaSansTextTheme`                                                                                                                                                                 | source `google_fonts`                                            |
| `CachedNetworkImage` (parameter `imageUrl`, `placeholder`, `errorWidget`, `fit`)                                                                                                                       | source `cached_network_image`                                    |

### 2.3 Jika masih ragu

1. Cari di source/dokumentasi (maksimal 2 percobaan pencarian berbeda).
2. Pilih API paling sederhana yang **sudah terbukti ada**.
3. Jangan menambahkan parameter "yang kira-kira ada". Biarkan analyzer memutuskan.

---

## 3. Pra-Pemeriksaan (Preflight) — lakukan sebelum M0

```bash
flutter --version          # harus 3.47.x dan Dart 3.13.x
flutter doctor -v          # Android toolchain harus ✓
java -version              # harus 17
```

Keputusan:
| Temuan | Tindakan |
|---|---|
| Flutter bukan 3.47.x | Hentikan dan laporkan. Sarankan instal 3.47.x lewat arsip resmi atau FVM (`fvm install 3.47.6`). Jangan lanjut dengan versi lain tanpa persetujuan. |
| Flutter 3.47.x tetapi patch ≠ 3.47.6 | Lanjut, catat patch sebenarnya di `PROGRESS.md`. |
| Java bukan 17 / Android SDK tidak ada | Perbaiki lewat `flutter config --jdk-dir …` / `--android-sdk …` atau laporkan sebagai hambatan lingkungan. |
| Lisensi Android belum diterima | `flutter doctor --android-licenses`. |
| Tidak ada akses jaringan ke Maven/pub | Laporkan hambatan. Kerjakan semua kode, tetapi nyatakan build belum terbukti. |
| `env.json` tidak ada | Normal. Lanjut. Backend nyata tidak dapat diuji (lihat bagian 10). |

Catat hasil preflight di `docs/PROGRESS.md`.

---

## 4. Cara Kerja

### 4.1 Task list

Buat satu task per milestone (M0–M8) dan sub-task per fitur di dalamnya. Tandai selesai **hanya** setelah gerbangnya lulus.

### 4.2 Siklus per file (loop kecil)

1. Tentukan path dan tanggung jawab file dari PRD 7.3/7.4.
2. Tulis file **utuh** (semua import, semua class).
3. Jalankan `flutter analyze`. Perbaiki **semua** temuan (error, warning, info) sebelum file berikutnya.
4. Setelah satu fitur selesai: tulis test-nya, jalankan `flutter test <berkas>`.
5. Setelah milestone selesai: jalankan gerbangnya (bagian 5), lalu commit (`feat(<scope>): …`).

Ritme verifikasi: `flutter analyze` setelah setiap file, `flutter test` setiap fitur, `flutter build apk --debug` pada akhir M0, M3, M5, dan M8, serta setiap kali `pubspec.yaml`, manifest, atau konfigurasi Gradle berubah.

### 4.3 Berkas `docs/PROGRESS.md` (wajib dipelihara)

Agar pekerjaan bisa dilanjutkan oleh sesi/agent lain tanpa mengulang. Buat di M0 dengan templat:

```markdown
# PROGRESS — RodaKuu

## Lingkungan

- Flutter: <hasil flutter --version>
- Dart: <…>
- Java: <…>
- Tanggal mulai: <…>

## Milestone

| M   | Status | Gerbang lulus (tanggal) | Catatan |
| --- | ------ | ----------------------- | ------- |
| M0  | belum  |                         |         |
| …   |        |                         |         |

## Keterlacakan FR

| FR         | File implementasi     | Test                   | Status |
| ---------- | --------------------- | ---------------------- | ------ |
| FR-AUTH-01 | lib/features/auth/... | test/features/auth/... | belum  |
| …          |                       |                        |        |

## Keputusan

- <tanggal> — <keputusan> — <alasan>

## Versi paket terpasang (hasil flutter pub add)

- material_ui: …
- …

## Hambatan

- <…>

## Saran lanjutan (di luar lingkup)

- <…>
```

Perbarui setelah setiap milestone.

### 4.4 Keputusan saat PRD ambigu

Pilih opsi paling sederhana yang memenuhi acceptance criteria, catat di "Keputusan". **Bertanya ke pengguna hanya** untuk: kredensial Supabase, persetujuan mengubah versi Flutter, atau hal yang tidak mungkin diputuskan sendiri.

---

## 5. Milestone, Gerbang, dan Kriteria Lulus

### M0 — Scaffold dan toolchain

**Aksi**

1. `flutter create --org id.rodakuu --project-name rodakuu --platforms=android .`
2. `flutter pub add material_ui supabase_flutter flutter_riverpod go_router google_fonts cached_network_image intl` lalu cocokkan hasilnya dengan PRD 6.1 (catat versi aktual di `PROGRESS.md`). Sesuaikan `environment.sdk` dengan Dart sebenarnya.
3. Susun `pubspec.yaml` sesuai PRD 12.2 (name, description, version, `publish_to`).
4. Buat `analysis_options.yaml` (PRD 12.5), tambah `.gitignore` (PRD 12.6), `env.example.json` (PRD 12.3).
5. `AndroidManifest.xml`: tambah izin INTERNET sebelum `<application>` dan set label `RodaKuu` (PRD 12.4).
6. **Hapus** template: isi `lib/main.dart` diganti stub minimal berbasis `material_ui`, hapus `test/widget_test.dart`.
7. Pindahkan PRD ke `docs/PRD.md` bila belum, buat `docs/PROGRESS.md`, dan buat `docs/expected_files.txt` berisi **semua path file** dari pohon PRD 7.3 (satu path per baris, relatif dari root repo, hanya file bukan folder).
8. `git init` bila belum ada repo dan commit awal.

**Gerbang G0**

```bash
flutter pub get
flutter analyze
flutter build apk --debug
```

Lulus bila: analyzer bersih dan APK debug terbentuk. Gerbang ini sengaja dini untuk menangkap masalah toolchain Gradle/JDK sebelum ada kode.

### M1 — Core

**File:** semua di `lib/core/**`, `lib/bootstrap.dart`, `lib/app.dart`, `lib/main.dart` (PRD 7.3).

**Spesifikasi kunci**

- `AppEnv`: `String.fromEnvironment('SUPABASE_URL')` dan `('SUPABASE_PUBLISHABLE_KEY')`, getter `isConfigured`.
- `AppConstants`: `maxRentalDays = 30`, `priceFilterMin = 0`, `priceFilterMax = 1000000`, `priceFilterStep = 10000`, `searchDebounce = Duration(milliseconds: 400)`, `vehicleQueryLimit = 200`, `bookingQueryLimit = 100`, `notesMaxLength = 200`.
- `AppFailure` (sealed) dan `mapToFailure`/`failureMessage` sesuai PRD 7.8 dan 9.5.
- Tema (PRD 10.3): `AppColors`, `AppSpacing` (termasuk `screenHorizontal = 20`, `screenHorizontalCompact = 16`, radius), `AppTypography`, `AppTheme.light({bool useGoogleFonts = true})`.
- `formatters.dart`: `formatRupiah(int)`, `formatDate(DateTime)` (`d MMM yyyy`, locale `id_ID`), `formatDateRange(DateTime, DateTime)`, `toDateOnlyString(DateTime)` (`yyyy-MM-dd` dirakit manual dengan `padLeft`, tanpa locale).
- `validators.dart`: `Validators.email`, `password`, `confirmPassword`, `fullName`, `phone` (opsional), `required`/`pickupLocation`. Mengembalikan `String?` berbahasa Indonesia.
- `enum_parser.dart`, `responsive.dart` (extension `BuildContext`: `screenWidth`, `screenHorizontalPadding`), `debouncer.dart`.
- Widget generik: `AppButton` (varian primer/sekunder/teks + `isLoading`), `AppTextField`, `AppLoading`, `AppEmptyView`, `AppErrorView`, `AppLogo`, `ResponsiveCenter`, `NotFoundScreen`, `ConfigErrorView` + `ConfigErrorApp`.
- `bootstrap.dart` dan `app.dart` sesuai pola bagian 6 (termasuk clamp skala teks, lokalisasi `id_ID`, `themeMode: ThemeMode.light`).

**Test:** `validators_test.dart` (T-UT-01..03), `formatters_test.dart` (T-UT-04), `error_mapper_test.dart` (T-UT-09, T-UT-10).

**Gerbang G1:** `dart format .`, `flutter analyze`, `flutter test` lulus.

### M2 — Backend (SQL)

**Aksi:** salin SQL dari PRD 8.3 dan 8.4 **apa adanya** ke `supabase/migrations/0001_init.sql` dan `supabase/seed.sql`. Tambahkan `supabase/README.md` berisi langkah setup (PRD 8.2).

**Gerbang G2 (review silang, tanpa eksekusi):** centang satu per satu dan catat di `PROGRESS.md`:

- Nama tabel/kolom di SQL = nama kolom di DTO dan query Dart (`price_per_day`, `image_url`, `is_available`, `start_date`, `end_date`, `total_days`, `total_price`, `pickup_location`, `status`, `created_at`, `vehicle_id`, `user_id`).
- Nama RPC dan parameter di SQL = di repository (`create_booking(p_vehicle_id, p_start_date, p_end_date, p_pickup_location, p_notes)`, `cancel_booking(p_booking_id)`, `get_booked_ranges(p_vehicle_id)`).
- Nilai enum Dart = nilai `check` di SQL.
- Batas 30 hari konsisten di SQL, `AppConstants.maxRentalDays`, dan `BookingCalculator`.
- Bila Anda memiliki akses `psql`/proyek Supabase dari pengguna, jalankan SQL dan catat hasilnya. Bila tidak, tulis "SQL belum dieksekusi" di laporan akhir.

### M3 — Auth, router, shell

**File:** `lib/features/auth/**`, `lib/core/router/**`, `lib/features/shell/main_shell_screen.dart`, plus stub layar kosong **sementara** untuk rute yang belum dibuat. Stub harus diganti nyata pada M4–M6 (lihat checklist akhir).

**Spesifikasi kunci**

- `AuthRepository` (domain): `String? get currentUserId`, `Stream<String?> get userIdChanges`, `Future<void> signIn({required String email, required String password})`, `Future<SignUpResult> signUp({required String fullName, required String email, required String password})`, `Future<void> signOut()`. `enum SignUpResult { signedIn, needsEmailVerification }`.
- Implementasi Supabase memetakan `onAuthStateChange` → `session?.user.id` dengan `.distinct()`.
- `currentUserIdProvider` = `NotifierProvider<CurrentUserIdNotifier, String?>`.
- `LoginController`/`RegisterController` = `AsyncNotifier<void>` (pola 6.4).
- `routerProvider`, redirect, `StatefulShellRoute.indexedStack`, `errorBuilder` (pola 6.3 dan PRD 11).
- `MainShellScreen`: `NavigationBar` 3 tujuan (Beranda, Pesanan, Profil) dengan ikon Material rounded.
- `LoginScreen`, `RegisterScreen`: validasi inline, loading, error via `ref.listen` + SnackBar, toggle visibilitas kata sandi (dengan `tooltip`), `textInputAction`, `autofillHints`.

**Test:** `login_screen_test.dart` (T-WT-01, 02), `register_screen_test.dart` (T-WT-03, 04).

**Gerbang G3:** format, analyze, test, dan `flutter build apk --debug` lulus.

### M4 — Kendaraan

**File:** `lib/features/vehicles/**` lengkap.

**Spesifikasi kunci**

- `Vehicle`, enum `VehicleType`/`Transmission`/`FuelType`, `VehicleFilter` (`query`, `type`, `transmission`, `minPrice`, `maxPrice`, `onlyAvailable`, `sort`; `==`/`hashCode` via `Object.hash`; `copyWith` yang bisa mengosongkan field nullable, mis. parameter bertipe `T? Function()?`; getter `activeFilterCount` yang menghitung transmisi, harga ≠ default, dan onlyAvailable, **tanpa** jenis dan sort).
- Query PostgREST sesuai PRD 9.3 (filter dulu, `.order` terakhir, sanitasi keyword, jangan `.lte` bila `maxPrice == priceFilterMax`).
- `vehicleListProvider` (`FutureProvider.autoDispose`) me-`watch` `vehicleFilterProvider`.
- `VehicleListScreen`: sapaan nama depan dari `profileProvider` (jika belum termuat, tampilkan "Halo" saja, jangan blok layar), kolom cari dengan debounce, tombol Filter + badge, chip jenis, daftar `VehicleCard` dalam `ResponsiveCenter`, skeleton, kosong, error, pull-to-refresh.
- `VehicleFilterSheet`: transmisi, `RangeSlider`, switch, sort, tombol Terapkan/Reset. State draft lokal, baru ditulis ke provider saat Terapkan.
- `VehicleDetailScreen` + `SpecItem` + bar bawah tetap.
- `VehicleImage`: `CachedNetworkImage` bila `imageUrl` ada, placeholder `navy50` + ikon kendaraan bila null/gagal.

**Test:** `vehicle_dto_test`, `vehicle_filter_test`, `vehicle_list_screen_test`, `vehicle_detail_screen_test` (T-UT-07, 08, 11; T-WT-05..09).

**Gerbang G4:** format, analyze, test lulus.

### M5 — Pemesanan dan riwayat

**File:** `lib/features/bookings/**` lengkap.

**Spesifikasi kunci**

- `BookingCalculator.totalDays(DateTime start, DateTime end)` memakai `DateTime.utc(y,m,d)` untuk selisih hari **inklusif** (hindari efek jam/zona). `totalPrice(int pricePerDay, int days)`.
- `Booking` (id, vehicleId, startDate, endDate, totalDays, pricePerDay, totalPrice, pickupLocation, notes, status, createdAt, `BookingVehicle? vehicle`), `BookingStatus`, `BookedRange`, `BookingRequest`.
- `BookingDto.fromJson` menangani embed `vehicle` (boleh null) dan tanggal `yyyy-MM-dd`.
- Repository: `createBooking` (mengembalikan `String` id; terima `Map` maupun `List` berisi 1 `Map`), `getMyBookings`, `getBooking`, `cancelBooking`, `getBookedRanges`.
- `BookingFormScreen`: ringkasan kendaraan, `DateRangeField` (picker, `firstDate` hari ini, `lastDate` +365 hari, validasi maks 30 hari dan tabrakan dengan `bookedRangesProvider`), lokasi, catatan (maks 200 + counter), `PriceSummary`, bar bawah tetap dengan tombol "Buat Pesanan" (nonaktif + loading). Sukses → `ref.invalidate(myBookingsProvider)` lalu `context.go(AppRoutes.bookingDetail(id))` + SnackBar.
- `BookingHistoryScreen`: `SegmentedButton` Aktif/Selesai, filter di klien, skeleton/kosong/error/pull-to-refresh.
- `BookingDetailScreen`: semua blok PRD 10.4, tombol "Batalkan Pesanan" hanya bila `menunggu`, dialog konfirmasi, `CancelBookingController`, invalidate `bookingDetailProvider(id)` dan `myBookingsProvider`.
- `BookingStatusChip`: warna dan label PRD 10.3.

**Test:** `booking_calculator_test`, `booking_dto_test`, `booking_form_screen_test`, `booking_history_screen_test` (T-UT-05, 06, 12; T-WT-10..14).

**Gerbang G5:** format, analyze, test, dan `flutter build apk --debug` lulus.

### M6 — Profil

**File:** `lib/features/profile/**` lengkap.

**Spesifikasi kunci**

- `Profile` (id, fullName, phone?, email). Email diambil di data layer dari user auth saat ini.
- `profileProvider` (`FutureProvider.autoDispose`, me-`watch` `currentUserIdProvider`).
- `ProfileScreen`: avatar inisial (huruf pertama dua kata pertama, huruf besar), nama, email, telepon, menu "Ubah profil" dan "Keluar" (dialog konfirmasi → `signOut`).
- `EditProfileScreen` + `EditProfileController`: validasi, simpan, invalidate `profileProvider`, kembali dengan SnackBar "Profil diperbarui."

**Test:** `edit_profile_screen_test` (T-WT-15).

**Gerbang G6:** format, analyze, test lulus. Pada titik ini **tidak boleh tersisa stub layar sementara**.

### M7 — Polesan

1. Ganti semua stub (jika ada) dengan layar nyata. Cek bahwa setiap `*Screen` terdaftar di router (bagian 9, skrip 6).
2. Audit teks: semua teks UI berbahasa Indonesia, tanpa emoji, sapaan "Anda", sesuai tabel PRD 10.7.
3. Audit responsif: tulis `test/responsive/responsive_layout_test.dart` (T-RS-01) yang merender setiap layar utama (Masuk, Daftar, Beranda, Detail kendaraan, Form pemesanan, Riwayat, Detail pesanan, Profil, Ubah profil) dengan fake repository pada 320×568, 360×640, 393×852, 412×915, 600×960, 852×393, masing-masing dengan skala teks 1.0 dan 1.3, lalu memastikan `tester.takeException()` bernilai null.
4. Audit aksesibilitas: `tooltip` pada semua `IconButton`, `semanticLabel` gambar, target sentuh ≥ 48 dp.
5. Audit deprecated: `flutter analyze` harus 0 issue (termasuk info deprecated).
6. Audit UI "anti-AI-slop" terhadap tabel PRD 10.2 (tanpa gradasi, glass, emoji, radius di luar skala).

**Gerbang G7:** format, analyze, seluruh `flutter test` lulus (termasuk T-RS-01).

### M8 — QA akhir dan build

1. Jalankan **audit akhir** (bagian 9) sampai bersih.
2. `flutter build apk --debug` dan `flutter build apk --release` (dengan `--dart-define-from-file=env.json` bila file ada; bila tidak, tanpa flag dan catat).
3. Jalankan di emulator/perangkat bila tersedia. Tanpa `env.json`, verifikasi bahwa `ConfigErrorView` tampil dan tidak crash. Dengan `env.json` dan SQL sudah dijalankan, jalankan **skrip UAT PRD 13.3** dan catat hasil tiap langkah.
4. Lengkapi tabel keterlacakan FR di `PROGRESS.md` (setiap FR → file → test → status).
5. Laporan akhir (bagian 10).

**Gerbang G8 = seluruh DoD PRD bagian 14.**

---

## 6. Pola Kode Baku

Pola berikut adalah titik awal yang sudah dirancang untuk Flutter 3.47 + Riverpod 3. Verifikasi API-nya sesuai bagian 2. Semua file memakai `import 'package:material_ui/material_ui.dart';` untuk widget/tema, **bukan** `flutter/material.dart`.

### 6.1 `lib/bootstrap.dart`

```dart
import 'dart:ui';

import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:rodakuu/app.dart';
import 'package:rodakuu/core/config/app_env.dart';
import 'package:rodakuu/core/widgets/config_error_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  PlatformDispatcher.instance.onError = (error, stack) {
    if (kDebugMode) {
      debugPrint('Kesalahan tak tertangani: $error');
    }
    return true;
  };

  if (!AppEnv.isConfigured) {
    runApp(const ConfigErrorApp());
    return;
  }

  await initializeDateFormatting('id_ID');
  await Supabase.initialize(
    url: AppEnv.supabaseUrl,
    publishableKey: AppEnv.supabasePublishableKey,
  );

  runApp(
    ProviderScope(
      // Error langsung ditampilkan; pengguna memakai tombol "Coba lagi".
      retry: (retryCount, error) => null,
      child: const RodaKuuApp(),
    ),
  );
}
```

`lib/main.dart`:

```dart
import 'package:rodakuu/bootstrap.dart';

Future<void> main() => bootstrap();
```

### 6.2 `lib/app.dart` (inti)

```dart
class RodaKuuApp extends ConsumerWidget {
  const RodaKuuApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'RodaKuu',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      themeMode: ThemeMode.light,
      routerConfig: router,
      locale: const Locale('id', 'ID'),
      supportedLocales: const [Locale('id', 'ID')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      builder: (context, child) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            textScaler: media.textScaler.clamp(minScaleFactor: 0.85, maxScaleFactor: 1.3),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
```

### 6.3 Router (inti)

```dart
final rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.read(authRepositoryProvider);
  final refresh = AuthRefreshNotifier(auth.userIdChanges);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.home,
    refreshListenable: refresh,
    redirect: (context, state) {
      final loggedIn = auth.currentUserId != null;
      final location = state.matchedLocation;
      final atAuth = location == AppRoutes.login || location == AppRoutes.register;
      if (!loggedIn && !atAuth) return AppRoutes.login;
      if (loggedIn && atAuth) return AppRoutes.home;
      return null;
    },
    errorBuilder: (context, state) => const NotFoundScreen(),
    routes: [
      GoRoute(path: AppRoutes.login, builder: (context, state) => const LoginScreen()),
      GoRoute(path: AppRoutes.register, builder: (context, state) => const RegisterScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => MainShellScreen(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: AppRoutes.home, builder: (context, state) => const VehicleListScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.bookings,
              builder: (context, state) => const BookingHistoryScreen(),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (context, state) =>
                      BookingDetailScreen(bookingId: state.pathParameters['id']!),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.profile,
              builder: (context, state) => const ProfileScreen(),
              routes: [
                GoRoute(path: 'ubah', builder: (context, state) => const EditProfileScreen()),
              ],
            ),
          ]),
        ],
      ),
      GoRoute(
        path: '/kendaraan/:id',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) =>
            VehicleDetailScreen(vehicleId: state.pathParameters['id']!),
        routes: [
          GoRoute(
            path: 'pesan',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) =>
                BookingFormScreen(vehicleId: state.pathParameters['id']!),
          ),
        ],
      ),
    ],
  );
});
```

`NotFoundScreen` (`lib/core/widgets/not_found_screen.dart`, sudah ada di pohon PRD 7.3) adalah layar sederhana: judul "Halaman tidak ditemukan", satu kalimat penjelasan, dan tombol "Kembali ke Beranda" yang memanggil `context.go(AppRoutes.home)`.

`AuthRefreshNotifier`:

```dart
class AuthRefreshNotifier extends ChangeNotifier {
  AuthRefreshNotifier(Stream<String?> userIdChanges) {
    _subscription = userIdChanges.listen((_) => notifyListeners());
  }

  late final StreamSubscription<String?> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
```

(`import 'dart:async';` dan `import 'package:flutter/foundation.dart';`.)

### 6.4 Repository + pemetaan error (pola)

```dart
class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client);
  final SupabaseClient _client;

  @override
  String? get currentUserId => _client.auth.currentSession?.user.id;

  @override
  Stream<String?> get userIdChanges =>
      _client.auth.onAuthStateChange.map((state) => state.session?.user.id).distinct();

  @override
  Future<void> signIn({required String email, required String password}) async {
    try {
      await _client.auth.signInWithPassword(email: email, password: password);
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(mapToFailure(error), stackTrace);
    }
  }
  // signUp dan signOut dengan pola yang sama.
}
```

### 6.5 Controller aksi (pola)

```dart
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  /// Mengembalikan true bila berhasil.
  Future<bool> signIn({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signIn(email: email.trim(), password: password),
    );
    return !state.hasError;
  }
}

final loginControllerProvider =
    AsyncNotifierProvider.autoDispose<LoginController, void>(LoginController.new);
```

Di screen: `ref.listen(loginControllerProvider, (previous, next) { if (next is AsyncError) { tampilkan SnackBar(failureMessage(next.error)); } });` dan `final isLoading = ref.watch(loginControllerProvider).isLoading;`.

Jika versi Riverpod terpasang menyediakan `ref.mounted`, cek `if (!ref.mounted) return …;` setelah `await` pada controller yang bisa di-dispose saat layar ditutup.

### 6.6 Menampilkan `AsyncValue` (pola)

```dart
final vehicles = ref.watch(vehicleListProvider);

return RefreshIndicator(
  onRefresh: () async {
    ref.invalidate(vehicleListProvider);
    try {
      await ref.read(vehicleListProvider.future);
    } on Object {
      // Error sudah ditampilkan oleh state provider; tidak perlu dilempar ke indikator.
    }
  },
  child: switch (vehicles) {
    AsyncData(:final value) when value.isEmpty => EmptyState(...),
    AsyncData(:final value) => VehicleListView(vehicles: value),
    AsyncError(:final error) => AppErrorView(
        message: failureMessage(error),
        onRetry: () => ref.invalidate(vehicleListProvider),
      ),
    _ => const VehicleListSkeleton(),
  },
);
```

`RefreshIndicator` membutuhkan child yang dapat di-scroll. Untuk state kosong/error, bungkus dalam `ListView` (physics `AlwaysScrollableScrollPhysics`) agar tarik-untuk-muat-ulang tetap bekerja.

### 6.7 Lebar konten responsif

```dart
class ResponsiveCenter extends StatelessWidget {
  const ResponsiveCenter({super.key, required this.child, this.maxWidth = 640});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
```

### 6.8 Helper test

```dart
Future<void> pumpApp(
  WidgetTester tester,
  Widget child, {
  List<Override> overrides = const [],
  Size size = const Size(393, 852),
  double textScale = 1.0,
}) async {
  tester.view.devicePixelRatio = 3;
  tester.view.physicalSize = Size(size.width * 3, size.height * 3);
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        theme: AppTheme.light(useGoogleFonts: false),
        locale: const Locale('id', 'ID'),
        supportedLocales: const [Locale('id', 'ID')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: child,
      ),
    ),
  );
  await tester.pump();
}
```

Fake repository ditulis tangan di `test/helpers/fakes.dart` (mis. `FakeVehicleRepository` dengan `Future<List<Vehicle>> Function(VehicleFilter)? onGetVehicles`, yang juga mencatat argumen pemanggilan).

---

## 7. Checklist Anti-Terlewat

### 7.1 Per file Dart

- [ ] Semua import ada dan terpakai; tidak ada `flutter/material.dart` atau `flutter/cupertino.dart`.
- [ ] Tidak ada `print`, `TODO`, `FIXME`, kode yang di-comment, dan `// ignore:` tanpa alasan.
- [ ] `const` dipakai di mana mungkin.
- [ ] Tidak ada angka/teks ajaib berulang.
- [ ] Tidak lebih dari ~300 baris; satu class publik per file.
- [ ] `flutter analyze` bersih setelah file ini.

### 7.2 Per layar

- [ ] Rute terdaftar di `app_router.dart` dan dapat dicapai dari UI.
- [ ] State **loading, data, kosong, error** semuanya ditangani (bila ada pengambilan data).
- [ ] Teks Indonesia, tanpa emoji; mengikuti tabel microcopy PRD 10.7.
- [ ] Responsif: tanpa lebar hardcode, `SafeArea`, scrollable bila ada form, `ResponsiveCenter`.
- [ ] Semua `TextEditingController`/`FocusNode`/`Timer` di-dispose.
- [ ] Setelah `await`: `if (!context.mounted) return;` sebelum memakai `context`.
- [ ] `IconButton` punya `tooltip`; target sentuh ≥ 48 dp.
- [ ] Tombol aksi nonaktif + indikator saat loading (tidak bisa dobel-submit).
- [ ] Tidak ada logika bisnis atau akses data langsung di widget.

### 7.3 Per repository

- [ ] Interface di `domain`, implementasi di `data`, DTO terpisah.
- [ ] Semua panggilan dibungkus `try/catch` → `Error.throwWithStackTrace(mapToFailure(e), st)`.
- [ ] `maybeSingle()` null → `NotFoundFailure` berpesan Indonesia.
- [ ] Nama tabel/kolom/RPC sama persis dengan SQL.
- [ ] Ada unit test parsing DTO.

### 7.4 Per provider

- [ ] Tipe provider sesuai tabel PRD 7.7 (tanpa provider legacy).
- [ ] Provider data per-pengguna me-`watch` `currentUserIdProvider`.
- [ ] Aksi yang mengubah data meng-`invalidate` provider terkait.
- [ ] `ref.read` hanya di callback; `ref.watch` di build.

### 7.5 Per fitur (definisi selesai)

- [ ] Semua FR fitur tsb. memenuhi acceptance criteria PRD.
- [ ] Test fitur ada dan lulus.
- [ ] Baris keterlacakan FR di `PROGRESS.md` terisi.
- [ ] Tidak ada stub tersisa.

---

## 8. Jebakan Umum (sudah diketahui, hindari sejak awal)

| Jebakan                                                                                     | Penanganan                                                                                                      |
| ------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------- |
| Mencampur `flutter/material.dart` dan `material_ui`                                         | Hanya `material_ui`. Template `flutter create` harus dibersihkan.                                               |
| `StateProvider`/`StateNotifierProvider` (legacy di Riverpod 3)                              | Gunakan `NotifierProvider`.                                                                                     |
| Retry otomatis Riverpod 3 membuat loading lama saat error                                   | `ProviderScope(retry: …)` mengembalikan `null` (6.1).                                                           |
| APK release tanpa izin INTERNET                                                             | Manifest utama harus berisi izin (M0 langkah 5).                                                                |
| `ref.watch(authProvider)` di dalam `routerProvider`                                         | Gunakan `ref.read` + `refreshListenable` (6.3). Jika tidak, router dibuat ulang terus-menerus.                  |
| `.order()` sebelum `.eq()` pada query PostgREST                                             | Terapkan semua filter dulu, `.order()`/`.limit()` terakhir.                                                     |
| Karakter `, ( ) % *` di keyword pencarian merusak `.or()`                                   | Sanitasi keyword (PRD 9.3).                                                                                     |
| Tanggal bergeser satu hari                                                                  | Kirim `yyyy-MM-dd` lewat `toDateOnlyString`; hitung selisih dengan `DateTime.utc`.                              |
| `rpc` mengembalikan `Map` atau `List`                                                       | Parser menerima keduanya.                                                                                       |
| `single()` melempar `PGRST116` bila 0 baris                                                 | Pakai `maybeSingle()`.                                                                                          |
| Rupiah memakai spasi non-breaking di test                                                   | Normalisasi `\u00A0` sebelum membandingkan.                                                                     |
| `google_fonts` mencoba mengunduh font saat test                                             | Test memakai `AppTheme.light(useGoogleFonts: false)`.                                                           |
| Skala teks besar membuat overflow                                                           | Clamp skala 0.85–1.3, `Wrap`, `maxLines` + ellipsis, `Flexible`.                                                |
| Keyboard menutupi form                                                                      | `SingleChildScrollView`, `resizeToAvoidBottomInset` default, bar bawah di luar area scroll.                     |
| `context` dipakai setelah `await`                                                           | `if (!context.mounted) return;`.                                                                                |
| `withOpacity`, `MaterialStateProperty`, `WillPopScope`, `textScaleFactor`, `surfaceVariant` | Gunakan `withValues(alpha:)`, `WidgetStateProperty`, `PopScope`, `TextScaler`, `surfaceContainerHighest`.       |
| Ikon tampil sebagai kotak kosong                                                            | Pastikan `uses-material-design: true`; bila masih bermasalah, baca dokumentasi `material_ui` tentang font ikon. |
| State pengguna lama muncul setelah ganti akun                                               | Provider per-pengguna me-`watch` `currentUserIdProvider`.                                                       |
| Masih bisa kembali ke halaman terproteksi setelah logout                                    | Redirect router + `StatefulShellRoute`; verifikasi di UAT langkah 15.                                           |
| Perubahan manual pada Gradle/AGP                                                            | Dilarang. Perbaiki lewat konfigurasi Flutter/JDK, bukan menyunting versi.                                       |

---

## 9. Audit Akhir (jalankan sebelum klaim selesai)

```bash
# 1) Format dan analyzer
dart format --set-exit-if-changed .
flutter analyze

# 2) Test
flutter test

# 3) Pola terlarang (harus tidak mencetak apa pun selain "bersih")
grep -rnE "TODO|FIXME|(^|[^A-Za-z])print\(|withOpacity|package:flutter/material.dart|package:flutter/cupertino.dart|service_role|anonKey" lib test \
  && echo "ADA PELANGGARAN" || echo "bersih"

# 4) File yatim (tidak diimpor siapa pun)
for f in $(find lib -name '*.dart' ! -name 'main.dart'); do
  b=$(basename "$f")
  grep -rq --include='*.dart' --exclude="$b" "$b" lib || echo "YATIM: $f"
done

# 5) Kelengkapan terhadap daftar di PRD 7.3
find lib test -type f -name '*.dart' | sort > /tmp/actual.txt
grep -E '^(lib|test)/.*\.dart$' docs/expected_files.txt | sort > /tmp/expected.txt
echo "HILANG:";  comm -13 /tmp/actual.txt /tmp/expected.txt
echo "TAMBAHAN (harus dijelaskan di PROGRESS.md):"; comm -23 /tmp/actual.txt /tmp/expected.txt

# 6) Semua layar terdaftar di router
for s in $(grep -rhoE "class [A-Za-z]+Screen " lib | awk '{print $2}'); do
  grep -q "$s" lib/core/router/app_router.dart || echo "BELUM DI ROUTER: $s"
done

# 7) Supabase hanya di tempat yang diizinkan
grep -rln "supabase_flutter" lib | grep -vE "/data/|lib/bootstrap.dart|lib/core/network/|lib/core/error/" \
  && echo "PELANGGARAN LAPISAN" || echo "lapisan bersih"

# 8) Manifest
grep -n "android.permission.INTERNET" android/app/src/main/AndroidManifest.xml
grep -n 'android:label="RodaKuu"' android/app/src/main/AndroidManifest.xml

# 9) Build
flutter build apk --debug
flutter build apk --release
```

Semua keluaran harus sesuai harapan. Satu pun gagal berarti pekerjaan belum selesai: perbaiki lalu ulangi dari awal audit.

Pemeriksaan manual tambahan:

- Buka tiap file SQL dan bandingkan dengan PRD 8.3/8.4 (tidak ada baris hilang).
- Pastikan seluruh 6 layar PRD 10.4 dan kedua layar auth memenuhi checklist 7.2.
- Pastikan tidak ada file di luar pohon PRD yang tidak dijelaskan di `PROGRESS.md` (hasil skrip 5 bagian "TAMBAHAN" harus kosong atau terjustifikasi).

---

## 10. Format Laporan Akhir

Laporan singkat, jujur, dan berbasis bukti:

```markdown
## Hasil

RodaKuu: <selesai / selesai sebagian — jelaskan>.

## Bukti

| Pemeriksaan                                              | Hasil           |
| -------------------------------------------------------- | --------------- |
| dart format                                              | lolos           |
| flutter analyze                                          | No issues found |
| flutter test                                             | <n> test lulus  |
| build apk --debug                                        | <path>          |
| build apk --release                                      | <path>          |
| Audit pola terlarang / file yatim / kelengkapan / router | bersih          |

## Belum diverifikasi (jujur)

- <mis. UAT pada backend nyata: belum, karena env.json/SQL belum tersedia>
- <mis. dijalankan di emulator: belum, karena …>

## Yang perlu Anda lakukan

1. Buat proyek Supabase, jalankan `supabase/migrations/0001_init.sql` lalu `supabase/seed.sql`.
2. Salin `env.example.json` menjadi `env.json` dan isi URL + publishable key.
3. `flutter run --dart-define-from-file=env.json` atau `flutter build apk --release --dart-define-from-file=env.json`.
4. (Opsional) Unggah foto ke bucket `vehicle-images` dan isi `image_url`.

## Keputusan dan catatan penting

- <ringkas dari PROGRESS.md>
```

---

## 11. Larangan Mutlak (ringkasan)

- Menulis kode tanpa membaca PRD.
- Melanjutkan ke milestone berikutnya sebelum gerbang lulus.
- Mengklaim berhasil tanpa output perintah.
- Memakai API pustaka yang belum diverifikasi.
- Mengimpor `flutter/material.dart` atau `flutter/cupertino.dart`.
- Menggunakan provider legacy Riverpod, `freezed`, `json_serializable`, `build_runner`, atau dependency di luar PRD 6.1 tanpa persetujuan.
- Menaruh `service_role` key atau rahasia lain di repo/aplikasi.
- Memanggil Supabase dari lapisan presentation.
- Meninggalkan stub, placeholder, data dummy, atau `TODO` di kode produksi.
- Menambah fitur di luar lingkup PRD.
- Mengedit versi AGP/Kotlin/Gradle atau `compileSdk/targetSdk/minSdk` secara manual.
- Menyembunyikan kegagalan build/test dengan menghapus test atau menurunkan lint tanpa catatan.

---

## 12. Ringkasan Satu Halaman (untuk dibaca ulang di tengah pekerjaan)

1. PRD dibaca penuh → preflight → M0 (build debug lulus dulu).
2. M1 core → M2 SQL → M3 auth/router/shell → M4 kendaraan → M5 pemesanan → M6 profil → M7 polesan → M8 audit + APK.
3. Setiap file: tulis utuh → `flutter analyze` bersih. Setiap fitur: test lulus. Setiap milestone: gerbang lulus → commit → `PROGRESS.md`.
4. API pustaka: cari di source paket (`.dart_tool/package_config.json`), jangan menebak.
5. Hanya `material_ui`. Riverpod 3 tanpa codegen dan tanpa provider legacy. `retry` dimatikan. Izin INTERNET wajib.
6. Selesai = seluruh DoD PRD bagian 14 terbukti oleh output perintah. Yang tidak terbukti dilaporkan jujur.
