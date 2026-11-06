import 'package:material_ui/material_ui.dart';
import 'package:rodakuu/core/theme/app_colors.dart';
import 'package:rodakuu/core/theme/app_spacing.dart';
import 'package:rodakuu/features/bookings/domain/entities/booking.dart';

/// Chip penanda status transaksi pemesanan dengan palet warna semantik.
class BookingStatusChip extends StatelessWidget {
  const BookingStatusChip({
    super.key,
    required this.status,
    this.isLarge = false,
  });

  final BookingStatus status;
  final bool isLarge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final (textColor, bgColor) = switch (status) {
      BookingStatus.menunggu => (AppColors.warning, AppColors.warningBg),
      BookingStatus.dikonfirmasi => (AppColors.navy900, AppColors.navy50),
      BookingStatus.selesai => (AppColors.success, AppColors.successBg),
      BookingStatus.dibatalkan => (
        AppColors.textSecondary,
        AppColors.neutralBg,
      ),
    };

    return Semantics(
      container: true,
      label: status.label,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isLarge ? AppSpacing.md : AppSpacing.sm,
          vertical: isLarge ? AppSpacing.sm : AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          border: Border.all(
            color: status == BookingStatus.dikonfirmasi
                ? AppColors.border
                : textColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Text(
          status.label,
          style:
              (isLarge
                      ? theme.textTheme.labelLarge
                      : theme.textTheme.labelSmall)
                  ?.copyWith(color: textColor, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
