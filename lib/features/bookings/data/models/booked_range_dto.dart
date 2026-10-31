import 'package:rodakuu/features/bookings/domain/entities/booked_range.dart';

/// Data Transfer Object untuk rentang tanggal pesanan yang telah terisi.
class BookedRangeDto {
  const BookedRangeDto({required this.startDate, required this.endDate});

  final String startDate;
  final String endDate;

  factory BookedRangeDto.fromJson(Map<String, dynamic> json) {
    return BookedRangeDto(
      startDate: json['start_date'] as String,
      endDate: json['end_date'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'start_date': startDate, 'end_date': endDate};
  }

  BookedRange toEntity() {
    return BookedRange(
      startDate: DateTime.parse(startDate),
      endDate: DateTime.parse(endDate),
    );
  }
}
