import 'package:rodakuu/core/config/app_constants.dart';
import 'package:rodakuu/core/error/app_failure.dart';
import 'package:rodakuu/core/error/error_mapper.dart';
import 'package:rodakuu/core/utils/formatters.dart';
import 'package:rodakuu/features/bookings/data/models/booked_range_dto.dart';
import 'package:rodakuu/features/bookings/data/models/booking_dto.dart';
import 'package:rodakuu/features/bookings/domain/entities/booked_range.dart';
import 'package:rodakuu/features/bookings/domain/entities/booking.dart';
import 'package:rodakuu/features/bookings/domain/entities/booking_request.dart';
import 'package:rodakuu/features/bookings/domain/repositories/booking_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Implementasi [BookingRepository] menggunakan RPC dan tabel Supabase.
class SupabaseBookingRepository implements BookingRepository {
  SupabaseBookingRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<String> createBooking(BookingRequest request) async {
    try {
      final dynamic data = await _client.rpc(
        'create_booking',
        params: {
          'p_vehicle_id': request.vehicleId,
          'p_start_date': toDateOnlyString(request.startDate),
          'p_end_date': toDateOnlyString(request.endDate),
          'p_pickup_location': request.pickupLocation,
          'p_notes': request.notes,
        },
      );

      final Map<String, dynamic> row;
      if (data is Map) {
        row = Map<String, dynamic>.from(data);
      } else if (data is List && data.isNotEmpty && data.first is Map) {
        row = Map<String, dynamic>.from(data.first as Map);
      } else {
        throw const ServerFailure(
          'Format respon pembuatan pesanan tidak valid.',
        );
      }

      return row['id'] as String;
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(mapToFailure(error), stackTrace);
    }
  }

  @override
  Future<List<Booking>> getMyBookings() async {
    try {
      final rows = await _client
          .from('bookings')
          .select('*, vehicle:vehicles(id, type, brand, name, image_url)')
          .order('created_at', ascending: false)
          .limit(AppConstants.bookingQueryLimit);

      return (rows as List<dynamic>)
          .map(
            (row) =>
                BookingDto.fromJson(row as Map<String, dynamic>).toEntity(),
          )
          .toList();
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(mapToFailure(error), stackTrace);
    }
  }

  @override
  Future<Booking> getBooking(String id) async {
    try {
      final data = await _client
          .from('bookings')
          .select('*, vehicle:vehicles(id, type, brand, name, image_url)')
          .eq('id', id)
          .maybeSingle();

      if (data == null) {
        throw const NotFoundFailure('Pesanan tidak ditemukan.');
      }

      return BookingDto.fromJson(data).toEntity();
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(mapToFailure(error), stackTrace);
    }
  }

  @override
  Future<void> cancelBooking(String id) async {
    try {
      await _client.rpc('cancel_booking', params: {'p_booking_id': id});
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(mapToFailure(error), stackTrace);
    }
  }

  @override
  Future<List<BookedRange>> getBookedRanges(String vehicleId) async {
    try {
      final rows = await _client.rpc(
        'get_booked_ranges',
        params: {'p_vehicle_id': vehicleId},
      );

      return (rows as List<dynamic>)
          .map(
            (row) =>
                BookedRangeDto.fromJson(row as Map<String, dynamic>).toEntity(),
          )
          .toList();
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(mapToFailure(error), stackTrace);
    }
  }
}
