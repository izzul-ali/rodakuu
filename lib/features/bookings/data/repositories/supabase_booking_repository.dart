import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
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
      if (kDebugMode) {
        debugPrint(
          '📝 [SUPABASE_BOOKING] Memanggil RPC "create_booking" '
          '(vehicleId: ${request.vehicleId}, '
          'range: ${toDateOnlyString(request.startDate)} s.d. ${toDateOnlyString(request.endDate)})',
        );
      }

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

      if (kDebugMode) {
        debugPrint(
          '✅ [SUPABASE_BOOKING_SUCCESS] Pesanan berhasil dibuat dengan ID: ${row['id']}',
        );
      }

      return row['id'] as String;
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [SUPABASE_BOOKING_FAIL] Gagal membuat pesanan: $error');
      }
      Error.throwWithStackTrace(mapToFailure(error, stackTrace), stackTrace);
    }
  }

  @override
  Future<List<Booking>> getMyBookings() async {
    try {
      if (kDebugMode) {
        debugPrint(
          '📋 [SUPABASE_BOOKINGS] Memuat riwayat pesanan pengguna dari tabel "bookings"...',
        );
      }

      final rows = await _client
          .from('bookings')
          .select('*, vehicle:vehicles(id, type, brand, name, image_url)')
          .order('created_at', ascending: false)
          .limit(AppConstants.bookingQueryLimit);

      if (kDebugMode) {
        debugPrint(
          '📋 [SUPABASE_BOOKINGS_SUCCESS] Berhasil memuat ${(rows as List).length} pesanan.',
        );
      }

      return (rows as List<dynamic>)
          .map(
            (row) =>
                BookingDto.fromJson(row as Map<String, dynamic>).toEntity(),
          )
          .toList();
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [SUPABASE_BOOKINGS_FAIL] Gagal memuat riwayat pesanan: $error',
        );
      }
      Error.throwWithStackTrace(mapToFailure(error, stackTrace), stackTrace);
    }
  }

  @override
  Future<Booking> getBooking(String id) async {
    try {
      if (kDebugMode) {
        debugPrint(
          '📋 [SUPABASE_BOOKING_DETAIL] Memuat rincian pesanan id: $id',
        );
      }

      final data = await _client
          .from('bookings')
          .select('*, vehicle:vehicles(id, type, brand, name, image_url)')
          .eq('id', id)
          .maybeSingle();

      if (data == null) {
        throw const NotFoundFailure('Pesanan tidak ditemukan.');
      }

      if (kDebugMode) {
        debugPrint(
          '📋 [SUPABASE_BOOKING_DETAIL_SUCCESS] Rincian pesanan ditemukan: ${data['id']}',
        );
      }

      return BookingDto.fromJson(data).toEntity();
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [SUPABASE_BOOKING_DETAIL_FAIL] Gagal memuat rincian pesanan: $error',
        );
      }
      Error.throwWithStackTrace(mapToFailure(error, stackTrace), stackTrace);
    }
  }

  @override
  Future<void> cancelBooking(String id) async {
    try {
      if (kDebugMode) {
        debugPrint(
          '🚫 [SUPABASE_CANCEL] Membatalkan pesanan via RPC "cancel_booking" id: $id',
        );
      }

      await _client.rpc('cancel_booking', params: {'p_booking_id': id});

      if (kDebugMode) {
        debugPrint(
          '✅ [SUPABASE_CANCEL_SUCCESS] Pesanan $id berhasil dibatalkan',
        );
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [SUPABASE_CANCEL_FAIL] Gagal membatalkan pesanan: $error',
        );
      }
      Error.throwWithStackTrace(mapToFailure(error, stackTrace), stackTrace);
    }
  }

  @override
  Future<List<BookedRange>> getBookedRanges(String vehicleId) async {
    try {
      if (kDebugMode) {
        debugPrint(
          '📅 [SUPABASE_RANGES] Memuat rentang tanggal terisi untuk vehicleId: $vehicleId',
        );
      }

      final rows = await _client.rpc(
        'get_booked_ranges',
        params: {'p_vehicle_id': vehicleId},
      );

      if (kDebugMode) {
        debugPrint(
          '📅 [SUPABASE_RANGES_SUCCESS] Ditemukan ${(rows as List).length} rentang terisi.',
        );
      }

      return (rows as List<dynamic>)
          .map(
            (row) =>
                BookedRangeDto.fromJson(row as Map<String, dynamic>).toEntity(),
          )
          .toList();
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [SUPABASE_RANGES_FAIL] Gagal memuat rentang terisi: $error',
        );
      }
      Error.throwWithStackTrace(mapToFailure(error, stackTrace), stackTrace);
    }
  }
}
