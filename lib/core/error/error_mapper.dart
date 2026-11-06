import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:rodakuu/core/error/app_failure.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Memetakan berbagai exception menjadi subclass [AppFailure] dengan logging debug lengkap.
AppFailure mapToFailure(Object error, [StackTrace? stackTrace]) {
  if (error is AppFailure) {
    return error;
  }

  if (kDebugMode) {
    debugPrint(
      '═══════════════════════════════════════════════════════════════',
    );
    debugPrint('🚨 [SUPABASE_ERROR] Terjadi kesalahan: (${error.runtimeType})');
    debugPrint('🚨 [MESSAGE]: $error');

    if (error is SocketException) {
      debugPrint(
        '🚨 [SOCKET_DETAIL] OS Error: ${error.osError?.message} '
        '(code: ${error.osError?.errorCode})',
      );
      debugPrint(
        '🚨 [SOCKET_DETAIL] Host: ${error.address?.host}, Port: ${error.port}',
      );
    } else if (error is AuthException) {
      debugPrint(
        '🚨 [AUTH_DETAIL] Code: ${error.code}, StatusCode: ${error.statusCode}, '
        'Message: ${error.message}',
      );
    } else if (error is PostgrestException) {
      debugPrint(
        '🚨 [POSTGREST_DETAIL] Code: ${error.code}, Message: ${error.message}',
      );
      debugPrint(
        '🚨 [POSTGREST_DETAIL] Details: ${error.details}, Hint: ${error.hint}',
      );
    } else if (error is TimeoutException) {
      debugPrint(
        '🚨 [TIMEOUT_DETAIL] Durasi: ${error.duration}, Message: ${error.message}',
      );
    } else if (error is HttpException) {
      debugPrint(
        '🚨 [HTTP_DETAIL] URI: ${error.uri}, Message: ${error.message}',
      );
    }

    if (stackTrace != null) {
      debugPrint('🚨 [STACKTRACE]:\n$stackTrace');
    }
  }

  final failure = _resolveFailure(error);

  if (kDebugMode) {
    debugPrint(
      '📌 [MAPPED_TO]: ${failure.runtimeType} -> "${failure.message}"',
    );
    debugPrint(
      '═══════════════════════════════════════════════════════════════',
    );
  }

  return failure;
}

AppFailure _resolveFailure(Object error) {
  final errorStr = error.toString().toLowerCase();

  if (error is SocketException ||
      error is TimeoutException ||
      error is AuthRetryableFetchException ||
      errorStr.contains('socketexception') ||
      errorStr.contains('clientexception') ||
      errorStr.contains('failed host lookup') ||
      errorStr.contains('network is unreachable') ||
      errorStr.contains('connection refused') ||
      errorStr.contains('connection closed') ||
      errorStr.contains('connection reset') ||
      errorStr.contains('handshakeexception') ||
      errorStr.contains('tlsexception')) {
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
