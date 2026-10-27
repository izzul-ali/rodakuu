/// Konstanta global aplikasi RodaKuu.
abstract final class AppConstants {
  static const int maxRentalDays = 30;
  static const int priceFilterMin = 0;
  static const int priceFilterMax = 1000000;
  static const int priceFilterStep = 10000;
  static const Duration searchDebounce = Duration(milliseconds: 400);
  static const int vehicleQueryLimit = 200;
  static const int bookingQueryLimit = 100;
  static const int notesMaxLength = 200;
}
