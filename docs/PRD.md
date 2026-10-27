# PRD — RodaKuu

### Aplikasi Android Rental Mobil & Motor

| Item             | Keterangan                                                                                                                                                                 |
| ---------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Versi dokumen    | 1.0.0                                                                                                                                                                      |
| Tanggal          | 11 Oktober 2026                                                                                                                                                            |
| Status           | Siap diimplementasikan                                                                                                                                                     |
| Disusun sebagai  | Senior IT Business Analyst & Senior Flutter Developer                                                                                                                      |
| Platform         | Android (Flutter 3.47.x, Dart 3.13.x)                                                                                                                                      |
| Backend          | Supabase (Auth, Postgres, Storage)                                                                                                                                         |
| State management | Riverpod 3 (tanpa code generation)                                                                                                                                         |
| Bahasa           | Seluruh antarmuka aplikasi, pesan error, dan dokumen ini berbahasa Indonesia. Identifier kode (nama class, variabel, file) memakai bahasa Inggris sesuai standar industri. |

---

## 0. Cara Membaca Dokumen

| Bagian | Isi                                                                 | Pembaca utama       |
| ------ | ------------------------------------------------------------------- | ------------------- |
| 1–3    | Konteks bisnis, ruang lingkup, alur pengguna                        | Semua               |
| 4–5    | Kebutuhan fungsional dan non-fungsional beserta acceptance criteria | Developer, QA       |
| 6      | Tech stack dan versi library yang sudah diverifikasi                | Developer, AI Agent |
| 7      | Arsitektur, folder structure, standar kode                          | Developer, AI Agent |
| 8–9    | Skema database, SQL siap pakai, kontrak integrasi Supabase          | Developer, AI Agent |
| 10     | Desain UI/UX, design token, aturan responsif                        | Developer, Desainer |
| 11–12  | Routing dan konfigurasi proyek                                      | Developer, AI Agent |
| 13–15  | Testing, Definition of Done, rencana implementasi                   | Semua               |

**Aturan prioritas:** PRD ini adalah sumber kebenaran untuk _apa_ yang dibangun. `AGENTS.md` adalah sumber kebenaran untuk _bagaimana_ AI Agent mengeksekusinya. Jika ada konflik, hentikan pekerjaan dan laporkan, jangan menebak.

---

## 1. Ringkasan Produk

### 1.1 Visi

RodaKuu adalah aplikasi Android sederhana yang membuat penyewaan mobil dan motor terasa cepat dan jelas: temukan kendaraan, lihat detail, pilih tanggal, pesan, selesai.

### 1.2 Masalah yang diselesaikan

- Calon penyewa harus bertanya satu per satu lewat chat untuk tahu kendaraan apa yang tersedia dan berapa harganya.
- Pemilik rental kesulitan melacak pesanan dan mencegah pemesanan ganda pada tanggal yang sama.

### 1.3 Tujuan MVP

1. Pengguna dapat mendaftar, masuk, dan tetap masuk setelah aplikasi ditutup.
2. Pengguna dapat mencari dan memfilter kendaraan, lalu melihat detailnya.
3. Pengguna dapat membuat pesanan tanpa payment gateway. Pembayaran dilakukan langsung saat pengambilan kendaraan.
4. Sistem mencegah pemesanan ganda pada kendaraan dan tanggal yang sama, di level database.
5. Pengguna dapat melihat riwayat pesanan dan membatalkan pesanan yang belum dikonfirmasi.
6. Aplikasi dibangun dengan kualitas produksi: terstruktur, teruji, tanpa error analyzer, dan APK dapat dijalankan.

### 1.4 Target pengguna

- Penyewa individu (pekerja, mahasiswa, keluarga) usia 18–50 tahun di Indonesia dengan smartphone Android 7.0 ke atas.

### 1.5 Asumsi bisnis

- Satu operator rental. Tidak ada multi-vendor.
- Admin mengelola data kendaraan dan mengubah status pesanan lewat **Supabase Dashboard** (tidak ada aplikasi admin pada MVP).
- Pembayaran terjadi di luar aplikasi (tunai atau transfer saat pengambilan). Aplikasi hanya mencatat pesanan.
- Mata uang Rupiah (IDR), disimpan sebagai bilangan bulat tanpa desimal.

---

## 2. Ruang Lingkup

### 2.1 Dalam lingkup (In Scope)

| Fitur                                       | Catatan                                        |
| ------------------------------------------- | ---------------------------------------------- |
| Registrasi dan login email + kata sandi     | Registrasi diperlukan agar login dapat dipakai |
| Logout                                      | Dengan dialog konfirmasi                       |
| Daftar kendaraan mobil/motor                | Satu daftar, dua jenis                         |
| Pencarian, filter, dan pengurutan           | Server-side lewat PostgREST                    |
| Detail kendaraan                            |                                                |
| Pemesanan tanpa payment gateway             | Via RPC Supabase, harga dihitung di server     |
| Riwayat pesanan, detail pesanan, pembatalan |                                                |
| Profil (lihat dan ubah)                     |                                                |

### 2.2 Di luar lingkup (Out of Scope)

Payment gateway, aplikasi admin, lupa kata sandi, login sosial, notifikasi push, peta/GPS, unggah KTP/SIM, ulasan dan rating, favorit, chat, dark mode, multi-bahasa, iOS/Web/Desktop, pagination tak terbatas, analytics, CI/CD, ikon peluncur kustom.

> Agent **tidak boleh** menambah fitur di luar lingkup. Jika menurut agent ada celah, catat di `docs/PROGRESS.md` bagian "Saran lanjutan", jangan diimplementasikan.

---

## 3. Persona dan Alur Pengguna

### 3.1 Persona

- **Rina (24, karyawan):** butuh motor harian selama 2 minggu, ingin tahu harga total tanpa tanya-tanya.
- **Budi (38, ayah dua anak):** butuh mobil 7 kursi untuk akhir pekan, peduli transmisi dan kapasitas.

### 3.2 Alur utama

```
Buka aplikasi
   │
   ├─ belum login ──► Masuk ──(belum punya akun)──► Daftar ──► (otomatis masuk)
   │                    │
   └─ sudah login ◄─────┘
         │
         ▼
   Beranda (daftar kendaraan) ──► cari / filter / urutkan
         │
         ▼
   Detail kendaraan ──► [Pesan Sekarang]
         │
         ▼
   Form pemesanan: pilih tanggal, lokasi pengambilan, catatan → lihat ringkasan harga
         │
         ▼
   [Buat Pesanan] ──► Detail pesanan (status: Menunggu konfirmasi)
         │
         ▼
   Tab Pesanan (riwayat) ◄──► tab Profil (ubah profil, keluar)
```

---

## 4. Kebutuhan Fungsional

Prioritas semua item: **Must** (wajib ada di MVP).

### 4.1 Autentikasi

| ID         | Kebutuhan      | Acceptance Criteria                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| ---------- | -------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| FR-AUTH-01 | Registrasi     | Form: nama lengkap, email, kata sandi, konfirmasi kata sandi. Validasi inline: nama ≥ 2 karakter, email valid, kata sandi ≥ 8 karakter, konfirmasi harus sama. Nama dikirim sebagai metadata `full_name` agar trigger database membuat profil. Jika Supabase langsung memberi sesi, pengguna masuk otomatis. Jika email perlu verifikasi, tampilkan pesan "Periksa email Anda untuk verifikasi", lalu arahkan ke halaman Masuk. Email yang sudah terdaftar menampilkan "Email sudah terdaftar." |
| FR-AUTH-02 | Login          | Form: email dan kata sandi. Tombol menampilkan indikator loading dan nonaktif saat proses. Kredensial salah menampilkan "Email atau kata sandi salah." Sukses mengarahkan ke Beranda.                                                                                                                                                                                                                                                                                                           |
| FR-AUTH-03 | Sesi persisten | Setelah aplikasi ditutup dan dibuka lagi, pengguna tetap masuk (tanpa layar login berkedip).                                                                                                                                                                                                                                                                                                                                                                                                    |
| FR-AUTH-04 | Logout         | Di tab Profil. Dialog konfirmasi "Keluar dari akun?" dengan tombol Batal dan Keluar. Setelah keluar, pengguna di halaman Masuk dan tombol Back tidak bisa kembali ke halaman terproteksi.                                                                                                                                                                                                                                                                                                       |
| FR-AUTH-05 | Route guard    | Pengguna belum login yang membuka rute terproteksi diarahkan ke Masuk. Pengguna sudah login yang membuka Masuk/Daftar diarahkan ke Beranda.                                                                                                                                                                                                                                                                                                                                                     |

### 4.2 Kendaraan

| ID        | Kebutuhan        | Acceptance Criteria                                                                                                                                                                                                                                                                                                                            |
| --------- | ---------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| FR-VEH-01 | Daftar kendaraan | Menampilkan kartu: foto, jenis (Mobil/Motor), merek + nama, tahun, spesifikasi ringkas (transmisi • kapasitas • bahan bakar), harga per hari. Kendaraan `is_available = false` tampil dengan label "Tidak tersedia" dan redup, tetapi tetap bisa dibuka.                                                                                       |
| FR-VEH-02 | Pencarian        | Kolom cari mencocokkan merek atau nama (tidak peka huruf besar/kecil). Debounce 400 ms.                                                                                                                                                                                                                                                        |
| FR-VEH-03 | Filter           | Jenis (Semua/Mobil/Motor, selalu terlihat di atas daftar), serta di bottom sheet "Filter": transmisi (Semua/Manual/Matic), rentang harga per hari (RangeSlider Rp 0–1.000.000, kelipatan 10.000), switch "Hanya yang tersedia". Tombol "Terapkan" dan "Reset". Badge angka pada tombol Filter menunjukkan jumlah filter aktif (di luar jenis). |
| FR-VEH-04 | Pengurutan       | Terbaru (default), Harga terendah, Harga tertinggi. Berada di bottom sheet filter.                                                                                                                                                                                                                                                             |
| FR-VEH-05 | State daftar     | Loading: kerangka kartu (skeleton). Kosong: "Kendaraan tidak ditemukan" + tombol "Reset filter". Error: pesan ramah + tombol "Coba lagi". Tarik-untuk-muat-ulang (pull-to-refresh).                                                                                                                                                            |
| FR-VEH-06 | Detail kendaraan | Foto besar, merek + nama + tahun, harga per hari, grid spesifikasi (Jenis, Transmisi, Bahan bakar, Kapasitas, Tahun), deskripsi, bar bawah tetap berisi harga dan tombol "Pesan Sekarang". Tombol nonaktif dengan teks "Tidak tersedia" bila `is_available = false`.                                                                           |

### 4.3 Pemesanan

| ID        | Kebutuhan        | Acceptance Criteria                                                                                                                                                                                                                                                                                                                    |
| --------- | ---------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| FR-BKG-01 | Form pemesanan   | Input: rentang tanggal (date range picker), lokasi pengambilan (wajib, ≥ 3 karakter), catatan (opsional, maks 200 karakter). Menampilkan ringkasan kendaraan di bagian atas.                                                                                                                                                           |
| FR-BKG-02 | Validasi tanggal | Tanggal mulai tidak boleh sebelum hari ini. Durasi maksimal 30 hari. Rentang yang bertabrakan dengan pesanan aktif kendaraan tersebut ditolak dengan pesan "Tanggal bertabrakan dengan pesanan lain." Daftar tanggal terisi diambil lewat RPC `get_booked_ranges`. Database tetap menjadi penjaga terakhir lewat exclusion constraint. |
| FR-BKG-03 | Ringkasan harga  | Real-time: `Rp harga/hari × jumlah hari = Total`. Jumlah hari **inklusif** (1–3 Okt = 3 hari). Dengan catatan "Pembayaran dilakukan langsung saat pengambilan kendaraan."                                                                                                                                                              |
| FR-BKG-04 | Submit pesanan   | Memanggil RPC `create_booking`. Harga dihitung ulang di server dan **tidak** dipercaya dari klien. Tombol nonaktif + loading saat proses. Sukses: menuju detail pesanan dengan snackbar "Pesanan berhasil dibuat. Menunggu konfirmasi." Gagal: pesan error spesifik (lihat 9.5).                                                       |
| FR-BKG-05 | Detail pesanan   | Menampilkan status (chip), kendaraan, tanggal, durasi, lokasi pengambilan, catatan, rincian harga, waktu pesanan dibuat, serta tombol "Batalkan Pesanan" bila status Menunggu.                                                                                                                                                         |
| FR-BKG-06 | Pembatalan       | Dialog konfirmasi. Memanggil RPC `cancel_booking`. Hanya status `menunggu` yang bisa dibatalkan. Setelah sukses, status menjadi Dibatalkan dan daftar riwayat diperbarui.                                                                                                                                                              |

