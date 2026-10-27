import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rodakuu/features/auth/domain/auth_repository.dart';
import 'package:rodakuu/features/auth/presentation/providers/auth_providers.dart';

/// Pengendali proses pendaftaran akun pengguna baru.
class RegisterController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  /// Mendaftarkan pengguna baru dan mengembalikan hasil pendaftaran.
  Future<SignUpResult?> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    SignUpResult? result;
    state = await AsyncValue.guard(() async {
      result = await ref
          .read(authRepositoryProvider)
          .signUp(
            fullName: fullName.trim(),
            email: email.trim(),
            password: password,
          );
    });
    if (state.hasError) return null;
    return result;
  }
}

/// Provider pengontrol registrasi.
final registerControllerProvider =
    AsyncNotifierProvider.autoDispose<RegisterController, void>(
      RegisterController.new,
    );
