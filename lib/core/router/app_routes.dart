/// Konstanta jalur rute URL aplikasi RodaKuu.
abstract final class AppRoutes {
  static const String home = '/';
  static const String login = '/masuk';
  static const String register = '/daftar';
  static const String bookings = '/pesanan';
  static const String profile = '/profil';
  static const String editProfile = '/profil/ubah';

  static String vehicleDetail(String id) => '/kendaraan/$id';
  static String bookingForm(String id) => '/kendaraan/$id/pesan';
  static String bookingDetail(String id) => '/pesanan/$id';
}