### 4.4 Riwayat

| ID        | Kebutuhan      | Acceptance Criteria                                                                                                                                                                                                                                                                |
| --------- | -------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| FR-HIS-01 | Daftar riwayat | Tab "Pesanan" berisi segmented control **Aktif** (menunggu, dikonfirmasi) dan **Selesai** (selesai, dibatalkan). Urut dari terbaru. Kartu: foto kecil, nama kendaraan, rentang tanggal, total harga, chip status. State loading, kosong ("Belum ada pesanan"), dan error tersedia. |
| FR-HIS-02 | Buka detail    | Ketuk kartu membuka detail pesanan (FR-BKG-05).                                                                                                                                                                                                                                    |

### 4.5 Profil

| ID        | Kebutuhan    | Acceptance Criteria                                                                                                                                                                                              |
| --------- | ------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| FR-PRF-01 | Lihat profil | Avatar inisial, nama lengkap, email, nomor telepon (atau "Belum diisi").                                                                                                                                         |
| FR-PRF-02 | Ubah profil  | Ubah nama lengkap (≥ 2 karakter) dan nomor telepon (opsional; bila diisi, format Indonesia 9–14 digit diawali `08` atau `+62`). Email hanya-baca. Sukses: kembali ke profil dengan snackbar "Profil diperbarui." |
| FR-PRF-03 | Keluar       | Lihat FR-AUTH-04.                                                                                                                                                                                                |

### 4.6 Aturan Bisnis

| ID    | Aturan                                                                                                                                                                            |
| ----- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| BR-01 | Jumlah hari sewa = `tanggal_selesai − tanggal_mulai + 1` (inklusif).                                                                                                              |
| BR-02 | Total harga = jumlah hari × harga per hari kendaraan **saat pesanan dibuat**. Harga disalin (snapshot) ke pesanan agar perubahan harga di masa depan tidak mengubah pesanan lama. |
| BR-03 | Durasi sewa minimal 1 hari, maksimal 30 hari.                                                                                                                                     |
| BR-04 | Satu kendaraan tidak boleh memiliki dua pesanan aktif (`menunggu` atau `dikonfirmasi`) pada tanggal yang beririsan.                                                               |
| BR-05 | Pesanan yang `dibatalkan` atau `selesai` tidak memblokir tanggal.                                                                                                                 |
| BR-06 | Pengguna hanya bisa membatalkan pesanannya sendiri dan hanya saat status `menunggu`.                                                                                              |
| BR-07 | Pengguna hanya bisa membaca pesanan dan profil miliknya sendiri.                                                                                                                  |
| BR-08 | Konfirmasi (`dikonfirmasi`) dan penyelesaian (`selesai`) pesanan dilakukan admin lewat Supabase Dashboard.                                                                        |

### 4.7 Siklus Status Pesanan

```
            ┌────────────► dibatalkan   (oleh pengguna, hanya dari 'menunggu')
 menunggu ──┤
            └─► dikonfirmasi ─► selesai  (oleh admin via dashboard)
```

---

## 5. Kebutuhan Non-Fungsional

| Kategori        | Target                                                                                                                                                                                                                    |
| --------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Performa        | Cold start < 3 detik di perangkat menengah. Konten daftar pertama muncul < 2 detik pada 4G. Scroll 60 fps (tanpa jank pada daftar 50+ item).                                                                              |
| Keamanan        | Row Level Security aktif di semua tabel. Hanya **publishable key** di aplikasi, **tidak boleh** ada `service_role` key. Semua trafik HTTPS. Token, email, dan kata sandi tidak boleh masuk log. Harga dihitung di server. |
| Keandalan       | Setiap pemanggilan jaringan punya state loading, error, dan retry. Tidak ada exception tak tertangani yang menutup aplikasi pada alur utama.                                                                              |
| Offline         | Tidak ada cache offline. Saat tanpa internet tampilkan error ramah + "Coba lagi".                                                                                                                                         |
| Kompatibilitas  | Android 7.0+ (minSdk 24, default Flutter 3.47). Target/compile SDK 36 lewat variabel `flutter.*`.                                                                                                                         |
| Responsif       | Layout aman (tanpa overflow) pada lebar 320–600+ dp, tinggi 568–960 dp, orientasi portrait; landscape tidak crash. Skala teks sistem 0.85–1.3 tidak merusak layout.                                                       |
| Aksesibilitas   | Kontras teks ≥ 4.5:1. Target sentuh ≥ 48×48 dp. Ikon-tombol punya `tooltip`/`Semantics`. Status tidak hanya dibedakan warna (selalu ada teks).                                                                            |
| Maintainability | `flutter analyze` 0 issue. `dart format` bersih. File ≤ 300 baris. Tidak ada logika bisnis di widget. Semua logika non-UI punya unit test.                                                                                |
| Lokalisasi      | Tanggal `id_ID` ("12 Okt 2026"), Rupiah "Rp 350.000".                                                                                                                                                                     |

---

## 6. Tech Stack dan Versi

### 6.1 Versi (diverifikasi 11 Oktober 2026)

| Komponen               | Versi                      | Keterangan                                                                                                                          |
| ---------------------- | -------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| Flutter                | **3.47.x** (target 3.47.6) | Garis rilis 3.47 terverifikasi (dirilis Agustus 2026). Patch `.6` harus dikonfirmasi lewat `flutter --version` di mesin pengembang. |
| Dart                   | 3.13.x                     | Bawaan Flutter 3.47. Constraint `sdk: ^3.13.0`.                                                                                     |
| Java (JDK)             | 17                         | Minimum yang diwajibkan Flutter 3.47.                                                                                               |
| Android Gradle Plugin  | 9.1.0                      | Diatur oleh template `flutter create`. **Jangan diedit manual.**                                                                    |
| Kotlin Gradle Plugin   | 2.4.0                      | Idem.                                                                                                                               |
| Gradle                 | 9.3.1                      | Idem.                                                                                                                               |
| `material_ui`          | ^1.6.0                     | Pengganti `package:flutter/material.dart` (lihat 6.2).                                                                              |
| `supabase_flutter`     | ^2.18.2                    | Inisialisasi memakai `publishableKey`.                                                                                              |
| `flutter_riverpod`     | ^3.4.3                     | Riverpod 3.                                                                                                                         |
| `go_router`            | ^18.0.2                    |                                                                                                                                     |
| `google_fonts`         | ^9.0.0                     |                                                                                                                                     |
| `cached_network_image` | ^4.0.4                     |                                                                                                                                     |
| `intl`                 | ^0.20.3                    |                                                                                                                                     |
| `flutter_lints` (dev)  | ^6.0.0                     |                                                                                                                                     |

### 6.2 Catatan kritis Flutter 3.47

1. **Material dipisah menjadi paket `material_ui`.** Flutter 3.47 menyediakan `material_ui` dan `cupertino_ui` sebagai paket mandiri versi 1.0+. Library lama di dalam SDK dijadwalkan deprecated pada rilis stable November 2026. Library pihak ketiga yang dipakai proyek ini (`go_router`, `google_fonts`, `cached_network_image`) sudah bergantung pada `material_ui`.
   - **Wajib:** semua file memakai `import 'package:material_ui/material_ui.dart';`.
   - **Dilarang:** `import 'package:flutter/material.dart';` dan `import 'package:flutter/cupertino.dart';`. Mencampur keduanya menghasilkan dua class berbeda dengan nama sama sehingga terjadi error tipe dan impor ambigu.
   - Lokalisasi: pakai `GlobalMaterialLocalizations.delegates` dari `material_ui` (sudah mencakup delegate Cupertino dan Widgets). Tidak perlu impor `flutter_localizations`.
   - Template `flutter create` masih menghasilkan `main.dart` dan `test/widget_test.dart` berbasis `flutter/material.dart`. Keduanya **harus diganti/dihapus**.
2. **Riverpod 3.**
   - Gunakan `Notifier`, `AsyncNotifier`, `Provider`, `FutureProvider`, `StreamProvider` (modifier `.autoDispose` dan `.family` tetap berlaku).
   - **Dilarang** `StateProvider`, `StateNotifierProvider`, `ChangeNotifierProvider` (dipindah ke `flutter_riverpod/legacy.dart`).
   - Provider yang gagal otomatis **di-retry** secara default. Untuk aplikasi ini retry dimatikan global lewat `ProviderScope(retry: (retryCount, error) => null)` agar error tampil segera dan pengguna memakai tombol "Coba lagi". Verifikasi signature di API reference versi terpasang.
   - Tanpa code generation, jadi tanpa `riverpod_generator`, `riverpod_annotation`, dan `build_runner`.
3. **Supabase.** `Supabase.initialize(url: ..., publishableKey: ...)`. Parameter lama `anonKey` tidak dipakai.
4. **Dart 3.13.** `dart format` memakai gaya baru. Selalu jalankan `dart format .` sebelum commit.
5. **Android.** Gunakan `flutter.compileSdkVersion`, `flutter.targetSdkVersion`, `flutter.minSdkVersion` dari template, jangan hardcode angka.

### 6.3 Aturan manajemen versi

- Tambahkan dependency dengan `flutter pub add <paket>` agar versi yang ter-resolve pasti kompatibel, lalu cocokkan dengan tabel 6.1.
- Jika hasil resolve lebih baru pada level minor/patch, boleh dipakai. Jika berbeda major, baca changelog paket sebelum memakai API-nya.
- `pubspec.lock` di-commit (ini aplikasi, bukan library).
- Dilarang menurunkan versi untuk "mengakali" error tanpa mencatat alasannya di `docs/PROGRESS.md`.

### 6.4 Keputusan arsitektur (ADR ringkas)

| Keputusan                                              | Alasan                                                                                                                                           |
| ------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| Riverpod manual, tanpa codegen                         | Lebih sedikit dependency dan langkah build, risiko konflik versi `analyzer` nol, tetap idiomatis dan mudah diuji.                                |
| Tanpa `freezed`/`json_serializable`                    | Hanya 4 entity sederhana. `fromJson` manual lebih mudah diaudit dan bebas build_runner.                                                          |
| `go_router`                                            | Standar resmi tim Flutter, mendukung redirect berbasis auth dan `StatefulShellRoute` untuk bottom navigation.                                    |
| Pemesanan lewat RPC (`security definer`)               | Harga dan validasi dihitung di server, klien tidak bisa memanipulasi total harga. Tabel `bookings` tidak punya policy INSERT/UPDATE untuk klien. |
| Exclusion constraint `btree_gist`                      | Mencegah pemesanan ganda secara atomik, bebas race condition.                                                                                    |
| `--dart-define-from-file` untuk konfigurasi            | Tanpa dependency tambahan dan tanpa mem-bundle file rahasia sebagai asset.                                                                       |
| `google_fonts` fetch saat runtime                      | Tidak perlu mengelola file font. Bila gagal unduh, teks tetap tampil dengan font bawaan.                                                         |
| Teks UI inline + `AppStrings` untuk yang dipakai ulang | Tidak butuh sistem i18n karena hanya satu bahasa.                                                                                                |

