# RodaKuu — Aplikasi Rental Mobil & Motor

Aplikasi mobile Android untuk penyewaan mobil dan motor yang praktis, transparan, dan andal. Dibangun menggunakan **Flutter 3.47.x**, **Dart 3.13.x**, **Riverpod 3**, dan backend **Supabase** (Postgres, Auth, Storage).

---

## 1. Tujuan Aplikasi

RodaKuu dirancang untuk mengatasi hambatan utama dalam proses rental kendaraan konvensional:

- **Transparansi Ketersediaan & Tarif:** Pengguna tidak perlu lagi bertanya ketersediaan armada dan rincian harga satu per satu melalui pesan instan. Semua informasi harga per hari dan spesifikasi kendaraan disajikan secara terbuka dan real-time.
- **Pencegahan Pemesanan Ganda (*Double Booking*):** Sistem menerapkan *exclusion constraint* di level basis data PostgreSQL untuk menjamin tidak ada dua penyewa yang dapat memesan kendaraan yang sama pada rentang tanggal yang beririsan.
- **Alur Pemesanan Cepat & Jelas:** Tanpa kerumitan *payment gateway* pada tahap MVP. Biaya dihitung transparan di server, pesanan tercatat otomatis, dan pembayaran diselesaikan secara langsung saat serah terima kendaraan.

---

## 2. Target Pengguna

- **Penyewa Individu:** Mahasiswa, karyawan, wisatawan, maupun keluarga berusia 18–50 tahun di Indonesia.
- **Kebutuhan Penggunaan:** Mobilitas harian dalam kota (motor/mobil lincah) hingga perjalanan luar kota/wisata keluarga (MPV kapasitas 7 penumpang).
- **Spesifikasi Perangkat:** Pengguna smartphone Android dengan sistem operasi Android 7.0 (Nougat / API 24) ke atas.

---

## 3. Fitur Utama

### 3.1 Autentikasi Pengguna
- **Registrasi Akun:** Validasi email, nama lengkap, dan kata sandi minimal 8 karakter. Profil pengguna dibuat otomatis di basis data via trigger.
- **Masuk (Login):** Autentikasi aman berbasis Supabase Auth dengan penanganan error ramah pengguna.
- **Sesi Persisten:** Sesi login tersimpan aman di perangkat sehingga pengguna tidak perlu login berulang kali saat membuka aplikasi.
- **Keluar (Logout):** Tombol logout di halaman profil dilengkapi dialog konfirmasi pencegahan ketidaksengajaan.

### 3.2 Katalog & Eksplorasi Kendaraan
- **Katalog Terpadu:** Menampilkan armada mobil dan motor dengan foto, tipe transmisi, kapasitas kursi, jenis bahan bakar, tahun, dan tarif sewa per hari.
- **Pencarian Real-Time:** Pencarian berdasarkan nama atau merek armada dengan mekanisme *debounce* 400 ms untuk efisiensi beban server.
- **Filter Kategori & Transmisi:** Filter instan jenis armada (*Semua*, *Mobil*, *Motor*) serta *bottom sheet* filter lanjutan (rentang harga, transmisi otomatis/manual, dan filter ketersediaan).
- **Pengurutan Fleksibel:** Pengurutan armada berdasarkan *Terbaru*, *Harga Terendah*, atau *Harga Tertinggi*.
- **State Visual Responsif:** Penanganan state lengkap meliputi *Skeleton Loading*, *Empty View* (jika armada tidak ditemukan), *Error View* dengan tombol coba lagi, serta *Pull-to-Refresh*.

### 3.3 Detail Kendaraan
- Menampilkan foto armada rasio 16:10 penuh lebar, lencana tipe kendaraan, grid spesifikasi teknis, deskripsi kendaraan, tarif harian, serta tombol aksi *"Pesan Sekarang"*.
- Status kendaraan yang sedang tidak tersedia (*is_available = false*) ditandai dengan lencana khusus dan tombol pemesanan dinonaktifkan.

### 3.4 Formulir Pemesanan & Validasi
- **Pemilihan Tanggal Sewa:** Kalender rentang tanggal (*Date Range Picker*) dengan batas durasi maksimal 30 hari dan deteksi otomatis jadwal yang telah terisi (*booked ranges*).
- **Kalkulasi Biaya Transparan:** Perhitungan total hari sewa secara inklusif dan total biaya yang diverifikasi ulang di sisi server (*server-side calculation*).
- **Input Lokasi & Catatan:** Input lokasi penjemputan armada serta catatan opsional untuk pemilik rental.
- **Pemberitahuan Pembayaran:** Catatan pembayaran langsung saat pengambilan kendaraan (*cash/transfer on pickup*).

