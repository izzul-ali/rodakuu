/// Hasil dari proses pendaftaran pengguna baru.
enum SignUpResult {
  /// Berhasil mendaftar dan langsung mendapatkan sesi masuk.
  signedIn,

  /// Berhasil mendaftar namun memerlukan verifikasi email sebelum bisa masuk.
  needsEmailVerification,
}

/// Kontrak repositori autentikasi yang independen dari implementasi Supabase.
abstract interface class AuthRepository {
  /// ID pengguna yang sedang masuk saat ini, atau null jika belum masuk.
  String? get currentUserId;

  /// Stream perubahan ID pengguna (berisi null saat pengguna keluar).
  Stream<String?> get userIdChanges;

  /// Masuk menggunakan alamat email dan kata sandi.
  Future<void> signIn({required String email, required String password});

  /// Mendaftarkan akun baru dengan nama lengkap, email, dan kata sandi.
  Future<SignUpResult> signUp({
    required String fullName,
    required String email,
    required String password,
  });

  /// Keluar dari sesi saat ini.
  Future<void> signOut();
}
