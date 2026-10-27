import 'package:intl/intl.dart';

/// Memformat bilangan bulat ke representasi Rupiah (contoh: "Rp 350.000").
String formatRupiah(int amount) {
  final formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  return formatter.format(amount).replaceAll('\u00A0', ' ').trim();
}

/// Memformat objek [DateTime] ke format tanggal Indonesia (contoh: "12 Okt 2026").
String formatDate(DateTime date) {
  return DateFormat('d MMM yyyy', 'id_ID').format(date);
}

/// Memformat rentang tanggal menjadi string ringkas Indonesia.
/// Contoh: "12 Okt – 14 Okt 2026" atau "28 Des 2026 – 2 Jan 2027".
String formatDateRange(DateTime start, DateTime end) {
  if (start.year == end.year) {
    if (start.month == end.month && start.day == end.day) {
      return formatDate(start);
    }
    final startFormatted = DateFormat('d MMM', 'id_ID').format(start);
    final endFormatted = DateFormat('d MMM yyyy', 'id_ID').format(end);
    return '$startFormatted – $endFormatted';
  }
  return '${formatDate(start)} – ${formatDate(end)}';
}

/// Merakit tanggal [DateTime] menjadi string ISO tanpa waktu "yyyy-MM-dd".
/// Dirakit manual dengan padLeft agar terbebas dari pergeseran zona waktu.
String toDateOnlyString(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}
