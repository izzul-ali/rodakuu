import 'package:material_ui/material_ui.dart';
import 'package:rodakuu/core/config/app_constants.dart';
import 'package:rodakuu/core/theme/app_colors.dart';
import 'package:rodakuu/core/theme/app_spacing.dart';
import 'package:rodakuu/core/utils/formatters.dart';
import 'package:rodakuu/features/bookings/domain/entities/booked_range.dart';
import 'package:rodakuu/features/bookings/domain/services/booking_calculator.dart';

/// Bidang pemilih rentang tanggal sewa dengan validasi maksimal 30 hari dan deteksi tabrakan.
class DateRangeField extends StatelessWidget {
  const DateRangeField({
    super.key,
    required this.selectedRange,
    required this.onRangeChanged,
    this.bookedRanges = const [],
    this.errorMessage,
  });

  final DateTimeRange? selectedRange;
  final ValueChanged<DateTimeRange?> onRangeChanged;
  final List<BookedRange> bookedRanges;
  final String? errorMessage;

  Future<void> _pickDateRange(BuildContext context) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final maxDate = today.add(const Duration(days: 365));

    final picked = await showDateRangePicker(
      context: context,
      firstDate: today,
      lastDate: maxDate,
      initialDateRange: selectedRange,
      helpText: 'Pilih Rentang Tanggal Sewa',
      cancelText: 'Batal',
      confirmText: 'Pilih',
      saveText: 'Pilih',
    );

    if (picked != null) {
      onRangeChanged(picked);
    }
  }

  static String? validateDateRange(
    DateTimeRange? range,
    List<BookedRange> bookedRanges,
  ) {
    if (range == null) {
      return 'Rentang tanggal sewa wajib dipilih.';
    }

    final totalDays = BookingCalculator.totalDays(range.start, range.end);
    if (totalDays > AppConstants.maxRentalDays) {
      return 'Durasi sewa maksimal 30 hari.';
    }

    for (final booked in bookedRanges) {
      if (booked.overlaps(range.start, range.end)) {
        return 'Tanggal bertabrakan dengan pesanan lain.';
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    String displayText;
    Color textColor = AppColors.navy900;

    if (selectedRange != null) {
      final days = BookingCalculator.totalDays(
        selectedRange!.start,
        selectedRange!.end,
      );
      displayText =
          '${formatDateRange(selectedRange!.start, selectedRange!.end)} • $days hari';
    } else {
      displayText = 'Pilih tanggal mulai & selesai';
      textColor = AppColors.textDisabled;
    }

    final hasError = errorMessage != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rentang Tanggal Sewa',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.navy900,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        InkWell(
          onTap: () => _pickDateRange(context),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.lg,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(
                color: hasError ? AppColors.error : AppColors.borderStrong,
                width: hasError ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.date_range_rounded,
                  color: AppColors.navy900,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    displayText,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: textColor,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            errorMessage!,
            style: theme.textTheme.bodySmall?.copyWith(color: AppColors.error),
          ),
        ],
      ],
    );
  }
}
