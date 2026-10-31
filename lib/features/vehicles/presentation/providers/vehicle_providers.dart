import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rodakuu/core/network/supabase_providers.dart';
import 'package:rodakuu/features/vehicles/data/repositories/supabase_vehicle_repository.dart';
import 'package:rodakuu/features/vehicles/domain/entities/vehicle.dart';
import 'package:rodakuu/features/vehicles/domain/repositories/vehicle_repository.dart';
import 'package:rodakuu/features/vehicles/presentation/providers/vehicle_filter_controller.dart';

/// Provider repositori kendaraan.
final vehicleRepositoryProvider = Provider<VehicleRepository>((ref) {
  return SupabaseVehicleRepository(ref.watch(supabaseClientProvider));
});

/// Provider daftar kendaraan otomatis ter-refresh saat filter berubah.
final vehicleListProvider = FutureProvider.autoDispose<List<Vehicle>>((
  ref,
) async {
  final filter = ref.watch(vehicleFilterProvider);
  return ref.watch(vehicleRepositoryProvider).getVehicles(filter);
});

/// Provider rincian satu kendaraan berdasarkan id.
final vehicleDetailProvider = FutureProvider.autoDispose
    .family<Vehicle, String>((ref, id) async {
      return ref.watch(vehicleRepositoryProvider).getVehicleById(id);
    });
