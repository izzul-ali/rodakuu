import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rodakuu/core/error/app_failure.dart';
import 'package:rodakuu/features/auth/presentation/providers/auth_providers.dart';
import 'package:rodakuu/features/auth/presentation/screens/login_screen.dart';

import '../../helpers/fakes.dart';
import '../../helpers/pump_app.dart';

void main() {
  group('LoginScreen', () {
    late FakeAuthRepository fakeAuth;

    setUp(() {
      fakeAuth = FakeAuthRepository();
    });

    tearDown(() {
      fakeAuth.dispose();
    });

    testWidgets(
      'T-WT-01: submit kosong menampilkan pesan validasi dan repository tidak dipanggil',
      (tester) async {
        await pumpApp(
          tester,
          const LoginScreen(),
          overrides: [authRepositoryProvider.overrideWithValue(fakeAuth)],
        );

        final submitButton = find.widgetWithText(FilledButton, 'Masuk');
        expect(submitButton, findsOneWidget);

        await tester.tap(submitButton);
        await tester.pumpAndSettle();

        expect(find.text('Email wajib diisi.'), findsOneWidget);
        expect(find.text('Kata sandi wajib diisi.'), findsOneWidget);
        expect(fakeAuth.signInCallCount, equals(0));
      },
    );

    testWidgets('T-WT-02: kredensial salah menampilkan SnackBar pesan error', (
      tester,
    ) async {
      fakeAuth.onSignIn = (email, password) async {
        throw const AuthFailure('Email atau kata sandi salah.');
      };

      await pumpApp(
        tester,
        const LoginScreen(),
        overrides: [authRepositoryProvider.overrideWithValue(fakeAuth)],
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, '').first,
        'user@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, '').last,
        'password123',
      );

      await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(fakeAuth.signInCallCount, equals(1));
      expect(find.text('Email atau kata sandi salah.'), findsOneWidget);
    });

    testWidgets('Toggle visibilitas kata sandi berfungsi', (tester) async {
      await pumpApp(
        tester,
        const LoginScreen(),
        overrides: [authRepositoryProvider.overrideWithValue(fakeAuth)],
      );

      final toggleButton = find.byTooltip('Tampilkan kata sandi');
      expect(toggleButton, findsOneWidget);

      await tester.tap(toggleButton);
      await tester.pumpAndSettle();

      expect(find.byTooltip('Sembunyikan kata sandi'), findsOneWidget);
    });
  });
}
