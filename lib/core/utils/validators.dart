/// Kumpulan fungsi validator input formulir berbahasa Indonesia.
abstract final class Validators {
  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$',
  );

  static final RegExp _phoneRegExp = RegExp(r'^(?:\+62|08)[0-9]{7,12}$');

  /// Validasi alamat email.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email wajib diisi.';
    }
    final trimmed = value.trim();
    if (!_emailRegExp.hasMatch(trimmed) || !trimmed.contains('.')) {
      return 'Format email tidak valid.';
    }
    return null;
  }

  /// Validasi kata sandi (minimal 8 karakter).
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Kata sandi wajib diisi.';
    }
    if (value.length < 8) {
      return 'Kata sandi minimal 8 karakter.';
    }
    return null;
  }

  /// Validasi kesamaan konfirmasi kata sandi.
  static String? confirmPassword(String? value, String? originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi kata sandi wajib diisi.';
    }
    if (value != originalPassword) {
      return 'Konfirmasi kata sandi tidak cocok.';
    }
    return null;
  }

  /// Validasi nama lengkap (minimal 2 karakter).
  static String? fullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama lengkap wajib diisi.';
    }
    if (value.trim().length < 2) {
      return 'Nama lengkap minimal 2 karakter.';
    }
    return null;
  }

  /// Validasi nomor telepon Indonesia (opsional).
  /// Bila diisi, harus 9–14 digit diawali 08 atau +62.
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final trimmed = value.trim();
    if (!_phoneRegExp.hasMatch(trimmed)) {
      return 'Format nomor telepon tidak valid.';
    }
    return null;
  }

  /// Validasi lokasi pengambilan (wajib, minimal 3 karakter).
  static String? pickupLocation(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Lokasi pengambilan wajib diisi.';
    }
    if (value.trim().length < 3) {
      return 'Lokasi pengambilan minimal 3 karakter.';
    }
    return null;
  }

  /// Validasi teks wajib umum.
  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null
          ? '$fieldName wajib diisi.'
          : 'Bidang ini wajib diisi.';
    }
    return null;
  }

  /// Validasi catatan pemesanan (opsional, maks 200 karakter).
  static String? notes(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (value.length > 200) {
      return 'Catatan maksimal 200 karakter.';
    }
    return null;
  }
}
