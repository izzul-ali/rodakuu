import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rodakuu/features/auth/presentation/providers/auth_providers.dart';

/// Pengendali proses masuk (login) pengguna.
class LoginController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  /// Menjalankan autentikasi masuk, mengembalikan true jika sukses.
  Future<bool> signIn({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(authRepositoryProvider)
          .signIn(email: email.trim(), password: password),
    );
    return !state.hasError;
  }
}

/// Provider siklus hidup pengontrol login.
final loginControllerProvider =
    AsyncNotifierProvider.autoDispose<LoginController, void>(
      LoginController.new,
    );