### 6.5 Dependency yang sengaja tidak dipakai

`freezed`, `json_serializable`, `build_runner`, `riverpod_generator`, `dio`, `get_it`, `flutter_dotenv`, `shimmer`, `flutter_launcher_icons`, `mocktail`. Skeleton dibuat dari widget biasa dan test memakai fake class tulisan tangan.

---

## 7. Arsitektur dan Standar Kode

### 7.1 Prinsip

Feature-first + clean architecture ringan. Setiap fitur memiliki tiga lapisan: **domain**, **data**, **presentation**. Tidak ada use-case class, notifier memanggil repository langsung.

### 7.2 Aturan dependensi antar lapisan

```
presentation ──► domain ◄── data
      │            ▲          │
      └────────────┴──────────┴────► core   (core tidak mengimpor feature mana pun)
```

| Lapisan        | Boleh mengimpor                                                                                                                   | Dilarang                                                        |
| -------------- | --------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------- |
| `domain`       | Dart murni, `core/utils` yang murni Dart                                                                                          | `supabase_flutter`, `material_ui`, `flutter_riverpod`           |
| `data`         | `domain`, `core`, `supabase_flutter`                                                                                              | `material_ui`, `flutter_riverpod`, apa pun dari `presentation`  |
| `presentation` | `domain`, `core`, `flutter_riverpod`, `material_ui`, `go_router`                                                                  | Pemanggilan `Supabase.instance`/`SupabaseClient` langsung       |
| `core`         | Dart, Flutter, paket pihak ketiga                                                                                                 | Mengimpor dari `features/`                                      |
| `core/router`  | **Satu-satunya pengecualian** (composition root): boleh mengimpor `screens` dan `providers` dari `features/` untuk merangkai rute | Mengimpor `data` fitur atau memanggil `SupabaseClient` langsung |
| Antar fitur    | Hanya `domain` dan `presentation/providers` fitur lain                                                                            | `data` fitur lain, `screens`/`widgets` fitur lain               |

Paket `supabase_flutter` hanya boleh diimpor di: semua folder `data/`, `lib/bootstrap.dart`, `lib/core/network/supabase_providers.dart`, dan `lib/core/error/error_mapper.dart` (untuk tipe exception).

### 7.3 Folder structure (daftar file wajib)

```
rodakuu/
├── android/                              # dihasilkan flutter create; edit hanya AndroidManifest (lihat 12.4)
├── docs/
│   ├── PRD.md                            # dokumen ini
│   ├── PROGRESS.md                       # log kemajuan agent (lihat AGENTS.md)
│   └── expected_files.txt                # daftar file dari pohon ini (untuk pengecekan kelengkapan)
├── supabase/
│   ├── migrations/0001_init.sql          # skema, RLS, RPC (bagian 8.3)
│   └── seed.sql                          # data contoh (bagian 8.4)
├── test/
│   ├── helpers/
│   │   ├── fakes.dart                    # Fake*Repository tulisan tangan
│   │   └── pump_app.dart                 # helper pumpWidget + ukuran layar
│   ├── core/
│   │   ├── validators_test.dart
│   │   ├── formatters_test.dart
│   │   └── error_mapper_test.dart
│   ├── responsive/
│   │   └── responsive_layout_test.dart   # T-RS-01: semua layar utama × 6 ukuran × 2 skala teks
│   └── features/
│       ├── auth/
│       │   ├── login_screen_test.dart
│       │   └── register_screen_test.dart
│       ├── vehicles/
│       │   ├── vehicle_dto_test.dart
│       │   ├── vehicle_filter_test.dart
│       │   ├── vehicle_list_screen_test.dart
│       │   └── vehicle_detail_screen_test.dart
│       ├── bookings/
│       │   ├── booking_calculator_test.dart
│       │   ├── booking_dto_test.dart
│       │   ├── booking_form_screen_test.dart
│       │   └── booking_history_screen_test.dart
│       └── profile/
│           └── edit_profile_screen_test.dart
├── env.example.json                      # contoh konfigurasi (di-commit)
├── env.json                              # konfigurasi asli (TIDAK di-commit)
├── analysis_options.yaml
├── pubspec.yaml
└── lib/
    ├── main.dart                         # hanya memanggil bootstrap()
    ├── bootstrap.dart                    # init binding, env check, Supabase, runApp
    ├── app.dart                          # RodaKuuApp: MaterialApp.router + tema + lokalisasi
    ├── core/
    │   ├── config/
    │   │   ├── app_env.dart              # String.fromEnvironment
    │   │   ├── app_constants.dart        # maxRentalDays, batas harga filter, debounce, dll
    │   │   └── app_strings.dart          # teks yang dipakai ≥ 2 tempat
    │   ├── error/
    │   │   ├── app_failure.dart          # sealed class AppFailure + turunannya
    │   │   └── error_mapper.dart         # mapToFailure(Object) + failureMessage(Object)
    │   ├── network/
    │   │   └── supabase_providers.dart   # supabaseClientProvider
    │   ├── router/
    │   │   ├── app_routes.dart           # konstanta path
    │   │   ├── app_router.dart           # routerProvider (GoRouter)
    │   │   └── auth_refresh_notifier.dart
    │   ├── theme/
    │   │   ├── app_colors.dart
    │   │   ├── app_spacing.dart          # spacing + radius
    │   │   ├── app_typography.dart
    │   │   └── app_theme.dart            # AppTheme.light({useGoogleFonts})
    │   ├── utils/
    │   │   ├── formatters.dart           # formatRupiah, formatDate, formatDateRange
    │   │   ├── validators.dart           # Validators.email/password/fullName/phone/…
    │   │   ├── enum_parser.dart          # parseEnum<T>
    │   │   ├── responsive.dart           # breakpoint + extension context
    │   │   └── debouncer.dart
    │   └── widgets/
    │       ├── app_button.dart           # AppButton (primary/secondary/text + loading)
    │       ├── app_text_field.dart
    │       ├── app_loading.dart
    │       ├── app_empty_view.dart
    │       ├── app_error_view.dart
    │       ├── app_logo.dart             # wordmark tipografi
    │       ├── responsive_center.dart    # batasi lebar konten maks 640 dp
    │       ├── not_found_screen.dart     # "Halaman tidak ditemukan" untuk errorBuilder router
    │       └── config_error_view.dart    # ConfigErrorView + ConfigErrorApp (bila env belum diisi)
    └── features/
        ├── shell/
        │   └── main_shell_screen.dart    # Scaffold + NavigationBar (3 tab)
        ├── auth/
        │   ├── domain/
        │   │   └── auth_repository.dart  # abstract + enum SignUpResult
        │   ├── data/
        │   │   └── supabase_auth_repository.dart
        │   └── presentation/
        │       ├── providers/
        │       │   ├── auth_providers.dart       # authRepositoryProvider, currentUserIdProvider
        │       │   ├── login_controller.dart
        │       │   └── register_controller.dart
        │       ├── screens/
        │       │   ├── login_screen.dart
        │       │   └── register_screen.dart
        │       └── widgets/
        │           └── auth_scaffold.dart
        ├── vehicles/
        │   ├── domain/
        │   │   ├── entities/
        │   │   │   ├── vehicle.dart              # Vehicle + enum VehicleType/Transmission/FuelType
        │   │   │   └── vehicle_filter.dart       # VehicleFilter + enum VehicleSort
        │   │   └── repositories/
        │   │       └── vehicle_repository.dart
        │   ├── data/
        │   │   ├── models/
        │   │   │   └── vehicle_dto.dart
        │   │   └── repositories/
        │   │       └── supabase_vehicle_repository.dart
        │   └── presentation/
        │       ├── providers/
        │       │   ├── vehicle_providers.dart    # repo, list, detail
        │       │   └── vehicle_filter_controller.dart
        │       ├── screens/
        │       │   ├── vehicle_list_screen.dart
        │       │   └── vehicle_detail_screen.dart
        │       └── widgets/
        │           ├── vehicle_card.dart
        │           ├── vehicle_card_skeleton.dart
        │           ├── vehicle_image.dart
        │           ├── vehicle_filter_sheet.dart
        │           ├── vehicle_type_selector.dart
        │           └── spec_item.dart
        ├── bookings/
        │   ├── domain/
        │   │   ├── entities/
        │   │   │   ├── booking.dart              # Booking, BookingVehicle, enum BookingStatus
        │   │   │   ├── booking_request.dart
        │   │   │   └── booked_range.dart
        │   │   ├── services/
        │   │   │   └── booking_calculator.dart   # hitung hari + total (Dart murni)
        │   │   └── repositories/
        │   │       └── booking_repository.dart
        │   ├── data/
        │   │   ├── models/
        │   │   │   ├── booking_dto.dart
        │   │   │   └── booked_range_dto.dart
        │   │   └── repositories/
        │   │       └── supabase_booking_repository.dart
        │   └── presentation/
        │       ├── providers/
        │       │   ├── booking_providers.dart    # repo, myBookings, bookingDetail, bookedRanges
        │       │   ├── booking_form_controller.dart
        │       │   └── cancel_booking_controller.dart
        │       ├── screens/
        │       │   ├── booking_form_screen.dart
        │       │   ├── booking_history_screen.dart
        │       │   └── booking_detail_screen.dart
        │       └── widgets/
        │           ├── booking_card.dart
        │           ├── booking_status_chip.dart
        │           ├── date_range_field.dart
        │           └── price_summary.dart
        └── profile/
            ├── domain/
            │   ├── entities/
            │   │   └── profile.dart
            │   └── repositories/
            │       └── profile_repository.dart
            ├── data/
            │   ├── models/
            │   │   └── profile_dto.dart
            │   └── repositories/
            │       └── supabase_profile_repository.dart
            └── presentation/
                ├── providers/
                │   ├── profile_providers.dart
                │   └── edit_profile_controller.dart
                ├── screens/
                │   ├── profile_screen.dart
                │   └── edit_profile_screen.dart
                └── widgets/
                    ├── profile_avatar.dart
                    └── profile_menu_tile.dart
```

### 7.4 Tanggung jawab tiap lapisan

| Lapisan                  | Isi                                                                                                              | Contoh                      |
| ------------------------ | ---------------------------------------------------------------------------------------------------------------- | --------------------------- |
| `domain/entities`        | Class immutable murni Dart, mewakili konsep bisnis                                                               | `Vehicle`, `Booking`        |
| `domain/repositories`    | `abstract interface class` yang mendefinisikan kontrak                                                           | `VehicleRepository`         |
| `domain/services`        | Logika bisnis murni tanpa I/O                                                                                    | `BookingCalculator`         |
| `data/models`            | DTO: `fromJson` + `toEntity()`, mengenal nama kolom database                                                     | `VehicleDto`                |
| `data/repositories`      | Implementasi repository memakai `SupabaseClient`, **semua** `try/catch` dan konversi ke `AppFailure` ada di sini | `SupabaseVehicleRepository` |
| `presentation/providers` | Provider repository, provider data, dan controller (Notifier)                                                    | `vehicleListProvider`       |
| `presentation/screens`   | Satu screen per file, hanya merangkai widget dan membaca provider                                                | `VehicleListScreen`         |
| `presentation/widgets`   | Widget khusus fitur yang bisa dipakai ulang                                                                      | `VehicleCard`               |
| `core/widgets`           | Widget generik lintas fitur                                                                                      | `AppButton`                 |

### 7.5 Konvensi penamaan

