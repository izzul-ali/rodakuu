import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:rodakuu/features/auth/presentation/providers/auth_providers.dart';
import 'package:rodakuu/features/bookings/domain/entities/booking.dart';
import 'package:rodakuu/features/bookings/presentation/providers/booking_providers.dart';
import 'package:rodakuu/features/bookings/presentation/screens/booking_detail_screen.dart';
import 'package:rodakuu/features/bookings/presentation/screens/booking_history_screen.dart';
import 'package:rodakuu/features/vehicles/domain/entities/vehicle.dart';

import '../../helpers/fakes.dart';
import '../../helpers/pump_app.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID');
  });

  group('BookingHistoryScreen & BookingDetailScreen', () {
    late FakeAuthRepository fakeAuth;
    late FakeBookingRepository fakeBookingRepo;

    final activeBooking = Booking(
      id: 'b-1',
      userId: 'u-1',
      vehicleId: 'v-1',
      startDate: DateTime(2026, 11, 1),
      endDate: DateTime(2026, 11, 3),
      totalDays: 3,
      pricePerDay: 350000,
      totalPrice: 1050000,
      pickupLocation: 'Stasiun Gambir',
      status: BookingStatus.menunggu,
      createdAt: DateTime(2026, 10, 30),
      vehicle: const BookingVehicle(
        id: 'v-1',
        type: VehicleType.mobil,
        brand: 'Toyota',
        name: 'Avanza',
      ),
    );

    final completedBooking = Booking(
      id: 'b-2',
      userId: 'u-1',
      vehicleId: 'v-2',
      startDate: DateTime(2026, 10, 1),
      endDate: DateTime(2026, 10, 2),
      totalDays: 2,
      pricePerDay: 90000,
      totalPrice: 180000,
      pickupLocation: 'Bandara',
      status: BookingStatus.selesai,
      createdAt: DateTime(2026, 9, 30),
      vehicle: const BookingVehicle(
        id: 'v-2',
        type: VehicleType.motor,
        brand: 'Honda',
        name: 'Beat',
      ),
    );

    setUp(() {
      fakeAuth = FakeAuthRepository(userId: 'u-1');
      fakeBookingRepo = FakeBookingRepository(
        bookings: [activeBooking, completedBooking],
      );
    });

    testWidgets(
      'T-WT-13: beralih tab Aktif vs Selesai memfilter daftar pesanan berdasarkan status',
      (tester) async {
        await pumpApp(
          tester,
          const BookingHistoryScreen(),
          overrides: [
            authRepositoryProvider.overrideWithValue(fakeAuth),
            bookingRepositoryProvider.overrideWithValue(fakeBookingRepo),
          ],
        );

        await tester.pumpAndSettle();

        // Default tab: Aktif -> menampilkan Toyota Avanza, tidak menampilkan Honda Beat
        expect(find.text('Toyota Avanza'), findsOneWidget);
        expect(find.text('Honda Beat'), findsNothing);

        // Beralih ke tab Selesai
        final selesaiTab = find.text('Selesai');
        expect(selesaiTab, findsOneWidget);
        await tester.tap(selesaiTab);
        await tester.pumpAndSettle();

        // Tab Selesai -> menampilkan Honda Beat, tidak menampilkan Toyota Avanza
        expect(find.text('Honda Beat'), findsOneWidget);
        expect(find.text('Toyota Avanza'), findsNothing);
      },
    );

    testWidgets(
      'T-WT-14: detail pesanan "menunggu" menampilkan tombol "Batalkan Pesanan", sedangkan status "selesai" tidak menampilkan tombol pembatalan',
      (tester) async {
        // Layar detail untuk pesanan berstatus menunggu
        await pumpApp(
          tester,
          const BookingDetailScreen(bookingId: 'b-1'),
          overrides: [
            authRepositoryProvider.overrideWithValue(fakeAuth),
            bookingRepositoryProvider.overrideWithValue(fakeBookingRepo),
          ],
        );

        await tester.pumpAndSettle();

        expect(find.text('Batalkan Pesanan'), findsOneWidget);

        // Layar detail untuk pesanan berstatus selesai
        await pumpApp(
          tester,
          const BookingDetailScreen(bookingId: 'b-2'),
          overrides: [
            authRepositoryProvider.overrideWithValue(fakeAuth),
            bookingRepositoryProvider.overrideWithValue(fakeBookingRepo),
          ],
        );

        await tester.pumpAndSettle();

        expect(find.text('Batalkan Pesanan'), findsNothing);
      },
    );
  });
}
