import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rodakuu/features/bookings/presentation/providers/booking_providers.dart';

/// Pengendali pembatalan pesanan kendaraan.
class CancelBookingController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  /// Mengirim permintaan pembatalan pesanan ke server.
  /// Mengembalikan true jika berhasil dibatalkan.
  Future<bool> cancelBooking(String bookingId) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await ref.read(bookingRepositoryProvider).cancelBooking(bookingId);
      ref.invalidate(myBookingsProvider);
      ref.invalidate(bookingDetailProvider(bookingId));
    });

    return !state.hasError;
  }
}

/// Provider pengontrol pembatalan pesanan.
final cancelBookingControllerProvider =
    AsyncNotifierProvider.autoDispose<CancelBookingController, void>(
      CancelBookingController.new,
    );