| Objek                       | Konvensi                                                | Contoh                                     |
| --------------------------- | ------------------------------------------------------- | ------------------------------------------ |
| File                        | `snake_case.dart`                                       | `vehicle_card.dart`                        |
| Class, enum, typedef        | `PascalCase`                                            | `VehicleCard`                              |
| Variabel, fungsi, parameter | `camelCase`                                             | `pricePerDay`                              |
| Konstanta                   | `camelCase` dalam `abstract final class`                | `AppConstants.maxRentalDays`               |
| Provider                    | `camelCase` + akhiran `Provider`                        | `vehicleListProvider`                      |
| Notifier/controller         | `PascalCase` + akhiran `Controller`                     | `LoginController`                          |
| Repository                  | Interface tanpa prefix, implementasi diawali `Supabase` | `AuthRepository`, `SupabaseAuthRepository` |
| DTO                         | akhiran `Dto`                                           | `BookingDto`                               |
| Kolom database              | `snake_case`                                            | `price_per_day`                            |
| Path rute                   | `kebab-case` bahasa Indonesia                           | `/kendaraan/:id`                           |

### 7.6 Aturan clean code (wajib)

1. **Satu tanggung jawab per file.** Satu class publik per file, maksimal ~300 baris. Jika melebihi, pecah menjadi widget/class kecil.
2. **Widget berupa class**, bukan fungsi helper `_buildXxx()`. Gunakan `const` constructor di mana mungkin.
3. **Tanpa logika bisnis di widget.** Validasi, kalkulasi, dan akses data berada di domain/data/controller.
4. **Tanpa akses Supabase di luar `data/`.** Presentation hanya mengenal interface repository.
5. **Immutability.** Entity memakai `final` field, `@immutable`, dan mengimplementasikan `==`/`hashCode` (gunakan `Object.hash`) bila dipakai sebagai state/key provider.
6. **Null-safety disiplin.** Dilarang `!` tanpa alasan yang jelas. Dilarang `dynamic` kecuali di batas JSON (`Map<String, dynamic>`).
7. **Async aman.** Setelah `await` di dalam widget, cek `if (!context.mounted) return;` sebelum memakai `context`. Semua `TextEditingController`, `FocusNode`, `Timer`, dan `StreamSubscription` di-`dispose`/`cancel`.
8. **Tanpa magic number/string.** Angka dan teks yang berulang masuk ke `AppConstants`, `AppSpacing`, atau `AppStrings`.
9. **Tanpa kode mati.** Dilarang `print`, kode yang di-comment, `TODO`/`FIXME`, import tak terpakai, dan `// ignore:` tanpa alasan tertulis.
10. **Komentar menjelaskan "mengapa"**, bukan "apa". Dokumentasi `///` untuk API publik di `domain` dan `core`. Komentar ditulis dalam bahasa Indonesia.
11. **Gunakan API non-deprecated.** Contoh: `Color.withValues(alpha: …)` (bukan `withOpacity`), `WidgetStateProperty` (bukan `MaterialStateProperty`), `PopScope` (bukan `WillPopScope`), `TextScaler` (bukan `textScaleFactor`), `surfaceContainerHighest` (bukan `surfaceVariant`). Peringatan deprecated dari analyzer harus 0.
12. **Urutan import** (dirapikan `dart format`): `dart:` → `package:` → relatif/proyek. Gunakan import absolut `package:rodakuu/...` untuk file di dalam `lib/`.
13. **Error tidak ditelan.** Tidak ada blok `catch` kosong tanpa komentar alasan. Error dipetakan ke `AppFailure` dan sampai ke UI.

### 7.7 Pola state management (Riverpod 3)

| Kebutuhan                                   | Pola                                                                                                 |
| ------------------------------------------- | ---------------------------------------------------------------------------------------------------- |
| Dependency (client, repository)             | `Provider<T>`                                                                                        |
| Data hanya-baca dari server                 | `FutureProvider.autoDispose` (`.family` bila ada parameter)                                          |
| Stream (auth state)                         | `StreamProvider`                                                                                     |
| State sinkron yang bisa diubah (filter)     | `NotifierProvider` + `Notifier<T>`                                                                   |
| Aksi submit (login, buat pesanan, batalkan) | `AsyncNotifierProvider.autoDispose<C, void>` + `AsyncNotifier<void>` yang memakai `AsyncValue.guard` |
| Parameter provider                          | `.family` pada `FutureProvider`, **bukan** family `Notifier`                                         |

Aturan:

- Di `build()` widget gunakan `ref.watch`. Di callback (onPressed) gunakan `ref.read`. Jangan `ref.read` di `build()`.
- Provider data yang bergantung pada pengguna (`myBookingsProvider`, `profileProvider`) wajib `ref.watch(currentUserIdProvider)` agar otomatis dibuat ulang saat pengguna berganti akun.
- Setelah aksi yang mengubah data (buat/batalkan pesanan, ubah profil), panggil `ref.invalidate(...)` pada provider terkait.
- Tampilkan `AsyncValue` dengan `switch`/`when` yang menangani **loading, error, dan data**. Dilarang `.value!`.
- Pesan error dari aksi ditampilkan lewat `ref.listen` + `SnackBar`, bukan di dalam `build`.

### 7.8 Penanganan error

```dart
sealed class AppFailure implements Exception {
  const AppFailure(this.message);
  final String message;
}
final class NetworkFailure extends AppFailure { const NetworkFailure() : super('Tidak dapat terhubung ke internet. Periksa koneksi Anda.'); }
final class AuthFailure extends AppFailure { const AuthFailure(super.message); }
final class NotFoundFailure extends AppFailure { const NotFoundFailure(super.message); }
final class ValidationFailure extends AppFailure { const ValidationFailure(super.message); }
final class ServerFailure extends AppFailure { const ServerFailure() : super('Terjadi kesalahan pada server. Coba lagi beberapa saat.'); }
final class UnknownFailure extends AppFailure { const UnknownFailure() : super('Terjadi kesalahan yang tidak diketahui.'); }
```

Alur: `Repository` menangkap exception pustaka lalu melempar ulang `AppFailure` dengan `Error.throwWithStackTrace(mapToFailure(e), st)` → `Controller/Provider` membiarkannya menjadi `AsyncError` → UI membaca `failureMessage(error)`.

### 7.9 Logging

Hanya `debugPrint` di dalam `bootstrap.dart` untuk `FlutterError.onError` dan `PlatformDispatcher.instance.onError`, dibungkus `kDebugMode`. Dilarang mencetak token, kata sandi, atau email.

### 7.10 Keamanan

- `env.json` masuk `.gitignore`. Hanya `env.example.json` yang di-commit.
- Hanya `SUPABASE_URL` dan `SUPABASE_PUBLISHABLE_KEY` di aplikasi. `service_role` tidak boleh muncul di repo mana pun.
- Semua akses data dilindungi RLS. Operasi tulis pesanan hanya lewat RPC.
- Sesi disimpan oleh `supabase_flutter` (default `shared_preferences`). Cukup untuk MVP.

### 7.11 Git dan commit

- Branch utama `main`. Satu commit per milestone (lihat 15) dengan format Conventional Commits berbahasa Inggris: `feat(auth): add login and register screens`.
- Jangan commit `env.json`, `build/`, `.dart_tool/`, `*.jks`, `key.properties`.

---

## 8. Desain Data (Supabase)

### 8.1 Diagram relasi

```
auth.users (Supabase)
    │ 1
    │ trigger on insert
    ▼ 1
profiles ─────────────┐ 1
 id (PK, FK users)    │
 full_name, phone     │
                      ▼ *
vehicles ──1────*──► bookings
 id (PK)               id (PK)
 type, brand, name…    user_id (FK profiles), vehicle_id (FK vehicles)
 price_per_day         start_date, end_date, total_days
 is_available          price_per_day (snapshot), total_price
                       pickup_location, notes, status
```

### 8.2 Pengaturan dashboard yang perlu dilakukan pemilik proyek

1. Buat proyek Supabase. Salin **Project URL** dan **Publishable key** dari _Project Settings → API Keys_.
2. _Authentication → Providers → Email_: aktif. Untuk MVP disarankan menonaktifkan **Confirm email** agar pendaftaran langsung masuk. Jika tetap aktif, aplikasi sudah menangani alurnya (FR-AUTH-01).
3. Jalankan `supabase/migrations/0001_init.sql` di _SQL Editor_, lalu `supabase/seed.sql`.
4. (Opsional) Unggah foto ke bucket `vehicle-images` dan isi kolom `image_url` dengan URL publiknya. Tanpa foto, aplikasi menampilkan placeholder.
5. Isi `env.json` (lihat 12.3).

### 8.3 Migrasi: `supabase/migrations/0001_init.sql`

