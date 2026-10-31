import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rodakuu/features/bookings/domain/entities/booking_request.dart';
import 'package:rodakuu/features/bookings/presentation/providers/booking_providers.dart';

/// Pengendali formulir pembuatan pesanan baru.
class BookingFormController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  /// Mengirim permintaan pembuatan pesanan ke server.
  /// Mengembalikan ID pesanan jika berhasil, atau null jika gagal.
  Future<String?> createBooking(BookingRequest request) async {
    state = const AsyncLoading();
    String? createdId;

    state = await AsyncValue.guard(() async {
      createdId = await ref
          .read(bookingRepositoryProvider)
          .createBooking(request);
      ref.invalidate(myBookingsProvider);
    });

    if (state.hasError) return null;
    return createdId;
  }
}

/// Provider pengontrol formulir pemesanan.
final bookingFormControllerProvider =
    AsyncNotifierProvider.autoDispose<BookingFormController, void>(
      BookingFormController.new,
    );
