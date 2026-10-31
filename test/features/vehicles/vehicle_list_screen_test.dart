import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rodakuu/core/error/app_failure.dart';
import 'package:rodakuu/features/vehicles/domain/entities/vehicle.dart';
import 'package:rodakuu/features/vehicles/presentation/providers/vehicle_providers.dart';
import 'package:rodakuu/features/vehicles/presentation/screens/vehicle_list_screen.dart';

import '../../helpers/fakes.dart';
import '../../helpers/pump_app.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID');
  });

  group('VehicleListScreen', () {
    late FakeVehicleRepository fakeRepo;

    final dummyVehicles = [
      Vehicle(
        id: 'v-1',
        type: VehicleType.mobil,
        brand: 'Toyota',
        name: 'Avanza',
        year: 2022,
        transmission: Transmission.manual,
        fuel: FuelType.bensin,
        seats: 7,
        pricePerDay: 350000,
        description: 'MPV keluarga',
        isAvailable: true,
        createdAt: DateTime(2026, 1, 1),
      ),
      Vehicle(
        id: 'v-2',
        type: VehicleType.motor,
        brand: 'Honda',
        name: 'Beat',
        year: 2023,
        transmission: Transmission.matic,
        fuel: FuelType.bensin,
        seats: 2,
        pricePerDay: 90000,
        description: 'Motor harian irit',
        isAvailable: true,
        createdAt: DateTime(2026, 1, 2),
      ),
    ];

    setUp(() {
      fakeRepo = FakeVehicleRepository(vehicles: dummyVehicles);
    });

    testWidgets(
      'T-WT-05: data kendaraan tampil pada kartu dengan harga terformat',
      (tester) async {
        await pumpApp(
          tester,
          const VehicleListScreen(),
          overrides: [vehicleRepositoryProvider.overrideWithValue(fakeRepo)],
        );

        await tester.pumpAndSettle();

        expect(find.text('Toyota Avanza'), findsOneWidget);
        expect(find.text('Honda Beat'), findsOneWidget);
        expect(find.text('Rp 350.000'), findsOneWidget);
        expect(find.text('Rp 90.000'), findsOneWidget);
      },
    );

    testWidgets(
      'T-WT-06: daftar kosong menampilkan pesan ramah dan tombol reset',
      (tester) async {
        fakeRepo.vehicles = [];

        await pumpApp(
          tester,
          const VehicleListScreen(),
          overrides: [vehicleRepositoryProvider.overrideWithValue(fakeRepo)],
        );

        await tester.pumpAndSettle();

        expect(find.text('Kendaraan tidak ditemukan'), findsOneWidget);
        expect(find.text('Reset'), findsOneWidget);
      },
    );

    testWidgets(
      'T-WT-07: error menampilkan pesan ramah dan tombol Coba lagi memicu reload',
      (tester) async {
        var callCount = 0;
        fakeRepo.onGetVehicles = (filter) async {
          callCount++;
          if (callCount == 1) {
            throw const ServerFailure('Gagal memuat data server.');
          }
          return dummyVehicles;
        };

        await pumpApp(
          tester,
          const VehicleListScreen(),
          overrides: [vehicleRepositoryProvider.overrideWithValue(fakeRepo)],
        );

        await tester.pumpAndSettle();

        expect(find.text('Gagal memuat data server.'), findsOneWidget);
        final retryButton = find.widgetWithText(OutlinedButton, 'Coba lagi');
        expect(retryButton, findsOneWidget);

        await tester.tap(retryButton);
        await tester.pumpAndSettle();

        expect(callCount, equals(2));
        expect(find.text('Toyota Avanza'), findsOneWidget);
      },
    );

    testWidgets(
      'T-WT-08: memilih chip "Motor" memperbarui filter dengan type: motor',
      (tester) async {
        await pumpApp(
          tester,
          const VehicleListScreen(),
          overrides: [vehicleRepositoryProvider.overrideWithValue(fakeRepo)],
        );

        await tester.pumpAndSettle();

        final motorChip = find.widgetWithText(ChoiceChip, 'Motor');
        expect(motorChip, findsOneWidget);

        await tester.tap(motorChip);
        await tester.pumpAndSettle();

        expect(fakeRepo.lastFilter?.type, equals(VehicleType.motor));
      },
    );
  });
}