```sql
-- =====================================================================
-- RodaKuu — migrasi awal
-- Jalankan sekali di Supabase SQL Editor.
-- =====================================================================

create extension if not exists btree_gist;

-- ---------------------------------------------------------------------
-- Fungsi bantu: perbarui kolom updated_at
-- ---------------------------------------------------------------------
create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- ---------------------------------------------------------------------
-- PROFILES
-- ---------------------------------------------------------------------
create table public.profiles (
  id          uuid primary key references auth.users (id) on delete cascade,
  full_name   text not null default '',
  phone       text,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create trigger profiles_set_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();

-- Buat profil otomatis saat pengguna mendaftar
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, full_name)
  values (new.id, coalesce(new.raw_user_meta_data ->> 'full_name', ''));
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ---------------------------------------------------------------------
-- VEHICLES
-- ---------------------------------------------------------------------
create table public.vehicles (
  id             uuid primary key default gen_random_uuid(),
  type           text not null check (type in ('mobil', 'motor')),
  brand          text not null,
  name           text not null,
  year           smallint not null check (year between 1990 and 2100),
  transmission   text not null check (transmission in ('manual', 'matic')),
  fuel           text not null check (fuel in ('bensin', 'diesel', 'listrik')),
  seats          smallint not null check (seats between 1 and 12),
  price_per_day  integer not null check (price_per_day > 0),
  description    text not null default '',
  image_url      text,
  is_available   boolean not null default true,
  created_at     timestamptz not null default now()
);

create index vehicles_type_idx  on public.vehicles (type);
create index vehicles_price_idx on public.vehicles (price_per_day);

-- ---------------------------------------------------------------------
-- BOOKINGS
-- ---------------------------------------------------------------------
create table public.bookings (
  id               uuid primary key default gen_random_uuid(),
  user_id          uuid not null references public.profiles (id) on delete cascade,
  vehicle_id       uuid not null references public.vehicles (id) on delete restrict,
  start_date       date not null,
  end_date         date not null,
  total_days       integer not null check (total_days between 1 and 30),
  price_per_day    integer not null check (price_per_day > 0),
  total_price      integer not null check (total_price > 0),
  pickup_location  text not null,
  notes            text,
  status           text not null default 'menunggu'
                   check (status in ('menunggu', 'dikonfirmasi', 'selesai', 'dibatalkan')),
  created_at       timestamptz not null default now(),
  constraint bookings_dates_valid check (end_date >= start_date),
  -- Cegah pemesanan ganda: kendaraan yang sama tidak boleh punya dua pesanan
  -- aktif dengan rentang tanggal beririsan.
  constraint bookings_no_overlap exclude using gist (
    vehicle_id with =,
    daterange(start_date, end_date, '[]') with &&
  ) where (status in ('menunggu', 'dikonfirmasi'))
);

create index bookings_user_idx on public.bookings (user_id, created_at desc);

-- ---------------------------------------------------------------------
-- ROW LEVEL SECURITY
-- ---------------------------------------------------------------------
alter table public.profiles enable row level security;
alter table public.vehicles enable row level security;
alter table public.bookings enable row level security;

create policy "profiles_select_own"
  on public.profiles for select to authenticated
  using ((select auth.uid()) = id);

create policy "profiles_update_own"
  on public.profiles for update to authenticated
  using ((select auth.uid()) = id)
  with check ((select auth.uid()) = id);

create policy "vehicles_select_authenticated"
  on public.vehicles for select to authenticated
  using (true);

create policy "bookings_select_own"
  on public.bookings for select to authenticated
  using ((select auth.uid()) = user_id);

-- Sengaja TIDAK ada policy INSERT/UPDATE/DELETE pada bookings:
-- klien hanya boleh menulis lewat fungsi RPC di bawah.

-- ---------------------------------------------------------------------
-- RPC: buat pesanan (harga dihitung di server)
-- ---------------------------------------------------------------------
create or replace function public.create_booking(
  p_vehicle_id       uuid,
  p_start_date       date,
  p_end_date         date,
  p_pickup_location  text,
  p_notes            text default null
)
returns public.bookings
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user     uuid := auth.uid();
  v_vehicle  public.vehicles;
  v_days     integer;
  v_booking  public.bookings;
begin
  if v_user is null then
    raise exception 'Anda harus masuk terlebih dahulu.' using errcode = '28000';
  end if;

  if p_start_date is null or p_end_date is null or p_end_date < p_start_date then
    raise exception 'Rentang tanggal tidak valid.' using errcode = '22023';
  end if;

  if p_start_date < current_date then
    raise exception 'Tanggal mulai tidak boleh di masa lalu.' using errcode = '22023';
  end if;

  v_days := (p_end_date - p_start_date) + 1;
  if v_days > 30 then
    raise exception 'Durasi sewa maksimal 30 hari.' using errcode = '22023';
  end if;

  if length(trim(coalesce(p_pickup_location, ''))) < 3 then
    raise exception 'Lokasi pengambilan wajib diisi.' using errcode = '22023';
  end if;

  select * into v_vehicle from public.vehicles where id = p_vehicle_id;
  if not found then
    raise exception 'Kendaraan tidak ditemukan.' using errcode = 'P0002';
  end if;

  if not v_vehicle.is_available then
    raise exception 'Kendaraan sedang tidak tersedia.' using errcode = '22023';
  end if;

  insert into public.bookings (
    user_id, vehicle_id, start_date, end_date, total_days,
    price_per_day, total_price, pickup_location, notes
  )
  values (
    v_user, p_vehicle_id, p_start_date, p_end_date, v_days,
    v_vehicle.price_per_day, v_days * v_vehicle.price_per_day,
    trim(p_pickup_location), nullif(trim(coalesce(p_notes, '')), '')
  )
  returning * into v_booking;

  return v_booking;
end;
$$;

-- ---------------------------------------------------------------------
-- RPC: batalkan pesanan milik sendiri (hanya status 'menunggu')
-- ---------------------------------------------------------------------
create or replace function public.cancel_booking(p_booking_id uuid)
returns public.bookings
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_booking public.bookings;
begin
  update public.bookings
     set status = 'dibatalkan'
   where id = p_booking_id
     and user_id = auth.uid()
     and status = 'menunggu'
  returning * into v_booking;

  if not found then
    raise exception 'Pesanan tidak dapat dibatalkan.' using errcode = '22023';
  end if;

  return v_booking;
end;
$$;

-- ---------------------------------------------------------------------
-- RPC: rentang tanggal yang sudah terisi (tanpa membuka data pengguna lain)
-- ---------------------------------------------------------------------
create or replace function public.get_booked_ranges(p_vehicle_id uuid)
returns table (start_date date, end_date date)
language sql
stable
security definer
set search_path = ''
as $$
  select b.start_date, b.end_date
    from public.bookings b
   where b.vehicle_id = p_vehicle_id
     and b.status in ('menunggu', 'dikonfirmasi')
     and b.end_date >= current_date
   order by b.start_date;
$$;

-- Batasi eksekusi RPC hanya untuk pengguna yang sudah masuk
revoke all on function public.create_booking(uuid, date, date, text, text) from public, anon;
revoke all on function public.cancel_booking(uuid) from public, anon;
revoke all on function public.get_booked_ranges(uuid) from public, anon;
grant execute on function public.create_booking(uuid, date, date, text, text) to authenticated;
grant execute on function public.cancel_booking(uuid) to authenticated;
grant execute on function public.get_booked_ranges(uuid) to authenticated;

-- ---------------------------------------------------------------------
-- STORAGE: bucket publik untuk foto kendaraan
-- ---------------------------------------------------------------------
insert into storage.buckets (id, name, public)
values ('vehicle-images', 'vehicle-images', true)
on conflict (id) do nothing;
```

### 8.4 Data contoh: `supabase/seed.sql`

```sql
insert into public.vehicles
  (type, brand, name, year, transmission, fuel, seats, price_per_day, description, is_available, image_url)
values
  ('mobil', 'Toyota',     'Avanza',        2022, 'manual', 'bensin', 7, 350000,
   'MPV keluarga yang irit dan lega, nyaman untuk perjalanan dalam maupun luar kota.', true),
  ('mobil', 'Daihatsu',   'Xenia',         2023, 'matic',  'bensin', 7, 380000,
   'Transmisi otomatis membuat perjalanan di kota terasa lebih santai.', true),
  ('mobil', 'Honda',      'Brio',          2023, 'matic',  'bensin', 5, 320000,
   'Mungil dan lincah, mudah diparkir, cocok untuk pemakaian harian.', true),
  ('mobil', 'Toyota',     'Innova Reborn', 2021, 'matic',  'diesel', 7, 600000,
   'Kabin luas dan stabil di jalan jauh, pilihan tepat untuk rombongan keluarga.', true),
  ('mobil', 'Mitsubishi', 'Xpander',       2022, 'matic',  'bensin', 7, 470000,
   'Kabin lapang dengan ground clearance tinggi untuk berbagai kondisi jalan.', true),
  ('mobil', 'Suzuki',     'Ertiga',        2021, 'manual', 'bensin', 7, 400000,
   'Irit bahan bakar dan nyaman untuk tujuh penumpang.', false),
  ('motor', 'Honda',      'Beat',          2023, 'matic',  'bensin', 2,  90000,
   'Ringan dan irit, andalan mobilitas harian di dalam kota.', true),
  ('motor', 'Honda',      'Vario 160',     2023, 'matic',  'bensin', 2, 130000,
   'Tenaga lebih besar dengan bagasi luas untuk kebutuhan harian.', true),
  ('motor', 'Yamaha',     'NMAX',          2022, 'matic',  'bensin', 2, 190000,
   'Skuter besar yang stabil dan nyaman untuk jarak menengah.', true),
  ('motor', 'Honda',      'PCX 160',       2023, 'matic',  'bensin', 2, 210000,
   'Skuter premium dengan posisi berkendara nyaman untuk perjalanan jauh.', true);
```

### 8.5 Pemetaan enum Dart ke database

Nilai enum Dart **identik** dengan string di database sehingga `enum.name` langsung dipakai.

| Enum Dart                   | Nilai                                               |
| --------------------------- | --------------------------------------------------- |
| `VehicleType`               | `mobil`, `motor`                                    |
| `Transmission`              | `manual`, `matic`                                   |
| `FuelType`                  | `bensin`, `diesel`, `listrik`                       |
| `BookingStatus`             | `menunggu`, `dikonfirmasi`, `selesai`, `dibatalkan` |
| `VehicleSort` (hanya klien) | `newest`, `priceAsc`, `priceDesc`                   |

Parsing memakai `parseEnum<T extends Enum>(List<T> values, String raw)` yang melempar `FormatException` bila nilai tidak dikenal.

---

## 9. Kontrak Integrasi Supabase

> Contoh di bawah adalah **pola acuan**. Sebelum memakai API pustaka, agent wajib memverifikasi signature di source paket terpasang (lihat `AGENTS.md` bagian anti-halusinasi).

### 9.1 Inisialisasi

```dart
await Supabase.initialize(
  url: AppEnv.supabaseUrl,
  publishableKey: AppEnv.supabasePublishableKey,
);
```

`supabaseClientProvider = Provider<SupabaseClient>((ref) => Supabase.instance.client);`

### 9.2 Autentikasi

```dart
// Login
await client.auth.signInWithPassword(email: email, password: password);

// Daftar: full_name dibaca trigger handle_new_user
final res = await client.auth.signUp(
  email: email,
  password: password,
  data: {'full_name': fullName},
);
final result = res.session != null ? SignUpResult.signedIn : SignUpResult.needsEmailVerification;

// Keluar
await client.auth.signOut();

// Pantau perubahan sesi (hanya di data layer)
client.auth.onAuthStateChange; // Stream<AuthState>
client.auth.currentSession;    // Session?
```

Domain `AuthRepository` tidak mengekspos tipe Supabase. Kontraknya: `String? get currentUserId`, `Stream<String?> get userIdChanges`, `signIn`, `signUp`, `signOut`. Implementasi memetakan `onAuthStateChange` menjadi `session?.user.id` dengan `.distinct()` agar refresh token berkala tidak memicu pemuatan ulang data. Router dan `currentUserIdProvider` hanya memakai kontrak ini.

### 9.3 Daftar kendaraan dengan filter

Filter diterapkan **sebelum** `.order(...)` karena `.order` mengubah tipe builder.

```dart
var query = _client.from('vehicles').select();

if (filter.type != null) query = query.eq('type', filter.type!.name);
if (filter.transmission != null) query = query.eq('transmission', filter.transmission!.name);
if (filter.onlyAvailable) query = query.eq('is_available', true);
query = query.gte('price_per_day', filter.minPrice).lte('price_per_day', filter.maxPrice);

final keyword = _sanitizeKeyword(filter.query); // buang , ( ) % * dan trim
if (keyword.isNotEmpty) {
  query = query.or('name.ilike.%$keyword%,brand.ilike.%$keyword%');
}

final ordered = switch (filter.sort) {
  VehicleSort.newest    => query.order('created_at', ascending: false),
  VehicleSort.priceAsc  => query.order('price_per_day', ascending: true),
  VehicleSort.priceDesc => query.order('price_per_day', ascending: false),
};
final rows = await ordered.limit(AppConstants.vehicleQueryLimit);
```

> Sanitasi keyword wajib: karakter `,` `(` `)` merusak sintaks filter `or` PostgREST. Batas harga maksimum di slider (`Rp 1.000.000`) berarti "tanpa batas atas": bila `maxPrice == AppConstants.priceFilterMax`, jangan terapkan `.lte`.

### 9.4 Operasi lain

```dart
// Detail kendaraan
await _client.from('vehicles').select().eq('id', id).maybeSingle(); // null → NotFoundFailure

// Buat pesanan
final data = await _client.rpc('create_booking', params: {
  'p_vehicle_id': request.vehicleId,
  'p_start_date': _dateOnly(request.startDate), // 'yyyy-MM-dd'
  'p_end_date': _dateOnly(request.endDate),
  'p_pickup_location': request.pickupLocation,
  'p_notes': request.notes,
});
// data berupa Map (atau List berisi 1 Map): ambil data['id']

// Rentang terisi
await _client.rpc('get_booked_ranges', params: {'p_vehicle_id': vehicleId});

// Riwayat (+ ringkasan kendaraan lewat embed)
await _client
    .from('bookings')
    .select('*, vehicle:vehicles(id, type, brand, name, image_url)')
    .order('created_at', ascending: false)
    .limit(AppConstants.bookingQueryLimit);

// Detail pesanan
await _client
    .from('bookings')
    .select('*, vehicle:vehicles(id, type, brand, name, image_url)')
    .eq('id', id)
    .maybeSingle();

// Batalkan
await _client.rpc('cancel_booking', params: {'p_booking_id': id});

// Profil
await _client.from('profiles').select().eq('id', userId).maybeSingle();
await _client.from('profiles').update({'full_name': name, 'phone': phone}).eq('id', userId);
```

Tanggal dikirim sebagai string `yyyy-MM-dd` (tanpa zona waktu) agar tidak bergeser hari.

### 9.5 Pemetaan error ke pesan pengguna

