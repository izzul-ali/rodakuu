import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rodakuu/core/utils/formatters.dart';
import 'package:rodakuu/features/bookings/domain/entities/booked_range.dart';
import 'package:rodakuu/features/bookings/presentation/providers/booking_providers.dart';
import 'package:rodakuu/features/bookings/presentation/screens/booking_form_screen.dart';
import 'package:rodakuu/features/bookings/presentation/widgets/date_range_field.dart';
import 'package:rodakuu/features/vehicles/domain/entities/vehicle.dart';
import 'package:rodakuu/features/vehicles/presentation/providers/vehicle_providers.dart';

import '../../helpers/fakes.dart';
import '../../helpers/pump_app.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID');
  });

  group('BookingFormScreen', () {
    late FakeVehicleRepository fakeVehicleRepo;
    late FakeBookingRepository fakeBookingRepo;

    final dummyVehicle = Vehicle(
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
    );

    setUp(() {
      fakeVehicleRepo = FakeVehicleRepository(vehicles: [dummyVehicle]);
      fakeBookingRepo = FakeBookingRepository();
    });

    testWidgets(
      'T-WT-10: memilih rentang 3 hari menampilkan ringkasan "× 3 hari" dan total harga benar',
      (tester) async {
        await pumpApp(
          tester,
          const BookingFormScreen(vehicleId: 'v-1'),
          overrides: [
            vehicleRepositoryProvider.overrideWithValue(fakeVehicleRepo),
            bookingRepositoryProvider.overrideWithValue(fakeBookingRepo),
          ],
        );

        await tester.pumpAndSettle();

        final dateFieldFinder = find.byType(DateRangeField);
        expect(dateFieldFinder, findsOneWidget);

        final startDate = DateTime.now().add(const Duration(days: 1));
        final endDate = startDate.add(
          const Duration(days: 2),
        ); // 3 hari inklusif

        final dateField = tester.widget<DateRangeField>(dateFieldFinder);
        dateField.onRangeChanged(DateTimeRange(start: startDate, end: endDate));
        await tester.pumpAndSettle();

        expect(find.textContaining('× 3 hari'), findsOneWidget);
        expect(find.text(formatRupiah(1050000)), findsNWidgets(2));
      },
    );

    testWidgets(
      'T-WT-11: rentang bertabrakan dengan pesanan aktif menampilkan error dan tombol nonaktif',
      (tester) async {
        final conflictStart = DateTime.now().add(const Duration(days: 2));
        final conflictEnd = conflictStart.add(const Duration(days: 2));

        fakeBookingRepo.bookedRanges = [
          BookedRange(startDate: conflictStart, endDate: conflictEnd),
        ];

        await pumpApp(
          tester,
          const BookingFormScreen(vehicleId: 'v-1'),
          overrides: [
            vehicleRepositoryProvider.overrideWithValue(fakeVehicleRepo),
            bookingRepositoryProvider.overrideWithValue(fakeBookingRepo),
          ],
        );

        await tester.pumpAndSettle();

        // Pilih rentang yang beririsan dengan conflict range
        final dateField = tester.widget<DateRangeField>(
          find.byType(DateRangeField),
        );
        dateField.onRangeChanged(
          DateTimeRange(start: conflictStart, end: conflictEnd),
        );
        await tester.pumpAndSettle();

        expect(
          find.text('Tanggal bertabrakan dengan pesanan lain.'),
          findsOneWidget,
        );

        final submitButton = tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Buat Pesanan'),
        );
        expect(submitButton.onPressed, isNull);
      },
    );

    testWidgets(
      'T-WT-12: submit form yang valid memanggil repository dengan parameter yang sesuai',
      (tester) async {
        await pumpApp(
          tester,
          const BookingFormScreen(vehicleId: 'v-1'),
          overrides: [
            vehicleRepositoryProvider.overrideWithValue(fakeVehicleRepo),
            bookingRepositoryProvider.overrideWithValue(fakeBookingRepo),
          ],
        );

        await tester.pumpAndSettle();

        final startDate = DateTime.now().add(const Duration(days: 1));
        final endDate = startDate.add(const Duration(days: 1)); // 2 hari

        final dateField = tester.widget<DateRangeField>(
          find.byType(DateRangeField),
        );
        dateField.onRangeChanged(DateTimeRange(start: startDate, end: endDate));
        await tester.pumpAndSettle();

        final locationField = find.widgetWithText(TextFormField, '');
        await tester.enterText(locationField.first, 'Stasiun Gambir');
        await tester.pumpAndSettle();

        final submitButton = find.widgetWithText(FilledButton, 'Buat Pesanan');
        await tester.tap(submitButton);
        await tester.pump();
        await tester.pumpAndSettle();

        expect(fakeBookingRepo.createBookingCallCount, equals(1));
        expect(fakeBookingRepo.lastRequest?.vehicleId, equals('v-1'));
        expect(
          fakeBookingRepo.lastRequest?.pickupLocation,
          equals('Stasiun Gambir'),
        );
        expect(fakeBookingRepo.lastRequest?.startDate, equals(startDate));
        expect(fakeBookingRepo.lastRequest?.endDate, equals(endDate));
      },
    );
  });
}
