import 'package:flutter/foundation.dart';

/// Kelas dasar kegagalan (failure) aplikasi yang aman dan terstruktur.
@immutable
sealed class AppFailure implements Exception {
  const AppFailure(this.message);
  final String message;

  @override
  String toString() => message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppFailure &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => Object.hash(runtimeType, message);
}

/// Kegagalan koneksi jaringan atau timeout.
final class NetworkFailure extends AppFailure {
  const NetworkFailure([
    super.message = 'Tidak dapat terhubung ke internet. Periksa koneksi Anda.',
  ]);
}

/// Kegagalan autentikasi (login, register, session).
final class AuthFailure extends AppFailure {
  const AuthFailure(super.message);
}

/// Data yang dicari tidak ditemukan.
final class NotFoundFailure extends AppFailure {
  const NotFoundFailure(super.message);
}

/// Validasi data masukan tidak memenuhi syarat.
final class ValidationFailure extends AppFailure {
  const ValidationFailure(super.message);
}

/// Kegagalan internal server database / RPC.
final class ServerFailure extends AppFailure {
  const ServerFailure([
    super.message = 'Terjadi kesalahan pada server. Coba lagi beberapa saat.',
  ]);
}

/// Kegagalan umum yang tidak teridentifikasi.
final class UnknownFailure extends AppFailure {
  const UnknownFailure([
    super.message = 'Terjadi kesalahan yang tidak diketahui.',
  ]);
}
