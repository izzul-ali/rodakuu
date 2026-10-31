import 'dart:async';

import 'package:rodakuu/core/error/app_failure.dart';
import 'package:rodakuu/features/auth/domain/auth_repository.dart';
import 'package:rodakuu/features/bookings/domain/entities/booked_range.dart';
import 'package:rodakuu/features/bookings/domain/entities/booking.dart';
import 'package:rodakuu/features/bookings/domain/entities/booking_request.dart';
import 'package:rodakuu/features/bookings/domain/repositories/booking_repository.dart';
import 'package:rodakuu/features/profile/domain/entities/profile.dart';
import 'package:rodakuu/features/profile/domain/repositories/profile_repository.dart';
import 'package:rodakuu/features/vehicles/domain/entities/vehicle.dart';
import 'package:rodakuu/features/vehicles/domain/entities/vehicle_filter.dart';
import 'package:rodakuu/features/vehicles/domain/repositories/vehicle_repository.dart';

/// Implementasi tiruan (fake) repositori autentikasi untuk pengujian unit dan widget.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.userId});

  String? userId;
  final StreamController<String?> _controller =
      StreamController<String?>.broadcast();

  Future<void> Function(String email, String password)? onSignIn;
  Future<SignUpResult> Function(String fullName, String email, String password)?
  onSignUp;
  Future<void> Function()? onSignOut;

  int signInCallCount = 0;
  int signUpCallCount = 0;
  int signOutCallCount = 0;

  @override
  String? get currentUserId => userId;

  @override
  Stream<String?> get userIdChanges => _controller.stream;

  void emitUserId(String? id) {
    userId = id;
    _controller.add(id);
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    signInCallCount++;
    if (onSignIn != null) {
      await onSignIn!(email, password);
    } else {
      emitUserId('user-123');
    }
  }

  @override
  Future<SignUpResult> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    signUpCallCount++;
    if (onSignUp != null) {
      return onSignUp!(fullName, email, password);
    }
    emitUserId('user-123');
    return SignUpResult.signedIn;
  }

  @override
  Future<void> signOut() async {
    signOutCallCount++;
    if (onSignOut != null) {
      await onSignOut!();
    }
    emitUserId(null);
  }

  void dispose() {
    _controller.close();
  }
}

/// Implementasi tiruan (fake) repositori kendaraan untuk pengujian.
class FakeVehicleRepository implements VehicleRepository {
  FakeVehicleRepository({List<Vehicle>? vehicles}) : vehicles = vehicles ?? [];

  List<Vehicle> vehicles;
  Future<List<Vehicle>> Function(VehicleFilter filter)? onGetVehicles;
  Future<Vehicle> Function(String id)? onGetVehicleById;

  int getVehiclesCallCount = 0;
  VehicleFilter? lastFilter;
  int getVehicleByIdCallCount = 0;
  String? lastVehicleId;

  @override
  Future<List<Vehicle>> getVehicles(VehicleFilter filter) async {
    getVehiclesCallCount++;
    lastFilter = filter;
    if (onGetVehicles != null) {
      return onGetVehicles!(filter);
    }
    return vehicles;
  }

  @override
  Future<Vehicle> getVehicleById(String id) async {
    getVehicleByIdCallCount++;
    lastVehicleId = id;
    if (onGetVehicleById != null) {
      return onGetVehicleById!(id);
    }
    final vehicle = vehicles.cast<Vehicle?>().firstWhere(
      (v) => v?.id == id,
      orElse: () => null,
    );
    if (vehicle == null) {
      throw const NotFoundFailure('Kendaraan tidak ditemukan.');
    }
    return vehicle;
  }
}

/// Implementasi tiruan (fake) repositori pemesanan untuk pengujian.
class FakeBookingRepository implements BookingRepository {
  FakeBookingRepository({
    List<Booking>? bookings,
    List<BookedRange>? bookedRanges,
  }) : bookings = bookings ?? [],
       bookedRanges = bookedRanges ?? [];

  List<Booking> bookings;
  List<BookedRange> bookedRanges;

