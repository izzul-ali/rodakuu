import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rodakuu/core/network/supabase_providers.dart';
import 'package:rodakuu/features/auth/presentation/providers/auth_providers.dart';
import 'package:rodakuu/features/bookings/data/repositories/supabase_booking_repository.dart';
import 'package:rodakuu/features/bookings/domain/entities/booked_range.dart';
import 'package:rodakuu/features/bookings/domain/entities/booking.dart';
import 'package:rodakuu/features/bookings/domain/repositories/booking_repository.dart';

/// Provider repositori pemesanan.
final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return SupabaseBookingRepository(ref.watch(supabaseClientProvider));
});

/// Provider riwayat pesanan milik pengguna aktif saat ini.
final myBookingsProvider = FutureProvider.autoDispose<List<Booking>>((
  ref,
) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return [];
  return ref.watch(bookingRepositoryProvider).getMyBookings();
});

/// Provider rincian satu pesanan berdasarkan ID.
final bookingDetailProvider = FutureProvider.autoDispose
    .family<Booking, String>((ref, id) async {
      ref.watch(currentUserIdProvider);
      return ref.watch(bookingRepositoryProvider).getBooking(id);
    });

/// Provider rentang tanggal yang telah dipesan untuk kendaraan tertentu.
final bookedRangesProvider = FutureProvider.autoDispose
    .family<List<BookedRange>, String>((ref, vehicleId) async {
      return ref.watch(bookingRepositoryProvider).getBookedRanges(vehicleId);
    });
