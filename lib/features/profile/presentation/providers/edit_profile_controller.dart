import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rodakuu/core/error/app_failure.dart';
import 'package:rodakuu/features/auth/presentation/providers/auth_providers.dart';
import 'package:rodakuu/features/profile/presentation/providers/profile_providers.dart';

/// Pengendali formulir ubah data profil pengguna.
class EditProfileController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  /// Mengirim pembaruan nama lengkap dan nomor telepon ke server.
  Future<bool> updateProfile({required String fullName, String? phone}) async {
    state = const AsyncLoading();
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      state = AsyncError(
        const AuthFailure('Pengguna belum masuk.'),
        StackTrace.current,
      );
      return false;
    }

    state = await AsyncValue.guard(() async {
      await ref
          .read(profileRepositoryProvider)
          .updateProfile(userId: userId, fullName: fullName, phone: phone);
      ref.invalidate(profileProvider);
    });

    return !state.hasError;
  }
}

/// Provider pengontrol ubah profil.
final editProfileControllerProvider =
    AsyncNotifierProvider.autoDispose<EditProfileController, void>(
      EditProfileController.new,
    );
