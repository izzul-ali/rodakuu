import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:rodakuu/core/error/error_mapper.dart';
import 'package:rodakuu/features/auth/domain/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Implementasi [AuthRepository] menggunakan Supabase Auth.
class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client);

  final SupabaseClient _client;

  @override
  String? get currentUserId => _client.auth.currentSession?.user.id;

  @override
  Stream<String?> get userIdChanges => _client.auth.onAuthStateChange
      .map((state) => state.session?.user.id)
      .distinct();

  @override
  Future<void> signIn({required String email, required String password}) async {
    try {
      if (kDebugMode) {
        debugPrint('🔐 [SUPABASE_AUTH] Mencoba signIn dengan email: $email');
      }

      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (kDebugMode) {
        debugPrint(
          '🔐 [SUPABASE_AUTH_SUCCESS] signIn berhasil! User ID: ${response.user?.id}, '
          'Session: ${response.session != null ? "Aktif" : "Kosong"}',
        );
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '❌ [SUPABASE_AUTH_FAIL] signIn gagal untuk email $email: $error',
        );
      }
      Error.throwWithStackTrace(mapToFailure(error, stackTrace), stackTrace);
    }
  }

  @override
  Future<SignUpResult> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint(
          '🔐 [SUPABASE_AUTH] Mencoba signUp dengan email: $email, nama: $fullName',
        );
      }

      final res = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );

      if (res.session != null) {
        if (kDebugMode) {
          debugPrint(
            '🔐 [SUPABASE_AUTH_SUCCESS] signUp langsung login: ${res.user?.id}',
          );
        }
        return SignUpResult.signedIn;
      }

      if (kDebugMode) {
        debugPrint(
          '🔐 [SUPABASE_AUTH_SUCCESS] signUp membutuhkan verifikasi email.',
        );
      }
      return SignUpResult.needsEmailVerification;
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [SUPABASE_AUTH_FAIL] signUp gagal: $error');
      }
      Error.throwWithStackTrace(mapToFailure(error, stackTrace), stackTrace);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      if (kDebugMode) {
        debugPrint(
          '🔐 [SUPABASE_AUTH] Melakukan signOut user ID: ${_client.auth.currentUser?.id}',
        );
      }

      await _client.auth.signOut();

      if (kDebugMode) {
        debugPrint('🔐 [SUPABASE_AUTH_SUCCESS] signOut berhasil.');
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ [SUPABASE_AUTH_FAIL] signOut gagal: $error');
      }
      Error.throwWithStackTrace(mapToFailure(error, stackTrace), stackTrace);
    }
  }
}