  Future<String> Function(BookingRequest request)? onCreateBooking;
  Future<List<Booking>> Function()? onGetMyBookings;
  Future<Booking> Function(String id)? onGetBooking;
  Future<void> Function(String id)? onCancelBooking;
  Future<List<BookedRange>> Function(String vehicleId)? onGetBookedRanges;

  int createBookingCallCount = 0;
  BookingRequest? lastRequest;
  int getMyBookingsCallCount = 0;
  int getBookingCallCount = 0;
  int cancelBookingCallCount = 0;
  String? lastCancelledId;
  int getBookedRangesCallCount = 0;

  @override
  Future<String> createBooking(BookingRequest request) async {
    createBookingCallCount++;
    lastRequest = request;
    if (onCreateBooking != null) {
      return onCreateBooking!(request);
    }
    const newId = 'bkg-new-123';
    return newId;
  }

  @override
  Future<List<Booking>> getMyBookings() async {
    getMyBookingsCallCount++;
    if (onGetMyBookings != null) {
      return onGetMyBookings!();
    }
    return bookings;
  }

  @override
  Future<Booking> getBooking(String id) async {
    getBookingCallCount++;
    if (onGetBooking != null) {
      return onGetBooking!(id);
    }
    final booking = bookings.cast<Booking?>().firstWhere(
      (b) => b?.id == id,
      orElse: () => null,
    );
    if (booking == null) {
      throw const NotFoundFailure('Pesanan tidak ditemukan.');
    }
    return booking;
  }

  @override
  Future<void> cancelBooking(String id) async {
    cancelBookingCallCount++;
    lastCancelledId = id;
    if (onCancelBooking != null) {
      await onCancelBooking!(id);
      return;
    }
    final index = bookings.indexWhere((b) => b.id == id);
    if (index != -1) {
      final old = bookings[index];
      bookings[index] = Booking(
        id: old.id,
        userId: old.userId,
        vehicleId: old.vehicleId,
        startDate: old.startDate,
        endDate: old.endDate,
        totalDays: old.totalDays,
        pricePerDay: old.pricePerDay,
        totalPrice: old.totalPrice,
        pickupLocation: old.pickupLocation,
        notes: old.notes,
        status: BookingStatus.dibatalkan,
        createdAt: old.createdAt,
        vehicle: old.vehicle,
      );
    }
  }

  @override
  Future<List<BookedRange>> getBookedRanges(String vehicleId) async {
    getBookedRangesCallCount++;
    if (onGetBookedRanges != null) {
      return onGetBookedRanges!(vehicleId);
    }
    return bookedRanges;
  }
}

/// Implementasi tiruan (fake) repositori profil untuk pengujian.
class FakeProfileRepository implements ProfileRepository {
  FakeProfileRepository({this.profile});

  Profile? profile;
  int getProfileCallCount = 0;
  int updateProfileCallCount = 0;
  String? lastUpdatedUserId;
  String? lastUpdatedFullName;
  String? lastUpdatedPhone;

  Future<Profile> Function(String userId)? onGetProfile;
  Future<void> Function(String userId, String fullName, String? phone)?
  onUpdateProfile;

  @override
  Future<Profile> getProfile(String userId) async {
    getProfileCallCount++;
    if (onGetProfile != null) {
      return onGetProfile!(userId);
    }
    if (profile == null) {
      throw const NotFoundFailure('Profil pengguna tidak ditemukan.');
    }
    return profile!;
  }

  @override
  Future<void> updateProfile({
    required String userId,
    required String fullName,
    String? phone,
  }) async {
    updateProfileCallCount++;
    lastUpdatedUserId = userId;
    lastUpdatedFullName = fullName;
    lastUpdatedPhone = phone;
    if (onUpdateProfile != null) {
      await onUpdateProfile!(userId, fullName, phone);
      return;
    }
    if (profile != null) {
      profile = Profile(
        id: profile!.id,
        fullName: fullName,
        phone: phone,
        email: profile!.email,
      );
    }
  }
}
