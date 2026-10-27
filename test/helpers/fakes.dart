import 'dart:async';

import 'package:rodakuu/features/auth/domain/auth_repository.dart';

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
