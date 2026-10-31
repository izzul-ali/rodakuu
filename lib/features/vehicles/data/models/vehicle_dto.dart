import 'package:rodakuu/core/utils/enum_parser.dart';
import 'package:rodakuu/features/vehicles/domain/entities/vehicle.dart';

/// Data Transfer Object untuk serialisasi data kendaraan dari/ke database Supabase.
class VehicleDto {
  const VehicleDto({
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
  final String type;
  final String brand;
  final String name;
  final int year;
  final String transmission;
  final String fuel;
  final int seats;
  final int pricePerDay;
  final String description;
  final String? imageUrl;
  final bool isAvailable;
  final DateTime createdAt;

  factory VehicleDto.fromJson(Map<String, dynamic> json) {
    return VehicleDto(
      id: json['id'] as String,
      type: json['type'] as String,
      brand: json['brand'] as String,
      name: json['name'] as String,
      year: (json['year'] as num).toInt(),
      transmission: json['transmission'] as String,
      fuel: json['fuel'] as String,
      seats: (json['seats'] as num).toInt(),
      pricePerDay: (json['price_per_day'] as num).toInt(),
      description: (json['description'] as String?) ?? '',
      imageUrl: json['image_url'] as String?,
      isAvailable: (json['is_available'] as bool?) ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'brand': brand,
      'name': name,
      'year': year,
      'transmission': transmission,
      'fuel': fuel,
      'seats': seats,
      'price_per_day': pricePerDay,
      'description': description,
      'image_url': imageUrl,
      'is_available': isAvailable,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Vehicle toEntity() {
    return Vehicle(
      id: id,
      type: parseEnum(VehicleType.values, type),
      brand: brand,
      name: name,
      year: year,
      transmission: parseEnum(Transmission.values, transmission),
      fuel: parseEnum(FuelType.values, fuel),
      seats: seats,
      pricePerDay: pricePerDay,
      description: description,
      imageUrl: imageUrl,
      isAvailable: isAvailable,
      createdAt: createdAt,
    );
  }
}
