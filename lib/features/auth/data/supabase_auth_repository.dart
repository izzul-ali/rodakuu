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
      await _client.auth.signInWithPassword(email: email, password: password);
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(mapToFailure(error), stackTrace);
    }
  }

  @override
  Future<SignUpResult> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final res = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );
      if (res.session != null) {
        return SignUpResult.signedIn;
      }
      return SignUpResult.needsEmailVerification;
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(mapToFailure(error), stackTrace);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(mapToFailure(error), stackTrace);
    }
  }
}
