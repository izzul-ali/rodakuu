import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:rodakuu/core/utils/formatters.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID');
  });

  group('Formatters', () {
    test('T-UT-04: formatRupiah(350000)', () {
      final formatted = formatRupiah(350000).replaceAll('\u00A0', ' ');
      expect(formatted, equals('Rp 350.000'));
    });

    test('formatDate', () {
      final date = DateTime(2026, 10, 12);
      expect(formatDate(date), equals('12 Okt 2026'));
    });

    test('formatDateRange', () {
      final start = DateTime(2026, 10, 12);
      final end = DateTime(2026, 10, 14);
      expect(formatDateRange(start, end), equals('12 Okt – 14 Okt 2026'));

      final sameDate = DateTime(2026, 10, 12);
      expect(formatDateRange(start, sameDate), equals('12 Okt 2026'));

      final crossYear = DateTime(2027, 1, 2);
      expect(
        formatDateRange(DateTime(2026, 12, 28), crossYear),
        equals('28 Des 2026 – 2 Jan 2027'),
      );
    });

    test('toDateOnlyString', () {
      final date = DateTime(2026, 4, 9, 23, 59);
      expect(toDateOnlyString(date), equals('2026-04-09'));
    });
  });
}
