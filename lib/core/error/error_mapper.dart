import 'dart:async';
import 'dart:io';

import 'package:rodakuu/core/error/app_failure.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Memetakan berbagai exception menjadi subclass [AppFailure].
AppFailure mapToFailure(Object error) {
  if (error is AppFailure) {
    return error;
  }

  if (error is SocketException ||
      error is TimeoutException ||
      error is AuthRetryableFetchException) {
    return const NetworkFailure();
  }

  if (error is AuthException) {
    final code = error.code?.toLowerCase() ?? '';
    final message = error.message.toLowerCase();
    final status = error.statusCode;

    if (code == 'invalid_credentials' ||
        message.contains('invalid login credentials') ||
        message.contains('invalid credentials')) {
      return const AuthFailure('Email atau kata sandi salah.');
    }

    if (code == 'user_already_exists' ||
        message.contains('already registered') ||
        message.contains('user already exists')) {
      return const AuthFailure('Email sudah terdaftar.');
    }

    if (code == 'email_not_confirmed' ||
        message.contains('email not confirmed')) {
      return const AuthFailure(
        'Email belum diverifikasi. Periksa kotak masuk Anda.',
      );
    }

    if (code == 'weak_password' || message.contains('weak password')) {
      return const AuthFailure(
        'Kata sandi terlalu lemah. Gunakan minimal 8 karakter.',
      );
    }

    if (code == 'over_request_rate_limit' ||
        status == '429' ||
        message.contains('rate limit')) {
      return const AuthFailure(
        'Terlalu banyak percobaan. Coba lagi beberapa saat.',
      );
    }

    return AuthFailure(error.message);
  }

  if (error is PostgrestException) {
    final code = error.code;
    if (code == '23P01') {
      return const ValidationFailure(
        'Kendaraan sudah dipesan pada tanggal tersebut. Pilih tanggal lain.',
      );
    }

    if (code == '42501') {
      return const ValidationFailure(
        'Anda tidak memiliki akses untuk tindakan ini.',
      );
    }

    if (code == '22023' || code == 'P0002' || code == '28000') {
      return ValidationFailure(error.message);
    }

    return const ServerFailure();
  }

  if (error is FormatException) {
    return ValidationFailure(error.message);
  }

  return const UnknownFailure();
}

/// Mengambil pesan ramah pengguna berbahasa Indonesia dari objek error.
String failureMessage(Object error) {
  if (error is AppFailure) {
    return error.message;
  }
  return mapToFailure(error).message;
}
