import 'package:flutter_test/flutter_test.dart';
import 'package:rodakuu/features/vehicles/domain/entities/vehicle.dart';
import 'package:rodakuu/features/vehicles/domain/entities/vehicle_filter.dart';

void main() {
  group('VehicleFilter', () {
    test(
      'T-UT-07: dua instance dengan nilai sama adalah equal dan hashCode sama',
      () {
        const filter1 = VehicleFilter(
          query: 'avanza',
          type: VehicleType.mobil,
          transmission: Transmission.manual,
          minPrice: 100000,
          maxPrice: 500000,
          onlyAvailable: true,
          sort: VehicleSort.priceAsc,
        );

        const filter2 = VehicleFilter(
          query: 'avanza',
          type: VehicleType.mobil,
          transmission: Transmission.manual,
          minPrice: 100000,
          maxPrice: 500000,
          onlyAvailable: true,
          sort: VehicleSort.priceAsc,
        );

        expect(filter1, equals(filter2));
        expect(filter1.hashCode, equals(filter2.hashCode));
      },
    );

    test('T-UT-08: copyWith dapat mengosongkan field nullable (type dan transmission)', () {
      const initial = VehicleFilter(
        type: VehicleType.mobil,
        transmission: Transmission.matic,
      );

      expect(initial.type, equals(VehicleType.mobil));
      expect(initial.transmission, equals(Transmission.matic));

      final cleared = initial.copyWith(
        type: () => null,
        transmission: () => null,
      );

      expect(cleared.type, isNull);
      expect(cleared.transmission, isNull);
    });

    test('activeFilterCount menghitung transmisi, rentang harga, dan onlyAvailable', () {
      const defaultFilter = VehicleFilter();
      expect(defaultFilter.activeFilterCount, equals(0));

      // Menambahkan type dan sort TIDAK menambah activeFilterCount
      final withTypeAndSort = defaultFilter.copyWith(
        type: () => VehicleType.motor,
        sort: VehicleSort.priceDesc,
      );
      expect(withTypeAndSort.activeFilterCount, equals(0));

      final withTransmission = withTypeAndSort.copyWith(
        transmission: () => Transmission.manual,
      );
      expect(withTransmission.activeFilterCount, equals(1));

      final withPrice = withTransmission.copyWith(minPrice: 50000);
      expect(withPrice.activeFilterCount, equals(2));

      final withAvailability = withPrice.copyWith(onlyAvailable: true);
      expect(withAvailability.activeFilterCount, equals(3));
    });
  });
}
