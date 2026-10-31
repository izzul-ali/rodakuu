import 'package:flutter/foundation.dart';

/// Jenis kendaraan: mobil atau motor.
enum VehicleType {
  mobil,
  motor;

  String get label => switch (this) {
    mobil => 'Mobil',
    motor => 'Motor',
  };
}

/// Tipe sistem transmisi kendaraan.
enum Transmission {
  manual,
  matic;

  String get label => switch (this) {
    manual => 'Manual',
    matic => 'Matic',
  };
}

/// Jenis bahan bakar yang digunakan kendaraan.
enum FuelType {
  bensin,
  diesel,
  listrik;

  String get label => switch (this) {
    bensin => 'Bensin',
    diesel => 'Diesel',
    listrik => 'Listrik',
  };
}

/// Entitas kendaraan sewa RodaKuu.
@immutable
class Vehicle {
  const Vehicle({
    required this.id,
    required this.type,
    required this.brand,
    required this.name,
    required this.year,
    required this.transmission,
    required this.fuel,
    required this.seats,
    required this.pricePerDay,
    required this.description,
    this.imageUrl,
    required this.isAvailable,
    required this.createdAt,
  });

  final String id;
  final VehicleType type;
  final String brand;
  final String name;
  final int year;
  final Transmission transmission;
  final FuelType fuel;
  final int seats;
  final int pricePerDay;
  final String description;
  final String? imageUrl;
  final bool isAvailable;
  final DateTime createdAt;

  String get fullName => '$brand $name';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Vehicle &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type &&
          brand == other.brand &&
          name == other.name &&
          year == other.year &&
          transmission == other.transmission &&
          fuel == other.fuel &&
          seats == other.seats &&
          pricePerDay == other.pricePerDay &&
          description == other.description &&
          imageUrl == other.imageUrl &&
          isAvailable == other.isAvailable &&
          createdAt == other.createdAt;

  @override
  int get hashCode => Object.hash(
    id,
    type,
    brand,
    name,
    year,
    transmission,
    fuel,
    seats,
    pricePerDay,
    description,
    imageUrl,
    isAvailable,
    createdAt,
  );
}
