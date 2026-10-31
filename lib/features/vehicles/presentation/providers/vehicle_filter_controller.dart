import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rodakuu/features/vehicles/domain/entities/vehicle.dart';
import 'package:rodakuu/features/vehicles/domain/entities/vehicle_filter.dart';

/// Pengendali status filter pencarian dan katalog kendaraan.
class VehicleFilterController extends Notifier<VehicleFilter> {
  @override
  VehicleFilter build() => const VehicleFilter();

  /// Memperbarui kata kunci pencarian kendaraan.
  void setQuery(String query) {
    state = state.copyWith(query: query);
  }

  /// Memperbarui pilihan jenis kendaraan (Semua/Mobil/Motor).
  void setType(VehicleType? type) {
    state = state.copyWith(type: () => type);
  }

  /// Menerapkan konfigurasi filter baru secara menyeluruh dari bottom sheet.
  void setFilter(VehicleFilter filter) {
    state = filter;
  }

  /// Mengembalikan filter ke pengaturan awal (default).
  void reset() {
    state = const VehicleFilter();
  }
}

/// Provider state filter kendaraan.
final vehicleFilterProvider =
    NotifierProvider<VehicleFilterController, VehicleFilter>(
      VehicleFilterController.new,
    );
