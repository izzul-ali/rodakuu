import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rodakuu/core/error/app_failure.dart';
import 'package:rodakuu/core/error/error_mapper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('ErrorMapper', () {
    test('T-UT-09: mapToFailure(PostgrestException(code: \'23P01\')) menghasilkan pesan tabrakan tanggal', () {
      const exception = PostgrestException(
        code: '23P01',
        message: 'conflicting key value violates exclusion constraint',
      );
      final failure = mapToFailure(exception);
      expect(failure, isA<ValidationFailure>());
      expect(
        failure.message,
        equals(
          'Kendaraan sudah dipesan pada tanggal tersebut. Pilih tanggal lain.',
        ),
      );
    });

    test(
      'T-UT-10: mapToFailure(SocketException) menghasilkan NetworkFailure',
      () {
        const exception = SocketException('Failed host lookup');
        final failure = mapToFailure(exception);
        expect(failure, isA<NetworkFailure>());
        expect(
          failure.message,
          equals('Tidak dapat terhubung ke internet. Periksa koneksi Anda.'),
        );
      },
    );

    test('AuthException pemetaan ramah pengguna', () {
      const invalidCreds = AuthException(
        'Invalid login credentials',
        code: 'invalid_credentials',
      );
      expect(mapToFailure(invalidCreds), isA<AuthFailure>());
      expect(
        mapToFailure(invalidCreds).message,
        equals('Email atau kata sandi salah.'),
      );

      const userExists = AuthException(
        'User already registered',
        code: 'user_already_exists',
      );
      expect(
        mapToFailure(userExists).message,
        equals('Email sudah terdaftar.'),
      );

      const unconfirmed = AuthException(
        'Email not confirmed',
        code: 'email_not_confirmed',
      );
      expect(
        mapToFailure(unconfirmed).message,
        equals('Email belum diverifikasi. Periksa kotak masuk Anda.'),
      );

      const weakPass = AuthException(
        'Password is too short',
        code: 'weak_password',
      );
      expect(
        mapToFailure(weakPass).message,
        equals('Kata sandi terlalu lemah. Gunakan minimal 8 karakter.'),
      );
    });

    test('failureMessage helper', () {
      expect(failureMessage(const AuthFailure('Gagal')), equals('Gagal'));
      expect(
        failureMessage(const SocketException('Koneksi terputus')),
        equals('Tidak dapat terhubung ke internet. Periksa koneksi Anda.'),
      );
    });
  });
}
