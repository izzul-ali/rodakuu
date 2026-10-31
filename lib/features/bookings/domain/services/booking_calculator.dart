/// Layanan kalkulator bisnis murni untuk perhitungan hari dan total harga sewa.
abstract final class BookingCalculator {
  /// Menghitung jumlah hari sewa secara inklusif (tanggal mulai dan selesai sama-sama dihitung).
  /// Menggunakan [DateTime.utc] untuk menghindari efek selisih jam dan zona waktu.
  static int totalDays(DateTime start, DateTime end) {
    final startUtc = DateTime.utc(start.year, start.month, start.day);
    final endUtc = DateTime.utc(end.year, end.month, end.day);
    final difference = endUtc.difference(startUtc).inDays;
    return difference + 1;
  }

  /// Menghitung total harga sewa berdasarkan harga per hari dan jumlah hari.
  static int totalPrice(int pricePerDay, int days) {
    if (days <= 0 || pricePerDay <= 0) return 0;
    return pricePerDay * days;
  }
}

