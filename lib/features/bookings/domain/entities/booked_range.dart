import 'package:flutter/foundation.dart';

/// Rentang tanggal yang sudah dipesan untuk sebuah kendaraan.
@immutable
class BookedRange {
  const BookedRange({required this.startDate, required this.endDate});

  final DateTime startDate;
  final DateTime endDate;

  /// Memeriksa apakah rentang [start] s/d [end] bertabrakan dengan rentang ini.
  bool overlaps(DateTime start, DateTime end) {
    final sUtc = DateTime.utc(start.year, start.month, start.day);
    final eUtc = DateTime.utc(end.year, end.month, end.day);
    final selfStart = DateTime.utc(
      startDate.year,
      startDate.month,
      startDate.day,
    );
    final selfEnd = DateTime.utc(endDate.year, endDate.month, endDate.day);

    return !(eUtc.isBefore(selfStart) || sUtc.isAfter(selfEnd));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookedRange &&
          runtimeType == other.runtimeType &&
          startDate.year == other.startDate.year &&
          startDate.month == other.startDate.month &&
          startDate.day == other.startDate.day &&
          endDate.year == other.endDate.year &&
          endDate.month == other.endDate.month &&
          endDate.day == other.endDate.day;

  @override
  int get hashCode => Object.hash(
    startDate.year,
    startDate.month,
    startDate.day,
    endDate.year,
    endDate.month,
    endDate.day,
  );
}