### 3.5 Riwayat & Detail Pesanan
- **Manajemen Riwayat Pesanan:** Pengelompokan transaksi ke dalam tab **Aktif** (*Menunggu konfirmasi*, *Dikonfirmasi*) dan **Selesai** (*Selesai*, *Dibatalkan*).
- **Detail Transaksi:** Rincian lengkap pesanan mencakup kode booking, identitas kendaraan, rentang waktu sewa, lokasi pengambilan, rincian pembayaran, dan waktu pembuatan.
- **Pembatalan Pesanan:** Opsi pembatalan pesanan yang aman dengan dialog konfirmasi, berlaku khusus untuk pesanan berstatus *Menunggu konfirmasi*.

### 3.6 Profil Pengguna
- Menampilkan avatar inisial nama, nama lengkap, alamat email terdaftar, dan nomor telepon.
- Menu **Ubah Profil** untuk memperbarui nama dan nomor kontak sewaktu-waktu.

---

## 4. Alur Pengguna (User Flow)

```
[Buka Aplikasi]
       │
       ├─ Belum Login ──► Layar Masuk ──► (Belum punya akun?) ──► Layar Daftar ──► (Otomatis Masuk)
       │                      │
       └─ Sesi Aktif ◄────────┘
             │
             ▼
     [Katalog Beranda] ◄────────────────────────────────────────┐
             │                                                  │
             ├─ Cari merek/nama armada (debounce 400ms)         │
             ├─ Filter jenis (Semua / Mobil / Motor)            │
             └─ Filter transmisi, harga & ketersediaan          │
                     │                                          │
                     ▼                                          │
             [Detail Kendaraan]                                 │
                     │                                          │
                     ▼                                          │
             [Form Pemesanan]                                   │
             • Pilih rentang tanggal sewa (1–30 hari)           │
             • Masukkan lokasi pengambilan                      │
             • Masukkan catatan tambahan                        │
             • Periksa kalkulasi total biaya                    │
                     │                                          │
                     ▼                                          │
             [Detail Pesanan] (Status: Menunggu konfirmasi)     │
                     │                                          │
                     ├─ (Opsional) Batalkan Pesanan ────────────┤
                     │                                          │
                     ▼                                          │
     [Tab Pesanan / Riwayat] ◄──────────────────────────────────┘
     • Tab Aktif: Pesanan berjalan
     • Tab Selesai: Pesanan tuntas & dibatalkan
             │
             ▼
     [Tab Profil] ──► Ubah Profil / Keluar (Logout)
```

---

## 5. Batasan Pengujian (Testing Scope & Boundaries)

### 5.1 Ruang Lingkup Pengujian yang Dicakup
- **Unit Testing:**
  - Pengujian logika validator (*email*, *password*, *phone*, *fullName*, *pickupLocation*).
  - Pengujian formatter (*formatRupiah*, *formatDate*, *formatDateRange*, *toDateOnlyString*).
  - Pengujian kalkulator sewa (*BookingCalculator* total hari inklusif dan total harga).
  - Pengujian filter armada (*VehicleFilter* equality, copyWith, active filter count).
  - Pengujian pemetaan error (*ErrorMapper* dari Postgres/Auth/Socket ke *AppFailure*).
  - Pengujian serialisasi & deserialisasi DTO (*VehicleDto*, *BookingDto*, *ProfileDto*).
- **Widget Testing:**
  - Validasi UI dan form pada layar Login, Register, Daftar Kendaraan, Detail Kendaraan, Form Pemesanan, Riwayat Pesanan, dan Ubah Profil menggunakan *fake repository* terisolasi.
- **Responsive Layout Testing (T-RS-01):**
  - Pengujian bebas luapan teks (*no overflow*) pada 9 layar utama di 6 variasi dimensi layar (320×568 hingga tablet 600×960 dan lanskap 852×393) serta 2 skala teks (1.0x dan 1.3x).