| Sumber   | Kondisi                                                 | Pesan                                                              |
| -------- | ------------------------------------------------------- | ------------------------------------------------------------------ |
| Auth     | `invalid_credentials` / "Invalid login credentials"     | Email atau kata sandi salah.                                       |
| Auth     | `user_already_exists` / "already registered"            | Email sudah terdaftar.                                             |
| Auth     | `email_not_confirmed`                                   | Email belum diverifikasi. Periksa kotak masuk Anda.                |
| Auth     | `weak_password`                                         | Kata sandi terlalu lemah. Gunakan minimal 8 karakter.              |
| Auth     | batas permintaan                                        | Terlalu banyak percobaan. Coba lagi beberapa saat.                 |
| Postgres | `23P01` (exclusion violation)                           | Kendaraan sudah dipesan pada tanggal tersebut. Pilih tanggal lain. |
| Postgres | `22023`, `P0002`, `28000` (dari RPC)                    | Pakai `message` dari server (sudah berbahasa Indonesia).           |
| Postgres | `42501` (RLS)                                           | Anda tidak memiliki akses untuk tindakan ini.                      |
| Jaringan | `SocketException`, `TimeoutException`, gagal fetch auth | Tidak dapat terhubung ke internet. Periksa koneksi Anda.           |
| Lainnya  | selain di atas                                          | Terjadi kesalahan pada server. Coba lagi beberapa saat.            |

---

## 10. Desain UI/UX

### 10.1 Prinsip

Modern, minimalis, tenang, dan terpercaya. Putih sebagai kanvas, navy sebagai satu-satunya warna identitas. Hirarki dibangun lewat **ukuran, bobot huruf, dan ruang kosong**, bukan dekorasi.

### 10.2 Daftar larangan agar tidak terlihat seperti "AI slop"

| Dilarang                                                       | Gantinya                                                    |
| -------------------------------------------------------------- | ----------------------------------------------------------- |
| Gradasi warna di latar, tombol, atau kartu                     | Warna solid datar                                           |
| Ungu/biru neon, warna aksen acak                               | Hanya palet navy + warna semantik (sukses/peringatan/error) |
| Glassmorphism, blur, bayangan tebal berlapis                   | Kartu putih dengan border 1 px, elevasi 0                   |
| Emoji sebagai ikon atau hiasan teks                            | Ikon Material rounded yang konsisten                        |
| Ilustrasi blob/abstrak generik dan hero "Selamat datang 👋"    | Wordmark tipografi + whitespace                             |
| Teks pemasaran bombastis dan tanda seru berlebihan             | Kalimat singkat, sopan, informatif                          |
| Semua elemen rata tengah dan semua kartu identik tanpa hirarki | Rata kiri, satu aksi utama per layar, judul jelas           |
| Sudut radius berbeda-beda tanpa aturan                         | Hanya radius 8/12/16 sesuai skala                           |
| Banyak ukuran font tanpa sistem                                | Hanya skala tipografi di 10.3                               |
| Ikon dekoratif tanpa fungsi                                    | Ikon hanya bila menambah makna                              |
| Animasi memantul (bounce)/berlebihan                           | Transisi 150–250 ms, kurva `easeOut`                        |
| Placeholder "Lorem ipsum"/data palsu di UI produksi            | Data nyata dari Supabase, placeholder gambar yang dirancang |

### 10.3 Design token

**Warna** (`core/theme/app_colors.dart`):

| Token                   | Hex                   | Pemakaian                                              |
| ----------------------- | --------------------- | ------------------------------------------------------ |
| `white`                 | `#FFFFFF`             | Latar semua layar, kartu                               |
| `navy900`               | `#0A1F44`             | Primer: tombol utama, judul, ikon aktif, teks utama    |
| `navy800`               | `#12305F`             | Tekan/pressed tombol primer                            |
| `navy600`               | `#2A4A7F`             | Ikon sekunder, link, aksen kecil                       |
| `navy100`               | `#DCE4F0`             | Garis/indikator lembut                                 |
| `navy50`                | `#F1F4F9`             | Latar terpilih, indikator navigasi, placeholder gambar |
| `border`                | `#E3E8EF`             | Border kartu dan pemisah                               |
| `borderStrong`          | `#CBD5E1`             | Border input                                           |
| `textSecondary`         | `#5B6B82`             | Teks sekunder (kontras 5.4:1 di atas putih)            |
| `textDisabled`          | `#9AA7B8`             | Hanya untuk elemen nonaktif, bukan teks penting        |
| `success` / `successBg` | `#14683F` / `#E3F4EA` | Status Selesai                                         |
| `warning` / `warningBg` | `#8A5A00` / `#FFF4DB` | Status Menunggu                                        |
| `error` / `errorBg`     | `#C0392B` / `#FDECEA` | Error, validasi                                        |
| `neutralBg`             | `#EEF0F3`             | Status Dibatalkan (teks `textSecondary`)               |

Status pesanan: **Menunggu** = `warning` di atas `warningBg`; **Dikonfirmasi** = `navy900` di atas `navy50`; **Selesai** = `success` di atas `successBg`; **Dibatalkan** = `textSecondary` di atas `neutralBg`. Semua pasangan lulus kontras ≥ 4.5:1.

**Tipografi** (`core/theme/app_typography.dart`): font **Plus Jakarta Sans** lewat `google_fonts`.

| Gaya            | Ukuran/tinggi baris | Bobot | Pemakaian                              |
| --------------- | ------------------- | ----- | -------------------------------------- |
| `headlineSmall` | 24/32               | 700   | Judul layar besar (Beranda, Masuk)     |
| `titleLarge`    | 20/28               | 700   | Judul AppBar, nama kendaraan di detail |
| `titleMedium`   | 16/24               | 600   | Judul kartu, harga                     |
| `bodyLarge`     | 16/24               | 400   | Isi utama, input                       |
| `bodyMedium`    | 14/20               | 400   | Teks sekunder dan spesifikasi          |
| `bodySmall`     | 12/16               | 400   | Keterangan kecil                       |
| `labelLarge`    | 14/20               | 600   | Tombol                                 |
| `labelSmall`    | 11/16               | 600   | Chip/badge, `letterSpacing 0.2`        |

**Spasi dan radius** (`core/theme/app_spacing.dart`): skala 4 dp.

| Token                                         | Nilai                             |
| --------------------------------------------- | --------------------------------- |
| `xs / sm / md / lg / xl / xxl`                | 4 / 8 / 12 / 16 / 24 / 32         |
| Padding horizontal layar                      | 20 dp (16 dp bila lebar < 360 dp) |
| `radiusSm / radiusMd / radiusLg / radiusPill` | 8 / 12 / 16 / 999                 |

**Tema komponen** (acuan nilai; nama class `*ThemeData` mengikuti API `material_ui` terpasang, analyzer sebagai wasit):

| Komponen                           | Spesifikasi                                                                                                                                      |
| ---------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| Latar scaffold                     | `white`                                                                                                                                          |
| AppBar                             | Latar putih, tanpa elevasi dan tanpa tint saat scroll, judul `titleLarge` rata kiri, ikon `navy900`                                              |
| Tombol primer (`FilledButton`)     | Latar `navy900`, teks putih, tinggi 52 dp, radius 12, `labelLarge`; pressed `navy800`; nonaktif memakai `navy900` opasitas 38%                   |
| Tombol sekunder (`OutlinedButton`) | Border 1 px `navy900`, teks `navy900`, tinggi 52, radius 12                                                                                      |
| Tombol teks                        | Teks `navy600`, `labelLarge`                                                                                                                     |
| Input                              | Latar putih, border 1 px `borderStrong`, fokus 1.5 px `navy900`, error 1 px `error`, radius 12, padding isi 16                                   |
| Kartu                              | Latar putih, border 1 px `border`, elevasi 0, radius 16                                                                                          |
| `NavigationBar`                    | Latar putih, border atas 1 px `border`, tinggi 72, indikator `navy50`, ikon/label terpilih `navy900` (label 600), tidak terpilih `textSecondary` |
| Chip filter                        | Radius pill; tidak terpilih: border `border`, teks `textSecondary`; terpilih: latar `navy900`, teks putih                                        |
| SnackBar                           | Latar `navy900`, teks putih, radius 12, `floating`                                                                                               |
| Bottom sheet                       | Radius atas 16, handle 4×36 dp `navy100`                                                                                                         |
| Divider                            | 1 px `border`                                                                                                                                    |
| Tema                               | **Hanya terang.** Set `themeMode: ThemeMode.light`.                                                                                              |

`ColorScheme` dibuat eksplisit (bukan `fromSeed`) agar navy presisi:

```dart
const ColorScheme(
  brightness: Brightness.light,
  primary: AppColors.navy900,
  onPrimary: AppColors.white,
  primaryContainer: AppColors.navy50,
  onPrimaryContainer: AppColors.navy900,
  secondary: AppColors.navy600,
  onSecondary: AppColors.white,
  secondaryContainer: AppColors.navy100,
  onSecondaryContainer: AppColors.navy900,
  error: AppColors.error,
  onError: AppColors.white,
  surface: AppColors.white,
  onSurface: AppColors.navy900,
  onSurfaceVariant: AppColors.textSecondary,
  outline: AppColors.borderStrong,
  outlineVariant: AppColors.border,
  surfaceContainerHighest: AppColors.navy50,
);
```

**Logo:** wordmark teks `RodaKuu` (`Roda` = `navy900`, `Kuu` = `navy600`, bobot 800), tanpa file gambar.

### 10.4 Spesifikasi layar

**Masuk / Daftar** (`AuthScaffold`): konten rata kiri dalam `ResponsiveCenter(maxWidth: 440)` dan `SingleChildScrollView`.

```
RodaKuu                       ← wordmark
Masuk ke akun Anda            ← headlineSmall
Sewa mobil dan motor, tanpa ribet.   ← bodyMedium textSecondary

Email
[ nama@email.com            ]
Kata sandi
[ ••••••••              👁  ]   ← ikon visibility_rounded (toggle)

[           Masuk           ]   ← tombol primer penuh
Belum punya akun? Daftar        ← tombol teks
```

**Beranda (daftar kendaraan):**

```
Halo, Rina                         ← bodyMedium textSecondary
Mau sewa apa hari ini?             ← headlineSmall
[🔍 Cari merek atau nama     ] [⚙ Filter (2)]
( Semua ) ( Mobil ) ( Motor )      ← chip jenis
┌──────────────────────────────┐
│ [foto 16:10]       [ Mobil ] │
│ Toyota Avanza           2022 │
│ Manual • 7 kursi • Bensin    │
│ Rp 350.000 / hari            │
└──────────────────────────────┘
(… kartu berikutnya, satu kolom)
```

(Ikon di wireframe hanya ilustrasi: implementasi memakai ikon Material rounded, bukan emoji.)

**Detail kendaraan:** foto 16:10 penuh lebar dengan tombol kembali bulat putih di atasnya, lalu nama (`titleLarge`), merek • tahun, grid spesifikasi 2 kolom (`SpecItem`: ikon + label + nilai), deskripsi, dan **bar bawah tetap** (putih, border atas): kiri harga + "/ hari", kanan tombol "Pesan Sekarang".

**Form pemesanan:** ringkasan kendaraan (foto kecil 72 dp + nama + harga/hari), `DateRangeField` (ketuk membuka date range picker, tampil "12 Okt – 14 Okt 2026 • 3 hari"), input lokasi pengambilan, input catatan (maks 200), `PriceSummary` (baris: "Rp 350.000 × 3 hari", garis, "Total Rp 1.050.000"), catatan pembayaran, dan tombol "Buat Pesanan" di bar bawah tetap.

**Riwayat pesanan:** judul "Pesanan", `SegmentedButton` Aktif | Selesai, daftar `BookingCard` (foto 56 dp, nama kendaraan, rentang tanggal, total, `BookingStatusChip`).

**Detail pesanan:** chip status besar, blok kendaraan, blok rincian (tanggal, durasi, lokasi, catatan), blok harga, "Dibuat pada …", tombol sekunder "Batalkan Pesanan" (hanya bila `menunggu`).

**Profil:** `ProfileAvatar` (lingkaran `navy900` 72 dp, inisial putih), nama (`titleLarge`), email (`textSecondary`), daftar `ProfileMenuTile` ("Ubah profil", "Keluar" berwarna `error`).

