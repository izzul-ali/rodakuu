import 'package:flutter/foundation.dart';
import 'package:rodakuu/core/config/app_constants.dart';
import 'package:rodakuu/features/vehicles/domain/entities/vehicle.dart';

/// Pilihan pengurutan daftar kendaraan.
enum VehicleSort {
  newest,
  priceAsc,
  priceDesc;

  String get label => switch (this) {
    newest => 'Terbaru',
    priceAsc => 'Harga terendah',
    priceDesc => 'Harga tertinggi',
  };
}

/// Kriteria filter dan pencarian daftar kendaraan.
@immutable
class VehicleFilter {
  const VehicleFilter({
    this.query = '',
    this.type,
    this.transmission,
    this.minPrice = AppConstants.priceFilterMin,
    this.maxPrice = AppConstants.priceFilterMax,
    this.onlyAvailable = false,
    this.sort = VehicleSort.newest,
  });

  final String query;
  final VehicleType? type;
  final Transmission? transmission;
  final int minPrice;
  final int maxPrice;
  final bool onlyAvailable;
  final VehicleSort sort;

  /// Jumlah filter aktif pada bottom sheet filter (tanpa jenis dan sort).
  int get activeFilterCount {
    var count = 0;
    if (transmission != null) count++;
    if (minPrice != AppConstants.priceFilterMin ||
        maxPrice != AppConstants.priceFilterMax) {
      count++;
    }
    if (onlyAvailable) count++;
    return count;
  }

  /// Membuat salinan filter baru dengan kemampuan mengosongkan nilai nullable via closure.
  VehicleFilter copyWith({
    String? query,
    VehicleType? Function()? type,
    Transmission? Function()? transmission,
    int? minPrice,
    int? maxPrice,
    bool? onlyAvailable,
    VehicleSort? sort,
  }) {
    return VehicleFilter(
      query: query ?? this.query,
      type: type != null ? type() : this.type,
      transmission: transmission != null ? transmission() : this.transmission,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      onlyAvailable: onlyAvailable ?? this.onlyAvailable,
      sort: sort ?? this.sort,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VehicleFilter &&
          runtimeType == other.runtimeType &&
          query == other.query &&
          type == other.type &&
          transmission == other.transmission &&
          minPrice == other.minPrice &&
          maxPrice == other.maxPrice &&
          onlyAvailable == other.onlyAvailable &&
          sort == other.sort;

  @override
  int get hashCode => Object.hash(
    query,
    type,
    transmission,
    minPrice,
    maxPrice,
    onlyAvailable,
    sort,
  );
}
