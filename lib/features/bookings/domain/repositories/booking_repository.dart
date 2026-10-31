import 'package:rodakuu/features/bookings/domain/entities/booked_range.dart';
import 'package:rodakuu/features/bookings/domain/entities/booking.dart';
import 'package:rodakuu/features/bookings/domain/entities/booking_request.dart';

/// Kontrak repositori pemesanan kendaraan.
abstract interface class BookingRepository {
  /// Membuat pesanan rental baru dan mengembalikan ID pesanan yang terbentuk.
  Future<String> createBooking(BookingRequest request);

  /// Mengambil seluruh riwayat pesanan milik pengguna yang sedang aktif.
  Future<List<Booking>> getMyBookings();

  /// Mengambil rincian lengkap satu pesanan berdasarkan ID.
  Future<Booking> getBooking(String id);

  /// Membatalkan pesanan milik pengguna (hanya bila berstatus menunggu).
  Future<void> cancelBooking(String id);

  /// Mengambil daftar rentang tanggal yang sudah dipesan untuk suatu kendaraan.
  Future<List<BookedRange>> getBookedRanges(String vehicleId);
}