**Ubah profil:** input nama, input telepon, email hanya-baca (disabled), tombol "Simpan".

### 10.5 Aturan responsif (wajib)

1. **Tidak ada lebar/tinggi hardcode** untuk kontainer utama. Gunakan `Expanded`, `Flexible`, `Wrap`, `AspectRatio`, `LayoutBuilder`.
2. **Satu kolom** untuk semua daftar. Pada layar lebar, konten dibatasi `ResponsiveCenter(maxWidth: 640)` dan dipusatkan (form auth 440).
3. Gunakan `SafeArea`. Bar bawah tetap memakai `SafeArea(top: false)` agar tidak tertutup gesture bar.
4. Form wajib bisa di-scroll (`SingleChildScrollView`) dan tidak overflow saat keyboard terbuka.
5. Teks panjang memakai `maxLines` + `TextOverflow.ellipsis` (nama kendaraan maksimal 2 baris). Baris spesifikasi memakai `Wrap`.
6. Batasi skala teks sistem: `MediaQuery.textScaler.clamp(minScaleFactor: 0.85, maxScaleFactor: 1.3)` di `builder` `MaterialApp`.
7. Padding horizontal 20 dp, menjadi 16 dp bila lebar < 360 dp (`context.screenHorizontalPadding`).
8. Gambar: `AspectRatio(16/10)` + `BoxFit.cover`. Placeholder dan error gambar memakai kotak `navy50` dengan ikon kendaraan.

**Matriks ukuran uji (dp):** 320×568, 360×640, 393×852, 412×915, 600×960, dan landscape 852×393. Tidak boleh ada overflow (`RenderFlex overflowed`) pada semua ukuran, dengan skala teks 1.0 dan 1.3.

### 10.6 Aksesibilitas

Target sentuh ≥ 48 dp. Semua `IconButton` punya `tooltip`. Gambar kendaraan punya `semanticLabel`. Status selalu berupa teks. Validasi muncul sebagai teks di bawah field (bukan hanya warna). Urutan fokus keyboard mengikuti urutan visual (`textInputAction`: next/done).

### 10.7 Gaya bahasa (microcopy)

Sapaan formal-ramah memakai **"Anda"**, kalimat singkat, tanpa emoji dan tanpa tanda seru berlebihan.

| Konteks           | Teks                                                                                |
| ----------------- | ----------------------------------------------------------------------------------- |
| Tombol utama      | Masuk • Daftar • Pesan Sekarang • Buat Pesanan • Simpan • Terapkan • Reset          |
| Daftar kosong     | "Kendaraan tidak ditemukan" / "Coba ubah kata kunci atau reset filter."             |
| Riwayat kosong    | "Belum ada pesanan" / "Pesanan Anda akan muncul di sini."                           |
| Error muat        | "Gagal memuat data" / "Periksa koneksi internet Anda lalu coba lagi." + "Coba lagi" |
| Sukses pesan      | "Pesanan berhasil dibuat. Menunggu konfirmasi."                                     |
| Catatan bayar     | "Pembayaran dilakukan langsung saat pengambilan kendaraan."                         |
| Konfirmasi keluar | "Keluar dari akun?" / "Anda perlu masuk lagi untuk memesan kendaraan."              |
| Konfirmasi batal  | "Batalkan pesanan?" / "Pesanan yang dibatalkan tidak dapat dikembalikan."           |
| Label status      | Menunggu konfirmasi • Dikonfirmasi • Selesai • Dibatalkan                           |
| Label transmisi   | Manual • Matic                                                                      |
| Label bahan bakar | Bensin • Diesel • Listrik                                                           |

### 10.8 Gerak

Transisi layar bawaan platform. Animasi mikro (ganti tab, buka bottom sheet) 150–250 ms, `Curves.easeOut`. Tanpa animasi dekoratif yang berjalan terus-menerus.

---

## 11. Daftar Layar dan Routing

| Layar            | Path                   | Terproteksi | Catatan                                                    |
| ---------------- | ---------------------- | ----------- | ---------------------------------------------------------- |
| Masuk            | `/masuk`               | Tidak       |                                                            |
| Daftar           | `/daftar`              | Tidak       |                                                            |
| Beranda (tab 1)  | `/`                    | Ya          | Di dalam `StatefulShellRoute.indexedStack`                 |
| Riwayat (tab 2)  | `/pesanan`             | Ya          | Di dalam shell                                             |
| Detail pesanan   | `/pesanan/:id`         | Ya          | Child dari `/pesanan` (navigasi bawah tetap terlihat)      |
| Profil (tab 3)   | `/profil`              | Ya          | Di dalam shell                                             |
| Ubah profil      | `/profil/ubah`         | Ya          | Child dari `/profil`                                       |
| Detail kendaraan | `/kendaraan/:id`       | Ya          | Rute teratas pada root navigator (menutupi navigasi bawah) |
| Form pemesanan   | `/kendaraan/:id/pesan` | Ya          | Child dari detail kendaraan, root navigator                |

Aturan navigasi:

- Redirect auth: `currentSession == null` dan bukan di `/masuk`/`/daftar` → `/masuk`. `currentSession != null` dan di `/masuk`/`/daftar` → `/`.
- `refreshListenable` diisi `AuthRefreshNotifier` (ChangeNotifier yang mendengarkan `AuthRepository.userIdChanges`). Redirect membaca `AuthRepository.currentUserId`. `routerProvider` memakai `ref.read` untuk repository dan **tidak** me-`watch` provider auth supaya GoRouter tidak dibuat ulang.
- Dari daftar ke detail memakai `context.push`. Setelah pesanan berhasil dibuat gunakan `context.go('/pesanan/$id')` sehingga tumpukan menjadi [Riwayat → Detail pesanan] dan tombol Back kembali ke Riwayat.
- Parameter `:id` dibaca lewat `state.pathParameters['id']`.
- Rute tidak dikenal menampilkan halaman "Halaman tidak ditemukan" dengan tombol kembali ke Beranda (`errorBuilder`).

---

## 12. Konfigurasi Proyek

### 12.1 Pembuatan proyek

```bash
flutter --version          # pastikan 3.47.x, Dart 3.13.x
flutter create --org id.rodakuu --project-name rodakuu --platforms=android .
flutter pub add material_ui supabase_flutter flutter_riverpod go_router google_fonts cached_network_image intl
```

Application ID hasilnya: `id.rodakuu.rodakuu`.

### 12.2 `pubspec.yaml` (acuan akhir)

```yaml
name: rodakuu
description: Aplikasi rental mobil dan motor RodaKuu.
publish_to: "none"
version: 1.0.0+1

environment:
  sdk: ^3.13.0
  flutter: ">=3.47.0"

dependencies:
  flutter:
    sdk: flutter
  material_ui: ^1.6.0
  supabase_flutter: ^2.18.2
  flutter_riverpod: ^3.4.3
  go_router: ^18.0.2
  google_fonts: ^9.0.0
  cached_network_image: ^4.0.4
  intl: ^0.20.3

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0

flutter:
  uses-material-design: true
```

Constraint `sdk` harus disesuaikan dengan versi Dart sebenarnya dari `flutter --version`. Jangan menebak.

### 12.3 `env.example.json` dan `env.json`

```json
{
  "SUPABASE_URL": "https://xxxxxxxxxxxx.supabase.co",
  "SUPABASE_PUBLISHABLE_KEY": "sb_publishable_xxxxxxxxxxxxxxxxxxxx"
}
```

`env.json` berformat sama dengan nilai asli dan masuk `.gitignore`. Bila `env.json` belum ada, aplikasi **tidak boleh crash**: tampilkan `ConfigErrorView` ("Konfigurasi belum lengkap. Isi env.json lalu jalankan ulang.").

### 12.4 Android (`android/app/src/main/AndroidManifest.xml`)

- Tambahkan **tepat di dalam `<manifest>`, sebelum `<application>`**:
  ```xml
  <uses-permission android:name="android.permission.INTERNET"/>
  ```
  Template hanya menambahkannya untuk build debug/profile. Tanpa baris ini, APK **release** tidak dapat mengakses jaringan.
- Ubah `android:label` menjadi `RodaKuu`.
- Jangan mengubah versi AGP, Kotlin, Gradle, maupun `compileSdk`/`targetSdk`/`minSdk`.

### 12.5 `analysis_options.yaml`

```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  language:
    strict-casts: true
    strict-raw-types: true

linter:
  rules:
    - prefer_const_constructors
    - prefer_const_declarations
    - prefer_final_locals
    - always_declare_return_types
    - avoid_print
    - unawaited_futures
    - use_build_context_synchronously
    - directives_ordering
```

(Jika analyzer menolak sebuah aturan sebagai tidak dikenal, hapus baris itu dan catat di `PROGRESS.md`.)

### 12.6 `.gitignore` (tambahan)

```
env.json
*.jks
key.properties
```

### 12.7 Perintah harian

```bash
flutter pub get
dart format .
flutter analyze
flutter test
flutter run --dart-define-from-file=env.json
flutter build apk --debug   --dart-define-from-file=env.json
flutter build apk --release --dart-define-from-file=env.json
# Hasil: build/app/outputs/flutter-apk/app-release.apk
```

---

## 13. Strategi Pengujian dan QA

### 13.1 Piramida pengujian

| Level     | Cakupan                                                                                                                                                                              | Alat           |
| --------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | -------------- |
| Unit      | Validators, formatters, `BookingCalculator`, `VehicleFilter` (equality + copyWith), `mapToFailure`, parsing DTO                                                                      | `flutter_test` |
| Widget    | Layar login/daftar, daftar kendaraan (data/kosong/error), detail, form pemesanan, riwayat, ubah profil. Repository diganti **fake** tulisan tangan melalui `ProviderScope.overrides` | `flutter_test` |
| Responsif | Setiap layar utama di-render pada matriks ukuran 10.5 dan skala teks 1.0/1.3, lalu `expect(tester.takeException(), isNull)`                                                          | `flutter_test` |
| Manual    | Skrip UAT 13.3 pada emulator/perangkat                                                                                                                                               | Manusia/Agent  |

Catatan teknis pengujian:

- Tema untuk test: `AppTheme.light(useGoogleFonts: false)` supaya tidak ada pengunduhan font saat test.
- Test tidak boleh menyentuh `Supabase.instance`. Seluruh akses data melalui provider repository yang di-override.
- Rupiah dari `intl` bisa memakai spasi non-breaking (`\u00A0`). Test membandingkan setelah `replaceAll('\u00A0', ' ')`.
- Jika tipe `Override` tidak ter-export dari `flutter_riverpod.dart`, impor dari `package:flutter_riverpod/misc.dart`.

### 13.2 Kasus uji minimum

