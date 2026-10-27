import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rodakuu/core/network/supabase_providers.dart';
import 'package:rodakuu/features/auth/data/supabase_auth_repository.dart';
import 'package:rodakuu/features/auth/domain/auth_repository.dart';

/// Provider repositori autentikasi aplikasi.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return SupabaseAuthRepository(ref.watch(supabaseClientProvider));
});

/// Notifier untuk melacak ID pengguna yang aktif secara reaktif.
class CurrentUserIdNotifier extends Notifier<String?> {
  StreamSubscription<String?>? _subscription;

  @override
  String? build() {
    final repository = ref.watch(authRepositoryProvider);
    _subscription?.cancel();
    _subscription = repository.userIdChanges.listen((id) {
      state = id;
    });

    ref.onDispose(() {
      _subscription?.cancel();
      _subscription = null;
    });

    return repository.currentUserId;
  }
}

/// Provider state ID pengguna aktif saat ini.
final currentUserIdProvider = NotifierProvider<CurrentUserIdNotifier, String?>(
  CurrentUserIdNotifier.new,
);
