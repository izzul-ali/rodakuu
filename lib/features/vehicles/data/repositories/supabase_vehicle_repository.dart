import 'package:rodakuu/core/config/app_constants.dart';
import 'package:rodakuu/core/error/app_failure.dart';
import 'package:rodakuu/core/error/error_mapper.dart';
import 'package:rodakuu/features/vehicles/data/models/vehicle_dto.dart';
import 'package:rodakuu/features/vehicles/domain/entities/vehicle.dart';
import 'package:rodakuu/features/vehicles/domain/entities/vehicle_filter.dart';
import 'package:rodakuu/features/vehicles/domain/repositories/vehicle_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Implementasi [VehicleRepository] menggunakan Supabase PostgREST.
class SupabaseVehicleRepository implements VehicleRepository {
  SupabaseVehicleRepository(this._client);

  final SupabaseClient _client;

  String _sanitizeKeyword(String input) {
    return input.replaceAll(RegExp(r'[,()%*]'), '').trim();
  }

  @override
  Future<List<Vehicle>> getVehicles(VehicleFilter filter) async {
    try {
      var query = _client.from('vehicles').select();

      if (filter.type != null) {
        query = query.eq('type', filter.type!.name);
      }
      if (filter.transmission != null) {
        query = query.eq('transmission', filter.transmission!.name);
      }
      if (filter.onlyAvailable) {
        query = query.eq('is_available', true);
      }
      if (filter.minPrice > AppConstants.priceFilterMin) {
        query = query.gte('price_per_day', filter.minPrice);
      }
      if (filter.maxPrice < AppConstants.priceFilterMax) {
        query = query.lte('price_per_day', filter.maxPrice);
      }

      final keyword = _sanitizeKeyword(filter.query);
      if (keyword.isNotEmpty) {
        query = query.or('name.ilike.%$keyword%,brand.ilike.%$keyword%');
      }

      final ordered = switch (filter.sort) {
        VehicleSort.newest => query.order('created_at', ascending: false),
        VehicleSort.priceAsc => query.order('price_per_day', ascending: true),
        VehicleSort.priceDesc => query.order('price_per_day', ascending: false),
      };

      final rows = await ordered.limit(AppConstants.vehicleQueryLimit);
      return (rows as List<dynamic>)
          .map(
            (row) =>
                VehicleDto.fromJson(row as Map<String, dynamic>).toEntity(),
          )
          .toList();
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(mapToFailure(error), stackTrace);
    }
  }

  @override
  Future<Vehicle> getVehicleById(String id) async {
    try {
      final data = await _client
          .from('vehicles')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (data == null) {
        throw const NotFoundFailure('Kendaraan tidak ditemukan.');
      }

      return VehicleDto.fromJson(data).toEntity();
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(mapToFailure(error), stackTrace);
    }
  }
}
