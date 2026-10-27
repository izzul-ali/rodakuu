/// Teks antarmuka yang digunakan di beberapa tempat dalam aplikasi.
abstract final class AppStrings {
  static const String appName = 'RodaKuu';
  static const String tagline = 'Sewa mobil dan motor, tanpa ribet.';

  // Tombol aksi umum
  static const String actionLogin = 'Masuk';
  static const String actionRegister = 'Daftar';
  static const String actionOrderNow = 'Pesan Sekarang';
  static const String actionCreateBooking = 'Buat Pesanan';
  static const String actionSave = 'Simpan';
  static const String actionApply = 'Terapkan';
  static const String actionReset = 'Reset';
  static const String actionCancel = 'Batal';
  static const String actionLogout = 'Keluar';
  static const String actionRetry = 'Coba lagi';
  static const String actionBackToHome = 'Kembali ke Beranda';

  // Status dan pesan umum
  static const String statusWaiting = 'Menunggu konfirmasi';
  static const String statusConfirmed = 'Dikonfirmasi';
  static const String statusCompleted = 'Selesai';
  static const String statusCancelled = 'Dibatalkan';

  static const String emptyVehiclesTitle = 'Kendaraan tidak ditemukan';
  static const String emptyVehiclesSubtitle =
      'Coba ubah kata kunci atau reset filter.';
  static const String emptyBookingsTitle = 'Belum ada pesanan';
  static const String emptyBookingsSubtitle =
      'Pesanan Anda akan muncul di sini.';

  static const String errorLoadTitle = 'Gagal memuat data';
  static const String errorLoadSubtitle =
      'Periksa koneksi internet Anda lalu coba lagi.';

  static const String bookingSuccessMessage =
      'Pesanan berhasil dibuat. Menunggu konfirmasi.';
  static const String paymentNotice =
      'Pembayaran dilakukan langsung saat pengambilan kendaraan.';

  static const String logoutConfirmTitle = 'Keluar dari akun?';
  static const String logoutConfirmMessage =
      'Anda perlu masuk lagi untuk memesan kendaraan.';

  static const String cancelBookingConfirmTitle = 'Batalkan pesanan?';
  static const String cancelBookingConfirmMessage =
      'Pesanan yang dibatalkan tidak dapat dikembalikan.';

  static const String profileUpdatedMessage = 'Profil diperbarui.';
}
