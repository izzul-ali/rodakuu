import 'package:rodakuu/features/profile/domain/entities/profile.dart';

/// Kontrak repositori profil pengguna.
abstract interface class ProfileRepository {
  /// Mengambil data profil pengguna berdasarkan ID.
  Future<Profile> getProfile(String userId);

  /// Memperbarui informasi nama lengkap dan nomor telepon profil.
  Future<void> updateProfile({
    required String userId,
    required String fullName,
    String? phone,
  });
}
