import 'dart:async';

import 'package:rodakuu/core/error/app_failure.dart';
import 'package:rodakuu/features/auth/domain/auth_repository.dart';
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
