import 'package:rodakuu/core/utils/enum_parser.dart';
import 'package:rodakuu/features/bookings/domain/entities/booking.dart';
import 'package:rodakuu/features/vehicles/domain/entities/vehicle.dart';

/// Data Transfer Object untuk transaksi pemesanan beserta embed ringkasan kendaraan.
class BookingDto {
  const BookingDto({
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
  final String startDate;
  final String endDate;
  final int totalDays;
  final int pricePerDay;
  final int totalPrice;
  final String pickupLocation;
  final String? notes;
  final String status;
  final DateTime createdAt;
  final Map<String, dynamic>? vehicle;

  factory BookingDto.fromJson(Map<String, dynamic> json) {
    return BookingDto(
      id: json['id'] as String,
      userId: (json['user_id'] as String?) ?? '',
      vehicleId: json['vehicle_id'] as String,
      startDate: json['start_date'] as String,
      endDate: json['end_date'] as String,
      totalDays: (json['total_days'] as num).toInt(),
      pricePerDay: (json['price_per_day'] as num).toInt(),
      totalPrice: (json['total_price'] as num).toInt(),
      pickupLocation: json['pickup_location'] as String,
      notes: json['notes'] as String?,
      status: json['status'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      vehicle: json['vehicle'] != null
          ? Map<String, dynamic>.from(json['vehicle'] as Map<dynamic, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'vehicle_id': vehicleId,
      'start_date': startDate,
      'end_date': endDate,
      'total_days': totalDays,
      'price_per_day': pricePerDay,
      'total_price': totalPrice,
      'pickup_location': pickupLocation,
      'notes': notes,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'vehicle': vehicle,
    };
  }

  Booking toEntity() {
    BookingVehicle? bookingVehicle;
    if (vehicle != null) {
      bookingVehicle = BookingVehicle(
        id: vehicle!['id'] as String,
        type: parseEnum(VehicleType.values, vehicle!['type'] as String),
        brand: vehicle!['brand'] as String,
        name: vehicle!['name'] as String,
        imageUrl: vehicle!['image_url'] as String?,
      );
    }

    return Booking(
      id: id,
      userId: userId,
      vehicleId: vehicleId,
      startDate: DateTime.parse(startDate),
      endDate: DateTime.parse(endDate),
      totalDays: totalDays,
      pricePerDay: pricePerDay,
      totalPrice: totalPrice,
      pickupLocation: pickupLocation,
      notes: notes,
      status: parseEnum(BookingStatus.values, status),
      createdAt: createdAt,
      vehicle: bookingVehicle,
    );
  }
}

