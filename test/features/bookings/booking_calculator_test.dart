import 'package:flutter_test/flutter_test.dart';
import 'package:rodakuu/features/bookings/domain/services/booking_calculator.dart';

void main() {
  group('BookingCalculator', () {
    test('T-UT-05: BookingCalculator.totalDays 1–1 Okt dan 1–3 Okt menghasilkan 1 dan 3 hari', () {
      final start1 = DateTime(2026, 10, 1);
      final end1 = DateTime(2026, 10, 1);
      expect(BookingCalculator.totalDays(start1, end1), equals(1));

      final start2 = DateTime(2026, 10, 1);
      final end2 = DateTime(2026, 10, 3);
      expect(BookingCalculator.totalDays(start2, end2), equals(3));

      // Lintas bulan: 29 Okt s/d 2 Nov = 5 hari (29, 30, 31, 1, 2)
      final start3 = DateTime(2026, 10, 29);
      final end3 = DateTime(2026, 11, 2);
      expect(BookingCalculator.totalDays(start3, end3), equals(5));
    });

    test('T-UT-06: BookingCalculator.totalPrice 350000 × 3 = 1050000', () {
      expect(BookingCalculator.totalPrice(350000, 3), equals(1050000));
      expect(BookingCalculator.totalPrice(90000, 1), equals(90000));
      expect(BookingCalculator.totalPrice(0, 5), equals(0));
      expect(BookingCalculator.totalPrice(350000, 0), equals(0));
    });
  });
}