| ID      | Kasus                                                                | Hasil yang diharapkan                                                    |
| ------- | -------------------------------------------------------------------- | ------------------------------------------------------------------------ |
| T-UT-01 | `Validators.email` dengan "a", "a@b", "a@b.com"                      | Dua pertama gagal, terakhir lolos                                        |
| T-UT-02 | `Validators.password` panjang 7 dan 8                                | 7 gagal, 8 lolos                                                         |
| T-UT-03 | `Validators.phone` "", "08123456789", "+628123456789", "0812", "abc" | Kosong lolos (opsional), dua valid lolos, dua terakhir gagal             |
| T-UT-04 | `formatRupiah(350000)`                                               | "Rp 350.000"                                                             |
| T-UT-05 | `BookingCalculator.totalDays` 1–1 Okt dan 1–3 Okt                    | 1 dan 3                                                                  |
| T-UT-06 | `BookingCalculator.totalPrice` 350000 × 3                            | 1.050.000                                                                |
| T-UT-07 | `VehicleFilter` dua instance sama                                    | `==` true dan `hashCode` sama                                            |
| T-UT-08 | `VehicleFilter.copyWith` mengosongkan `type`                         | `type` menjadi null                                                      |
| T-UT-09 | `mapToFailure(PostgrestException(code: '23P01'))`                    | Pesan tabrakan tanggal                                                   |
| T-UT-10 | `mapToFailure(SocketException)`                                      | `NetworkFailure`                                                         |
| T-UT-11 | `VehicleDto.fromJson` data valid dan nilai enum tak dikenal          | Entity benar / `FormatException`                                         |
| T-UT-12 | `BookingDto.fromJson` dengan embed `vehicle`                         | `Booking.vehicle` terisi                                                 |
| T-WT-01 | Login: submit kosong                                                 | Pesan validasi tampil, repository tidak dipanggil                        |
| T-WT-02 | Login: kredensial salah (fake melempar `AuthFailure`)                | SnackBar pesan error tampil                                              |
| T-WT-03 | Daftar: konfirmasi kata sandi beda                                   | Pesan validasi tampil                                                    |
| T-WT-04 | Daftar: fake mengembalikan `needsEmailVerification`                  | Pesan verifikasi tampil                                                  |
| T-WT-05 | Daftar kendaraan: data                                               | Kartu tampil dengan harga terformat                                      |
| T-WT-06 | Daftar kendaraan: kosong                                             | "Kendaraan tidak ditemukan" + tombol Reset filter                        |
| T-WT-07 | Daftar kendaraan: error                                              | "Gagal memuat data" + tombol Coba lagi memanggil ulang repository        |
| T-WT-08 | Pilih chip "Motor"                                                   | Filter di provider berubah dan repository dipanggil dengan `type: motor` |
| T-WT-09 | Detail kendaraan `is_available = false`                              | Tombol "Tidak tersedia" nonaktif                                         |
| T-WT-10 | Form pesanan: pilih rentang 3 hari                                   | Ringkasan "× 3 hari" dan total benar                                     |
| T-WT-11 | Form pesanan: rentang bertabrakan dengan fake booked range           | Pesan "Tanggal bertabrakan…" dan tombol nonaktif                         |
| T-WT-12 | Form pesanan: submit sukses                                          | Repository dipanggil dengan parameter benar                              |
| T-WT-13 | Riwayat: tab Aktif vs Selesai                                        | Daftar terfilter sesuai status                                           |
| T-WT-14 | Detail pesanan `menunggu`                                            | Tombol "Batalkan Pesanan" tampil; pada status lain tidak tampil          |
| T-WT-15 | Ubah profil: nama 1 huruf                                            | Pesan validasi tampil                                                    |
| T-RS-01 | Semua layar pada 6 ukuran × 2 skala teks                             | Tidak ada exception overflow                                             |

### 13.3 Skrip UAT manual (emulator/perangkat dengan `env.json` asli)

1. Buka aplikasi pertama kali → layar Masuk tampil.
2. Daftar dengan data valid → masuk ke Beranda dan nama tampil di sapaan.
3. Tutup paksa dan buka lagi → tetap di Beranda (sesi persisten).
4. Beranda menampilkan 10 kendaraan contoh. Ertiga berlabel "Tidak tersedia".
5. Ketik "avanza" → hanya Avanza tampil. Hapus → semua kembali.
6. Pilih chip "Motor" → hanya motor. Buka Filter: transmisi Matic, harga maks Rp 150.000, Terapkan → hasil sesuai. Reset → pulih.
7. Urutkan "Harga terendah" → urutan harga naik.
8. Buka detail Avanza → semua informasi tampil, "Pesan Sekarang" aktif.
9. Pesan: pilih 3 hari ke depan, isi lokasi → total = 3 × harga. Buat Pesanan → detail pesanan berstatus Menunggu konfirmasi.
10. Pesan Avanza lagi dengan rentang beririsan → ditolak dengan pesan tabrakan tanggal.
11. Tab Pesanan → pesanan ada di "Aktif". Batalkan → pindah ke "Selesai" dengan status Dibatalkan.
12. Di Supabase Dashboard ubah status pesanan lain menjadi `dikonfirmasi` lalu `selesai` → tampilan di aplikasi ikut berubah setelah tarik-untuk-muat-ulang.
13. Tab Profil → Ubah profil → simpan nama dan telepon → tampil terbarui.
14. Matikan internet (mode pesawat) → buka Beranda → pesan error + "Coba lagi"; hidupkan internet → Coba lagi berhasil.
15. Keluar → dialog konfirmasi → Masuk tampil; tombol Back tidak kembali ke Beranda.
16. Masuk dengan akun berbeda → data riwayat/profil milik akun baru (bukan sisa akun lama).
17. Ulangi langkah 1–9 pada lebar layar kecil (320 dp) dan skala font terbesar sistem → tidak ada teks terpotong atau overflow.

---

## 14. Definition of Done (DoD)

Aplikasi dinyatakan **selesai** hanya jika **semua** butir berikut terpenuhi dan terbukti lewat output perintah nyata:

| #   | Kriteria                                                                                                                                               | Bukti                                                                                     |
| --- | ------------------------------------------------------------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------- |
| 1   | Semua FR di bagian 4 terimplementasi sesuai acceptance criteria                                                                                        | Tabel keterlacakan FR → file → test di `docs/PROGRESS.md`                                 |
| 2   | Semua file pada pohon 7.3 ada dan terpakai (tidak ada file yatim)                                                                                      | Perintah cek kelengkapan di `AGENTS.md`                                                   |
| 3   | `dart format --set-exit-if-changed .` lolos                                                                                                            | Output exit code 0                                                                        |
| 4   | `flutter analyze` → **No issues found**                                                                                                                | Output perintah                                                                           |
| 5   | `flutter test` → semua lulus, termasuk T-RS-01                                                                                                         | Output perintah                                                                           |
| 6   | `flutter build apk --debug` sukses                                                                                                                     | Path APK                                                                                  |
| 7   | `flutter build apk --release` sukses                                                                                                                   | Path APK                                                                                  |
| 8   | Tidak ada `TODO`, `FIXME`, `print(`, `withOpacity`, import `flutter/material.dart`/`flutter/cupertino.dart`, atau `service_role` di `lib/` dan `test/` | Output `grep` kosong                                                                      |
| 9   | `AndroidManifest.xml` berisi izin INTERNET dan label `RodaKuu`                                                                                         | Isi file                                                                                  |
| 10  | SQL `0001_init.sql` dan `seed.sql` lengkap dan konsisten dengan kode (nama tabel/kolom/RPC/kode error)                                                 | Review silang tercatat                                                                    |
| 11  | Aplikasi dijalankan di emulator/perangkat dan skrip UAT 13.3 lulus                                                                                     | Catatan hasil per langkah, atau pernyataan jujur bahwa belum dijalankan beserta alasannya |
| 12  | Tanpa `env.json`, aplikasi menampilkan `ConfigErrorView` dan tidak crash                                                                               | Test/uji manual                                                                           |

> **Pernyataan jujur wajib:** verifikasi end-to-end terhadap backend nyata (butir 11) hanya mungkin bila `env.json` asli tersedia dan SQL sudah dijalankan di proyek Supabase pemilik. Bila tidak tersedia, agent wajib menyatakannya apa adanya dan **tidak boleh** mengklaim "sudah berjalan".

---

## 15. Rencana Implementasi (Milestone)

Detail langkah, gerbang verifikasi, dan template ada di `AGENTS.md`.

| Milestone | Isi                                                                      | Gerbang keluar                                               |
| --------- | ------------------------------------------------------------------------ | ------------------------------------------------------------ |
| M0        | Pra-pemeriksaan toolchain, scaffold, dependency, konfigurasi, build awal | `flutter analyze` bersih, `flutter build apk --debug` sukses |
| M1        | Core: env, error, tema, utils, widget generik, bootstrap                 | Unit test core lulus                                         |
| M2        | Backend: `0001_init.sql`, `seed.sql`, petunjuk setup                     | Review SQL silang dengan 8.x dan 9.x                         |
| M3        | Auth + router + shell                                                    | Test auth lulus, analyzer bersih                             |
| M4        | Kendaraan: daftar, filter, detail                                        | Test kendaraan lulus                                         |
| M5        | Pemesanan: form, kalkulator, riwayat, detail, pembatalan                 | Test pemesanan lulus                                         |
| M6        | Profil                                                                   | Test profil lulus                                            |
| M7        | Polesan: responsif, aksesibilitas, state kosong/error, audit teks        | T-RS-01 lulus                                                |
| M8        | QA akhir dan build APK release                                           | Seluruh DoD terpenuhi                                        |

---

## 16. Risiko dan Mitigasi

| Risiko                                                            | Dampak                                 | Mitigasi                                                                                     |
| ----------------------------------------------------------------- | -------------------------------------- | -------------------------------------------------------------------------------------------- |
| Patch Flutter 3.47.6 belum terpasang di mesin                     | Build berbeda dari yang diuji          | Pastikan `flutter --version` menunjukkan 3.47.x. Jika patch berbeda, catat di `PROGRESS.md`. |
| API Riverpod 3 / `material_ui` berbeda dari ingatan               | Error kompilasi                        | Verifikasi dari source paket terpasang, bukan dari ingatan (lihat `AGENTS.md`).              |
| Mencampur `flutter/material.dart` dengan `material_ui`            | Error tipe dan impor ambigu            | Larangan keras + pengecekan `grep` pada DoD.                                                 |
| Izin INTERNET tidak ada pada release                              | APK release tidak bisa memuat data     | Butir DoD #9.                                                                                |
| Pemesanan ganda                                                   | Data ganda, perselisihan pelanggan     | Exclusion constraint di database.                                                            |
| Manipulasi harga dari klien                                       | Kerugian bisnis                        | Harga dihitung di RPC, tidak ada policy tulis langsung.                                      |
| Retry otomatis Riverpod 3 membuat loading terlalu lama saat error | UX buruk                               | `retry` dimatikan global.                                                                    |
| Email verification aktif                                          | Pengguna baru bingung                  | Alur FR-AUTH-01 menangani; disarankan nonaktif untuk MVP.                                    |
| Font gagal diunduh saat pertama kali                              | Tampilan sementara memakai font bawaan | Diterima untuk MVP; opsi lanjutan: bundel font sebagai asset.                                |
| Tidak ada foto kendaraan                                          | Tampilan kurang menarik                | Placeholder yang dirancang + petunjuk unggah foto (8.2).                                     |
| Daftar tanpa pagination                                           | Lambat bila data > 200                 | Dibatasi `limit`; pagination dicatat sebagai saran lanjutan.                                 |

---

## 17. Lampiran

### 17.1 Glosarium

| Istilah         | Arti                                                                         |
| --------------- | ---------------------------------------------------------------------------- |
| RLS             | Row Level Security, aturan akses per baris di Postgres                       |
| RPC             | Remote Procedure Call, di sini fungsi Postgres yang dipanggil lewat Supabase |
| DTO             | Data Transfer Object, representasi data mentah dari/ke server                |
| Publishable key | Kunci publik Supabase yang aman ada di aplikasi klien (dilindungi RLS)       |
| Inklusif        | Hari mulai dan hari selesai sama-sama dihitung                               |

### 17.2 Sumber verifikasi versi (diakses 11 Oktober 2026)

- Flutter 3.47: https://flutter.dev/blog/whats-new-in-flutter-3-47
- Versi stabil Flutter 3.47.x dan Dart 3.13: https://docs.shorebird.dev/getting-started/flutter-version.md
- https://pub.dev/packages/material_ui
- https://pub.dev/packages/supabase_flutter
- https://pub.dev/packages/flutter_riverpod
- https://pub.dev/packages/go_router
- https://pub.dev/packages/google_fonts
- https://pub.dev/packages/cached_network_image
- https://pub.dev/packages/intl
- https://pub.dev/packages/flutter_lints

> Versi pada 6.1 adalah posisi per 11 Oktober 2026. Jika `flutter pub add` menghasilkan versi minor/patch yang lebih baru, gunakan versi tersebut sesuai aturan 6.3.
