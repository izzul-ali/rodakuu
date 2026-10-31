import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rodakuu/features/vehicles/domain/entities/vehicle.dart';
import 'package:rodakuu/features/vehicles/presentation/providers/vehicle_providers.dart';
import 'package:rodakuu/features/vehicles/presentation/screens/vehicle_detail_screen.dart';

import '../../helpers/fakes.dart';
import '../../helpers/pump_app.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID');
  });

  group('VehicleDetailScreen', () {
    late FakeVehicleRepository fakeRepo;

    final availableVehicle = Vehicle(
      id: 'v-1',
      type: VehicleType.mobil,
      brand: 'Toyota',
      name: 'Avanza',
      year: 2022,
      transmission: Transmission.manual,
      fuel: FuelType.bensin,
      seats: 7,
      pricePerDay: 350000,
      description: 'MPV keluarga yang irit dan lega.',
      isAvailable: true,
      createdAt: DateTime(2026, 1, 1),
    );

    final unavailableVehicle = Vehicle(
      id: 'v-2',
      type: VehicleType.mobil,
      brand: 'Suzuki',
      name: 'Ertiga',
      year: 2021,
      transmission: Transmission.manual,
      fuel: FuelType.bensin,
      seats: 7,
      pricePerDay: 400000,
      description: 'Irit bahan bakar dan nyaman.',
      isAvailable: false,
      createdAt: DateTime(2026, 1, 1),
    );

    setUp(() {
      fakeRepo = FakeVehicleRepository(
        vehicles: [availableVehicle, unavailableVehicle],
      );
    });

    testWidgets(
      'T-WT-09: detail kendaraan is_available = false menampilkan tombol nonaktif "Tidak tersedia"',
      (tester) async {
        await pumpApp(
          tester,
          const VehicleDetailScreen(vehicleId: 'v-2'),
          overrides: [vehicleRepositoryProvider.overrideWithValue(fakeRepo)],
        );

        await tester.pumpAndSettle();

        expect(find.text('Suzuki Ertiga'), findsOneWidget);
        expect(find.text('Rp 400.000'), findsOneWidget);
        expect(find.text('Tidak tersedia'), findsAtLeastNWidgets(1));

        final button = tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Tidak tersedia'),
        );
        expect(button.onPressed, isNull);
      },
    );

    testWidgets(
      'Detail kendaraan tersedia menampilkan tombol aktif "Pesan Sekarang"',
      (tester) async {
        await pumpApp(
          tester,
          const VehicleDetailScreen(vehicleId: 'v-1'),
          overrides: [vehicleRepositoryProvider.overrideWithValue(fakeRepo)],
        );

        await tester.pumpAndSettle();

        expect(find.text('Toyota Avanza'), findsOneWidget);
        expect(find.text('Rp 350.000'), findsOneWidget);
        final orderButton = find.widgetWithText(FilledButton, 'Pesan Sekarang');
        expect(orderButton, findsOneWidget);

        final button = tester.widget<FilledButton>(orderButton);
        expect(button.onPressed, isNotNull);
      },
    );
  });
}
