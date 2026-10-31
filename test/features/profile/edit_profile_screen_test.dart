import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rodakuu/core/config/app_strings.dart';
import 'package:rodakuu/features/auth/presentation/providers/auth_providers.dart';
import 'package:rodakuu/features/profile/domain/entities/profile.dart';
import 'package:rodakuu/features/profile/presentation/providers/profile_providers.dart';
import 'package:rodakuu/features/profile/presentation/screens/edit_profile_screen.dart';

import '../../helpers/fakes.dart';
import '../../helpers/pump_app.dart';

void main() {
  group('EditProfileScreen', () {
    late FakeAuthRepository fakeAuth;
    late FakeProfileRepository fakeProfile;

    const initialProfile = Profile(
      id: 'user-123',
      fullName: 'Budi Santoso',
      phone: '081234567890',
      email: 'budi@example.com',
    );

    setUp(() {
      fakeAuth = FakeAuthRepository(userId: 'user-123');
      fakeProfile = FakeProfileRepository(profile: initialProfile);
    });

    tearDown(() {
      fakeAuth.dispose();
    });

    testWidgets(
      'T-WT-15: ubah profil dengan nama 1 huruf menampilkan pesan validasi dan tidak menyimpan',
      (tester) async {
        await pumpApp(
          tester,
          const EditProfileScreen(),
          overrides: [
            authRepositoryProvider.overrideWithValue(fakeAuth),
            profileRepositoryProvider.overrideWithValue(fakeProfile),
          ],
        );
        await tester.pumpAndSettle();

        expect(find.text('Budi Santoso'), findsOneWidget);
        expect(find.text('081234567890'), findsOneWidget);
        expect(find.text('budi@example.com'), findsOneWidget);

        // Ubah nama menjadi 1 huruf saja
        final nameField = find.widgetWithText(TextFormField, 'Budi Santoso');
        await tester.enterText(nameField, 'A');
        await tester.pumpAndSettle();

        // Tekan Simpan
        final saveButton = find.widgetWithText(
          FilledButton,
          AppStrings.actionSave,
        );
        await tester.tap(saveButton);
        await tester.pumpAndSettle();

        expect(find.text('Nama lengkap minimal 2 karakter.'), findsOneWidget);
        expect(fakeProfile.updateProfileCallCount, equals(0));
      },
    );

    testWidgets(
      'Ubah profil dengan data valid berhasil memanggil repositori dan menampilkan SnackBar',
      (tester) async {
        await pumpApp(
          tester,
          const EditProfileScreen(),
          overrides: [
            authRepositoryProvider.overrideWithValue(fakeAuth),
            profileRepositoryProvider.overrideWithValue(fakeProfile),
          ],
        );
        await tester.pumpAndSettle();

        final nameField = find.widgetWithText(TextFormField, 'Budi Santoso');
        await tester.enterText(nameField, 'Budi Perkasa');

        final phoneField = find.widgetWithText(TextFormField, '081234567890');
        await tester.enterText(phoneField, '089876543210');
        await tester.pumpAndSettle();

        final saveButton = find.widgetWithText(
          FilledButton,
          AppStrings.actionSave,
        );
        await tester.tap(saveButton);
        await tester.pumpAndSettle();

        expect(fakeProfile.updateProfileCallCount, equals(1));
        expect(fakeProfile.lastUpdatedFullName, equals('Budi Perkasa'));
        expect(fakeProfile.lastUpdatedPhone, equals('089876543210'));
        expect(find.text(AppStrings.profileUpdatedMessage), findsOneWidget);
      },
    );
  });
}
