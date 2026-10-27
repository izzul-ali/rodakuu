import 'package:flutter_test/flutter_test.dart';
import 'package:rodakuu/core/utils/validators.dart';

void main() {
  group('Validators', () {
    test('T-UT-01: Validators.email dengan "a", "a@b", "a@b.com"', () {
      expect(Validators.email('a'), isNotNull);
      expect(Validators.email('a@b'), isNotNull);
      expect(Validators.email('a@b.com'), isNull);
    });

    test('T-UT-02: Validators.password panjang 7 dan 8', () {
      expect(Validators.password('1234567'), isNotNull);
      expect(Validators.password('12345678'), isNull);
    });

    test('T-UT-03: Validators.phone "", "08123456789", "+628123456789", "0812", "abc"', () {
      expect(Validators.phone(''), isNull);
      expect(Validators.phone('08123456789'), isNull);
      expect(Validators.phone('+628123456789'), isNull);
      expect(Validators.phone('0812'), isNotNull);
      expect(Validators.phone('abc'), isNotNull);
    });

    test('Validators.confirmPassword', () {
      expect(Validators.confirmPassword('', 'rahasia123'), isNotNull);
      expect(Validators.confirmPassword('rahasia456', 'rahasia123'), isNotNull);
      expect(Validators.confirmPassword('rahasia123', 'rahasia123'), isNull);
    });

    test('Validators.fullName', () {
      expect(Validators.fullName(''), isNotNull);
      expect(Validators.fullName('A'), isNotNull);
      expect(Validators.fullName('Budi'), isNull);
    });

    test('Validators.pickupLocation', () {
      expect(Validators.pickupLocation(''), isNotNull);
      expect(Validators.pickupLocation('AB'), isNotNull);
      expect(Validators.pickupLocation('Stasiun Gambir'), isNull);
    });

    test('Validators.notes', () {
      expect(Validators.notes(null), isNull);
      expect(Validators.notes(''), isNull);
      expect(Validators.notes('a' * 200), isNull);
      expect(Validators.notes('a' * 201), isNotNull);
    });
  });
}
