import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rodakuu/features/auth/presentation/providers/auth_providers.dart';
import 'package:rodakuu/features/profile/domain/entities/profile.dart';

/// Provider data profil pengguna saat ini.
final profileProvider = FutureProvider.autoDispose<Profile?>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return null;
  return null;
});
