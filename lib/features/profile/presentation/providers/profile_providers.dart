import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rodakuu/core/network/supabase_providers.dart';
import 'package:rodakuu/features/auth/presentation/providers/auth_providers.dart';
import 'package:rodakuu/features/profile/data/repositories/supabase_profile_repository.dart';
import 'package:rodakuu/features/profile/domain/entities/profile.dart';
import 'package:rodakuu/features/profile/domain/repositories/profile_repository.dart';

/// Provider repositori data profil pengguna.
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return SupabaseProfileRepository(ref.watch(supabaseClientProvider));
});

/// Provider data profil pengguna aktif saat ini.
final profileProvider = FutureProvider.autoDispose<Profile?>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return null;
  return ref.watch(profileRepositoryProvider).getProfile(userId);
});
