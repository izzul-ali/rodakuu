import 'package:flutter/foundation.dart';
import 'package:rodakuu/core/config/app_strings.dart';
import 'package:rodakuu/features/vehicles/domain/entities/vehicle.dart';

/// Status siklus hidup pesanan rental.
enum BookingStatus {
  menunggu,
  dikonfirmasi,
  selesai,
  dibatalkan;

  String get label => switch (this) {
    menunggu => AppStrings.statusWaiting,
    dikonfirmasi => AppStrings.statusConfirmed,
    selesai => AppStrings.statusCompleted,
    dibatalkan => AppStrings.statusCancelled,
  };

  bool get isWaiting => this == BookingStatus.menunggu;
  bool get isConfirmed => this == BookingStatus.dikonfirmasi;
  bool get isCompleted => this == BookingStatus.selesai;
  bool get isCancelled => this == BookingStatus.dibatalkan;

  /// Kategori tab riwayat: Aktif (menunggu & dikonfirmasi) atau Selesai (selesai & dibatalkan).
  bool get isActive => isWaiting || isConfirmed;
}

/// Ringkasan data kendaraan yang disematkan dalam pesanan.
@immutable
class BookingVehicle {
  const BookingVehicle({
    required this.id,
    required this.type,
    required this.brand,
    required this.name,
    this.imageUrl,
  });

  final String id;
  final VehicleType type;
  final String brand;
  final String name;
  final String? imageUrl;

  String get fullName => '$brand $name';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookingVehicle &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type &&
          brand == other.brand &&
          name == other.name &&
          imageUrl == other.imageUrl;

  @override
  int get hashCode => Object.hash(id, type, brand, name, imageUrl);
}

/// Entitas data transaksi pemesanan rental kendaraan.
@immutable
class Booking {
  const Booking({
    required this.id,
    required this.userId,
    required this.vehicleId,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.pricePerDay,
    required this.totalPrice,
    required this.pickupLocation,
    this.notes,
    required this.status,
    required this.createdAt,
    this.vehicle,
  });

  final String id;
  final String userId;
  final String vehicleId;
  final DateTime startDate;
  final DateTime endDate;
  final int totalDays;
  final int pricePerDay;
  final int totalPrice;
  final String pickupLocation;
  final String? notes;
  final BookingStatus status;
  final DateTime createdAt;
  final BookingVehicle? vehicle;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Booking &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          vehicleId == other.vehicleId &&
          startDate == other.startDate &&
          endDate == other.endDate &&
          totalDays == other.totalDays &&
          pricePerDay == other.pricePerDay &&
          totalPrice == other.totalPrice &&
          pickupLocation == other.pickupLocation &&
          notes == other.notes &&
          status == other.status &&
          createdAt == other.createdAt &&
          vehicle == other.vehicle;

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    vehicleId,
    startDate,
    endDate,
    totalDays,
    pricePerDay,
    totalPrice,
    pickupLocation,
    notes,
    status,
    createdAt,
    vehicle,
  );
}
