import 'package:rodakuu/features/vehicles/domain/entities/vehicle.dart';
import 'package:rodakuu/features/vehicles/domain/entities/vehicle_filter.dart';

/// Kontrak repositori kendaraan untuk mengakses katalog dan rincian kendaraan.
abstract interface class VehicleRepository {
  /// Mengambil daftar kendaraan sesuai filter yang ditentukan.
  Future<List<Vehicle>> getVehicles(VehicleFilter filter);

  /// Mengambil satu rincian kendaraan berdasarkan ID.
  Future<Vehicle> getVehicleById(String id);
}
