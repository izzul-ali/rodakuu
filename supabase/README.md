# Panduan Pengaturan Supabase RodaKuu

Langkah-langkah penyiapan proyek backend Supabase:

1. **Buat Proyek Supabase:**
   - Masuk ke dashboard Supabase (https://supabase.com/dashboard) dan buat proyek baru.
   - Buka menu *Project Settings -> API Keys*. Salin **Project URL** dan **Publishable Key** (sb_publishable_...).

2. **Konfigurasi Autentikasi:**
   - Masuk ke menu *Authentication -> Providers -> Email*.
   - Pastikan Email provider aktif.
   - (Rekomendasi MVP) Nonaktifkan opsi *Confirm email* agar akun langsung aktif setelah registrasi, atau biarkan aktif bila ingin alur verifikasi email.

3. **Jalankan Skrip SQL:**
   - Buka menu *SQL Editor*.
   - Jalankan seluruh isi berkas `supabase/migrations/0001_init.sql` (membuat tabel, trigger `profiles`, constraint overlap, RLS, RPC `create_booking`, `cancel_booking`, `get_booked_ranges`, dan storage bucket `vehicle-images`).
   - Jalankan seluruh isi berkas `supabase/seed.sql` untuk memasukkan data 10 kendaraan contoh.

4. **Konfigurasi Berkas Lingkungan Lokal:**
   - Salin `env.example.json` menjadi `env.json`.
   - Masukkan `SUPABASE_URL` dan `SUPABASE_PUBLISHABLE_KEY`.
   - Jalankan aplikasi dengan:
     `flutter run --dart-define-from-file=env.json`

5. **(Opsional) Unggah Foto Kendaraan:**
   - Masuk ke menu *Storage -> vehicle-images*.
   - Unggah gambar kendaraan dan perbarui kolom `image_url` pada tabel `vehicles` dengan URL publik gambar tersebut.
