import 'package:flutter/foundation.dart';

/// Data permintaan pembuatan pesanan baru ke server.
@immutable
class BookingRequest {
  const BookingRequest({
    required this.vehicleId,
    required this.startDate,
    required this.endDate,
    required this.pickupLocation,
    this.notes,
  });

  final String vehicleId;
  final DateTime startDate;
  final DateTime endDate;
  final String pickupLocation;
  final String? notes;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookingRequest &&
          runtimeType == other.runtimeType &&
          vehicleId == other.vehicleId &&
          startDate == other.startDate &&
          endDate == other.endDate &&
          pickupLocation == other.pickupLocation &&
          notes == other.notes;

  @override
  int get hashCode =>
      Object.hash(vehicleId, startDate, endDate, pickupLocation, notes);
}
