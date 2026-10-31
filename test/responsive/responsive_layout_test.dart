import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rodakuu/features/auth/presentation/providers/auth_providers.dart';
import 'package:rodakuu/features/auth/presentation/screens/login_screen.dart';
import 'package:rodakuu/features/auth/presentation/screens/register_screen.dart';
import 'package:rodakuu/features/bookings/domain/entities/booked_range.dart';
import 'package:rodakuu/features/bookings/domain/entities/booking.dart';
import 'package:rodakuu/features/bookings/presentation/providers/booking_providers.dart';
import 'package:rodakuu/features/bookings/presentation/screens/booking_detail_screen.dart';
import 'package:rodakuu/features/bookings/presentation/screens/booking_form_screen.dart';
import 'package:rodakuu/features/bookings/presentation/screens/booking_history_screen.dart';
import 'package:rodakuu/features/profile/domain/entities/profile.dart';
import 'package:rodakuu/features/profile/presentation/providers/profile_providers.dart';
import 'package:rodakuu/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:rodakuu/features/profile/presentation/screens/profile_screen.dart';
import 'package:rodakuu/features/vehicles/domain/entities/vehicle.dart';
import 'package:rodakuu/features/vehicles/presentation/providers/vehicle_providers.dart';
import 'package:rodakuu/features/vehicles/presentation/screens/vehicle_detail_screen.dart';
import 'package:rodakuu/features/vehicles/presentation/screens/vehicle_list_screen.dart';