- **End-to-End (E2E) Testing (Maestro):**
  - Skenario otomatis pengujian 4 modul utama secara terintegrasi: Autentikasi (`01_auth.yaml`), Katalog Kendaraan (`02_vehicles.yaml`), Pemesanan & Pembatalan (`03_booking.yaml`), serta Riwayat & Profil (`04_history_profile.yaml`).

### 5.2 Batasan & Hal di Luar Lingkup (Out of Scope MVP)
- **Payment Gateway:** Tidak menguji integrasi payment gateway pihak ketiga (Midtrans/Xendit). Pembayaran diasumsikan manual di luar sistem.
- **Aplikasi Khusus Admin:** Manajemen armada dan persetujuan pesanan dilakukan langsung via dashboard Supabase.
- **Fitur Eksternal:** Tidak mencakup pengujian login sosial (OAuth Google/Apple), reset sandi via SMS/OTP, notifikasi push (FCM), GPS penjemputan peta real-time, ulasan/rating, maupun mode gelap (*dark mode*).

---

## 6. Panduan Menjalankan Aplikasi

Pastikan sistem Anda telah terpasang:
- **Flutter SDK:** versi `3.47.x` (Dart `3.13.x`)
- **Java:** JDK 17
- **Android SDK:** platform Android terpasang dengan lisensi diterima

### Langkah 1: Konfigurasi Database Supabase
Sesuai petunjuk pada [`supabase/README.md`](supabase/README.md):
1. Buat proyek baru di [Supabase Dashboard](https://supabase.com/dashboard).
2. Salin **Project URL** dan **Publishable Key** dari menu *Project Settings -> API Keys*.
3. Buka menu *SQL Editor* di Supabase Dashboard:
   - Jalankan seluruh isi berkas [`supabase/migrations/0001_init.sql`](supabase/migrations/0001_init.sql) untuk menginisialisasi skema tabel, fungsi RPC, RLS, dan storage.
   - Jalankan seluruh isi berkas [`supabase/seed.sql`](supabase/seed.sql) untuk mengisi data awal 10 kendaraan contoh.
4. Pada menu *Authentication -> Providers -> Email*, pastikan provider Email aktif (opsi *Confirm email* dapat dinonaktifkan untuk kemudahan pengujian MVP).

### Langkah 2: Konfigurasi Variabel Lingkungan Lokal
Salin template berkas konfigurasi lingkungan:

```bash
cp env.example.json env.json
```

Buka `env.json` dan isi dengan kredensial proyek Supabase Anda:

```json
{
  "SUPABASE_URL": "https://xxxxxxxxxxxx.supabase.co",
  "SUPABASE_PUBLISHABLE_KEY": "sb_publishable_xxxxxxxxxxxxxxxxxxxx"
}
```

> **Catatan Keamanan:** Berkas `env.json` telah dimasukkan ke dalam `.gitignore` agar kredensial API tidak terunggah ke repositori publik.

### Langkah 3: Menjalankan Aplikasi di Emulator / Perangkat
Pastikan emulator Android sudah berjalan atau perangkat fisik Android terhubung dengan mode USB Debugging aktif.

Jalankan perintah berikut:

```bash
flutter run --dart-define-from-file=env.json
```

Aplikasi akan otomatis mengompilasi dan menginisialisasi koneksi ke Supabase sesuai konfigurasi lingkungan.

---

## 7. Menjalankan Pengujian

### 7.1 Unit & Widget Test (51 Skenario Uji)
Jalankan seluruh pengujian unit, widget, dan audit tata letak responsif:

```bash
flutter test
```

### 7.2 Pemeriksaan Kualitas Kode & Analisis Statis
Pastikan format kode dan analisis statis bersih (0 issue):

```bash
dart format --set-exit-if-changed .
flutter analyze
```

### 7.3 Pengujian Otomatis Maestro (E2E)
Jalankan skrip pengujian Maestro saat emulator/perangkat sedang menjalankan aplikasi:

```bash
maestro test maestro.yaml
```

Atau jalankan skrip per modul fitur:
- `maestro test flows/01_auth.yaml`
- `maestro test flows/02_vehicles.yaml`
- `maestro test flows/03_booking.yaml`
- `maestro test flows/04_history_profile.yaml`

---

## 8. Lisensi & Hak Cipta

Proyek ini dikembangkan sebagai bagian dari sistem aplikasi rental kendaraan **RodaKuu**. Seluruh kode sumber mematuhi arsitektur bersih (*clean architecture*) dan standar pengujian perangkat bergerak (*mobile testing*).
