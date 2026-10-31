import 'package:flutter_test/flutter_test.dart';
import 'package:rodakuu/features/vehicles/data/models/vehicle_dto.dart';
import 'package:rodakuu/features/vehicles/domain/entities/vehicle.dart';

void main() {
  group('VehicleDto', () {
    test(
      'T-UT-11: VehicleDto.fromJson data valid dan nilai enum tak dikenal',
      () {
        final validJson = {
          'id': 'v-1',
          'type': 'mobil',
          'brand': 'Toyota',
          'name': 'Avanza',
          'year': 2022,
          'transmission': 'manual',
          'fuel': 'bensin',
          'seats': 7,
          'price_per_day': 350000,
          'description': 'Mobil keluarga lega',
          'image_url': 'https://example.com/avanza.jpg',
          'is_available': true,
          'created_at': '2026-10-12T10:00:00.000Z',
        };

        final dto = VehicleDto.fromJson(validJson);
        final entity = dto.toEntity();

        expect(entity.id, equals('v-1'));
        expect(entity.type, equals(VehicleType.mobil));
        expect(entity.brand, equals('Toyota'));
        expect(entity.name, equals('Avanza'));
        expect(entity.fullName, equals('Toyota Avanza'));
        expect(entity.transmission, equals(Transmission.manual));
        expect(entity.fuel, equals(FuelType.bensin));
        expect(entity.seats, equals(7));
        expect(entity.pricePerDay, equals(350000));
        expect(entity.isAvailable, isTrue);

        final invalidTypeJson = Map<String, dynamic>.from(validJson)
          ..['type'] = 'pesawat';
        final invalidDto = VehicleDto.fromJson(invalidTypeJson);
        expect(() => invalidDto.toEntity(), throwsA(isA<FormatException>()));
      },
    );
  });
}