import '../helpers/fakes.dart';
import '../helpers/pump_app.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID');
  });

  const sizes = [
    Size(320, 568),
    Size(360, 640),
    Size(393, 852),
    Size(412, 915),
    Size(600, 960),
    Size(852, 393),
  ];

  const scales = [1.0, 1.3];

  final dummyVehicle = Vehicle(
    id: 'v-1',
    type: VehicleType.mobil,
    brand: 'Toyota',
    name: 'Avanza Veloz 1.5 AT',
    year: 2022,
    transmission: Transmission.matic,
    fuel: FuelType.bensin,
    seats: 7,
    pricePerDay: 350000,
    description:
        'Mobil keluarga nyaman untuk perjalanan jauh maupun perkotaan.',
    isAvailable: true,
    createdAt: DateTime(2026, 1, 1),
  );

  final dummyBooking = Booking(
    id: 'b-1',
    userId: 'u-1',
    vehicleId: 'v-1',
    startDate: DateTime(2026, 11, 1),
    endDate: DateTime(2026, 11, 3),
    totalDays: 3,
    pricePerDay: 350000,
    totalPrice: 1050000,
    pickupLocation: 'Stasiun Gambir, Jakarta Pusat',
    notes: 'Mohon siapkan charger mobil.',
    status: BookingStatus.menunggu,
    createdAt: DateTime(2026, 10, 30),
    vehicle: const BookingVehicle(
      id: 'v-1',
      type: VehicleType.mobil,
      brand: 'Toyota',
      name: 'Avanza Veloz 1.5 AT',
    ),
  );

  const dummyProfile = Profile(
    id: 'u-1',
    fullName: 'Budi Santoso',
    phone: '081234567890',
    email: 'budi.santoso@example.com',
  );

  group('T-RS-01: Audit Responsif Layar Utama', () {
    late FakeAuthRepository fakeAuth;
    late FakeVehicleRepository fakeVehicleRepo;
    late FakeBookingRepository fakeBookingRepo;
    late FakeProfileRepository fakeProfileRepo;

    setUp(() {
      fakeAuth = FakeAuthRepository(userId: 'u-1');
      fakeVehicleRepo = FakeVehicleRepository(vehicles: [dummyVehicle]);
      fakeBookingRepo = FakeBookingRepository(
        bookings: [dummyBooking],
        bookedRanges: [
          BookedRange(
            startDate: DateTime(2026, 11, 10),
            endDate: DateTime(2026, 11, 12),
          ),
        ],
      );
      fakeProfileRepo = FakeProfileRepository(profile: dummyProfile);
    });

    tearDown(() {
      fakeAuth.dispose();
    });

    List<dynamic> getOverrides() => [
      authRepositoryProvider.overrideWithValue(fakeAuth),
      vehicleRepositoryProvider.overrideWithValue(fakeVehicleRepo),
      bookingRepositoryProvider.overrideWithValue(fakeBookingRepo),
      profileRepositoryProvider.overrideWithValue(fakeProfileRepo),
    ];

    testWidgets('LoginScreen responsif tanpa overflow', (tester) async {
      for (final size in sizes) {
        for (final scale in scales) {
          await pumpApp(
            tester,
            const LoginScreen(),
            size: size,
            textScale: scale,
            overrides: getOverrides().cast(),
          );
          await tester.pumpAndSettle();
          expect(
            tester.takeException(),
            isNull,
            reason: 'LoginScreen gagal pada ukuran $size skala $scale',
          );
        }
      }
    });

    testWidgets('RegisterScreen responsif tanpa overflow', (tester) async {
      for (final size in sizes) {
        for (final scale in scales) {
          await pumpApp(
            tester,
            const RegisterScreen(),
            size: size,
            textScale: scale,
            overrides: getOverrides().cast(),
          );
          await tester.pumpAndSettle();
          expect(
            tester.takeException(),
            isNull,
            reason: 'RegisterScreen gagal pada ukuran $size skala $scale',
          );
        }
      }
    });

    testWidgets('VehicleListScreen responsif tanpa overflow', (tester) async {
      for (final size in sizes) {
        for (final scale in scales) {
          await pumpApp(
            tester,
            const VehicleListScreen(),
            size: size,
            textScale: scale,
            overrides: getOverrides().cast(),
          );
          await tester.pumpAndSettle();
          expect(
            tester.takeException(),
            isNull,
            reason: 'VehicleListScreen gagal pada ukuran $size skala $scale',
          );
        }
      }
    });

    testWidgets('VehicleDetailScreen responsif tanpa overflow', (tester) async {
      for (final size in sizes) {
        for (final scale in scales) {
          await pumpApp(
            tester,
            VehicleDetailScreen(vehicleId: dummyVehicle.id),
            size: size,
            textScale: scale,
            overrides: getOverrides().cast(),
          );
          await tester.pumpAndSettle();
          expect(
            tester.takeException(),
            isNull,
            reason: 'VehicleDetailScreen gagal pada ukuran $size skala $scale',
          );
        }
      }
    });

    testWidgets('BookingFormScreen responsif tanpa overflow', (tester) async {
      for (final size in sizes) {
        for (final scale in scales) {
          await pumpApp(
            tester,
            BookingFormScreen(vehicleId: dummyVehicle.id),
            size: size,
            textScale: scale,
            overrides: getOverrides().cast(),
          );
          await tester.pumpAndSettle();
          expect(
            tester.takeException(),
            isNull,
            reason: 'BookingFormScreen gagal pada ukuran $size skala $scale',
          );
        }
      }
    });

    testWidgets('BookingHistoryScreen responsif tanpa overflow', (
      tester,
    ) async {
      for (final size in sizes) {
        for (final scale in scales) {
          await pumpApp(
            tester,
            const BookingHistoryScreen(),
            size: size,
            textScale: scale,
            overrides: getOverrides().cast(),
          );
          await tester.pumpAndSettle();
          expect(
            tester.takeException(),
            isNull,
            reason: 'BookingHistoryScreen gagal pada ukuran $size skala $scale',
          );
        }
      }
    });

    testWidgets('BookingDetailScreen responsif tanpa overflow', (tester) async {
      for (final size in sizes) {
        for (final scale in scales) {
          await pumpApp(
            tester,
            BookingDetailScreen(bookingId: dummyBooking.id),
            size: size,
            textScale: scale,
            overrides: getOverrides().cast(),
          );
          await tester.pumpAndSettle();
          expect(
            tester.takeException(),
            isNull,
            reason: 'BookingDetailScreen gagal pada ukuran $size skala $scale',
          );
        }
      }
    });

    testWidgets('ProfileScreen responsif tanpa overflow', (tester) async {
      for (final size in sizes) {
        for (final scale in scales) {
          await pumpApp(
            tester,
            const ProfileScreen(),
            size: size,
            textScale: scale,
            overrides: getOverrides().cast(),
          );
          await tester.pumpAndSettle();
          expect(
            tester.takeException(),
            isNull,
            reason: 'ProfileScreen gagal pada ukuran $size skala $scale',
          );
        }
      }
    });

    testWidgets('EditProfileScreen responsif tanpa overflow', (tester) async {
      for (final size in sizes) {
        for (final scale in scales) {
          await pumpApp(
            tester,
            const EditProfileScreen(),
            size: size,
            textScale: scale,
            overrides: getOverrides().cast(),
          );
          await tester.pumpAndSettle();
          expect(
            tester.takeException(),
            isNull,
            reason: 'EditProfileScreen gagal pada ukuran $size skala $scale',
          );
        }
      }
    });
  });
}
