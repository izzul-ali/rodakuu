import 'package:flutter_test/flutter_test.dart';
import 'package:rodakuu/features/bookings/data/models/booking_dto.dart';
import 'package:rodakuu/features/bookings/domain/entities/booking.dart';
import 'package:rodakuu/features/vehicles/domain/entities/vehicle.dart';

void main() {
  group('BookingDto', () {
    test('T-UT-12: BookingDto.fromJson dengan embed vehicle memetakan Booking.vehicle dengan benar', () {
      final json = {
        'id': 'b-100',
        'user_id': 'u-1',
        'vehicle_id': 'v-1',
        'start_date': '2026-10-12',
        'end_date': '2026-10-14',
        'total_days': 3,
        'price_per_day': 350000,
        'total_price': 1050000,
        'pickup_location': 'Stasiun Gambir',
        'notes': 'Tolong siapkan tepat waktu',
        'status': 'menunggu',
        'created_at': '2026-10-11T08:30:00.000Z',
        'vehicle': {
          'id': 'v-1',
          'type': 'mobil',
          'brand': 'Toyota',
          'name': 'Avanza',
          'image_url': 'https://example.com/avanza.jpg',
        },
      };

      final dto = BookingDto.fromJson(json);
      final entity = dto.toEntity();

      expect(entity.id, equals('b-100'));
      expect(entity.userId, equals('u-1'));
      expect(entity.vehicleId, equals('v-1'));
      expect(entity.startDate, equals(DateTime(2026, 10, 12)));
      expect(entity.endDate, equals(DateTime(2026, 10, 14)));
      expect(entity.totalDays, equals(3));
      expect(entity.pricePerDay, equals(350000));
      expect(entity.totalPrice, equals(1050000));
      expect(entity.pickupLocation, equals('Stasiun Gambir'));
      expect(entity.notes, equals('Tolong siapkan tepat waktu'));
      expect(entity.status, equals(BookingStatus.menunggu));

      expect(entity.vehicle, isNotNull);
      expect(entity.vehicle!.id, equals('v-1'));
      expect(entity.vehicle!.type, equals(VehicleType.mobil));
      expect(entity.vehicle!.brand, equals('Toyota'));
      expect(entity.vehicle!.name, equals('Avanza'));
      expect(entity.vehicle!.fullName, equals('Toyota Avanza'));
      expect(
        entity.vehicle!.imageUrl,
        equals('https://example.com/avanza.jpg'),
      );
    });

    test('BookingDto.fromJson tanpa embed vehicle menghasilkan Booking.vehicle null', () {
      final jsonWithoutVehicle = {
        'id': 'b-101',
        'user_id': 'u-1',
        'vehicle_id': 'v-1',
        'start_date': '2026-10-12',
        'end_date': '2026-10-12',
        'total_days': 1,
        'price_per_day': 90000,
        'total_price': 90000,
        'pickup_location': 'Bandara',
        'status': 'dikonfirmasi',
        'created_at': '2026-10-11T09:00:00.000Z',
      };

      final dto = BookingDto.fromJson(jsonWithoutVehicle);
      final entity = dto.toEntity();

      expect(entity.id, equals('b-101'));
      expect(entity.vehicle, isNull);
      expect(entity.status, equals(BookingStatus.dikonfirmasi));
    });
  });
}
