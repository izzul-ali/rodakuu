import 'package:rodakuu/core/error/app_failure.dart';
import 'package:rodakuu/core/error/error_mapper.dart';
import 'package:rodakuu/features/profile/data/models/profile_dto.dart';
import 'package:rodakuu/features/profile/domain/entities/profile.dart';
import 'package:rodakuu/features/profile/domain/repositories/profile_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Implementasi [ProfileRepository] menggunakan Supabase Database dan Auth.
class SupabaseProfileRepository implements ProfileRepository {
  SupabaseProfileRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<Profile> getProfile(String userId) async {
    try {
      final data = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (data == null) {
        throw const NotFoundFailure('Profil pengguna tidak ditemukan.');
      }

      final email = _client.auth.currentUser?.email ?? '';
      return ProfileDto.fromJson(data, email: email).toEntity();
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(mapToFailure(error), stackTrace);
    }
  }

  @override
  Future<void> updateProfile({
    required String userId,
    required String fullName,
    String? phone,
  }) async {
    try {
      await _client
          .from('profiles')
          .update({
            'full_name': fullName.trim(),
            'phone': phone != null && phone.trim().isNotEmpty
                ? phone.trim()
                : null,
          })
          .eq('id', userId);
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(mapToFailure(error), stackTrace);
    }
  }
}
