import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rodakuu/features/auth/domain/auth_repository.dart';
import 'package:rodakuu/features/auth/presentation/providers/auth_providers.dart';
import 'package:rodakuu/features/auth/presentation/screens/register_screen.dart';

import '../../helpers/fakes.dart';
import '../../helpers/pump_app.dart';

void main() {
  group('RegisterScreen', () {
    late FakeAuthRepository fakeAuth;

    setUp(() {
      fakeAuth = FakeAuthRepository();
    });

    tearDown(() {
      fakeAuth.dispose();
    });

    testWidgets(
      'T-WT-03: konfirmasi kata sandi berbeda menampilkan pesan validasi',
      (tester) async {
        await pumpApp(
          tester,
          const RegisterScreen(),
          overrides: [authRepositoryProvider.overrideWithValue(fakeAuth)],
        );

        // Isi form dengan kata sandi tidak cocok
        final textFields = find.byType(TextFormField);
        await tester.enterText(textFields.at(0), 'Budi Santoso');
        await tester.enterText(textFields.at(1), 'budi@example.com');
        await tester.enterText(textFields.at(2), 'password123');
        await tester.enterText(textFields.at(3), 'password456');

        await tester.tap(find.widgetWithText(FilledButton, 'Daftar'));
        await tester.pumpAndSettle();

        expect(find.text('Konfirmasi kata sandi tidak cocok.'), findsOneWidget);
        expect(fakeAuth.signUpCallCount, equals(0));
      },
    );

    testWidgets(
      'T-WT-04: fake mengembalikan needsEmailVerification menampilkan pesan verifikasi',
      (tester) async {
        fakeAuth.onSignUp = (name, email, pass) async {
          return SignUpResult.needsEmailVerification;
        };

        await pumpApp(
          tester,
          const RegisterScreen(),
          overrides: [authRepositoryProvider.overrideWithValue(fakeAuth)],
        );

        final textFields = find.byType(TextFormField);
        await tester.enterText(textFields.at(0), 'Budi Santoso');
        await tester.enterText(textFields.at(1), 'budi@example.com');
        await tester.enterText(textFields.at(2), 'password123');
        await tester.enterText(textFields.at(3), 'password123');

        await tester.tap(find.widgetWithText(FilledButton, 'Daftar'));
        await tester.pump();
        await tester.pumpAndSettle();

        expect(fakeAuth.signUpCallCount, equals(1));
        expect(
          find.text('Periksa email Anda untuk verifikasi.'),
          findsOneWidget,
        );
      },
    );

    testWidgets('Validasi field wajib pendaftaran', (tester) async {
      await pumpApp(
        tester,
        const RegisterScreen(),
        overrides: [authRepositoryProvider.overrideWithValue(fakeAuth)],
      );

      await tester.tap(find.widgetWithText(FilledButton, 'Daftar'));
      await tester.pumpAndSettle();

      expect(find.text('Nama lengkap wajib diisi.'), findsOneWidget);
      expect(find.text('Email wajib diisi.'), findsOneWidget);
      expect(find.text('Kata sandi wajib diisi.'), findsOneWidget);
      expect(find.text('Konfirmasi kata sandi wajib diisi.'), findsOneWidget);
    });
  });
}
