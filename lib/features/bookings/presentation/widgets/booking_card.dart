import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rodakuu/core/router/app_routes.dart';
import 'package:rodakuu/core/theme/app_colors.dart';
import 'package:rodakuu/core/theme/app_spacing.dart';
import 'package:rodakuu/core/utils/formatters.dart';
import 'package:rodakuu/features/bookings/domain/entities/booking.dart';
import 'package:rodakuu/features/bookings/presentation/widgets/booking_status_chip.dart';
import 'package:rodakuu/features/vehicles/domain/entities/vehicle.dart';
import 'package:rodakuu/features/vehicles/presentation/widgets/vehicle_image.dart';

/// Kartu item riwayat pemesanan pada layar daftar pesanan.
class BookingCard extends StatelessWidget {
  const BookingCard({super.key, required this.booking, this.onTap});

  final Booking booking;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vehicle = booking.vehicle;
    final vehicleName = vehicle?.fullName ?? 'Kendaraan';
    final vehicleType = vehicle?.type ?? VehicleType.mobil;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap ?? () => context.push(AppRoutes.bookingDetail(booking.id)),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 72,
                height: 56,
                child: VehicleImage(
                  type: vehicleType,
                  imageUrl: vehicle?.imageUrl,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  semanticLabel: vehicleName,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            vehicleName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.navy900,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        BookingStatusChip(status: booking.status),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      formatDateRange(booking.startDate, booking.endDate),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      formatRupiah(booking.totalPrice),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColors.navy900,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
