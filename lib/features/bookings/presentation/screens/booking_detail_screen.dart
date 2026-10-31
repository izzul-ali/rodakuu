import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rodakuu/core/config/app_strings.dart';
import 'package:rodakuu/core/error/error_mapper.dart';
import 'package:rodakuu/core/theme/app_colors.dart';
import 'package:rodakuu/core/theme/app_spacing.dart';
import 'package:rodakuu/core/utils/formatters.dart';
import 'package:rodakuu/core/utils/responsive.dart';
import 'package:rodakuu/core/widgets/app_button.dart';
import 'package:rodakuu/core/widgets/app_error_view.dart';
import 'package:rodakuu/core/widgets/app_loading.dart';
import 'package:rodakuu/core/widgets/responsive_center.dart';
import 'package:rodakuu/features/bookings/domain/entities/booking.dart';
import 'package:rodakuu/features/bookings/presentation/providers/booking_providers.dart';
import 'package:rodakuu/features/bookings/presentation/providers/cancel_booking_controller.dart';
import 'package:rodakuu/features/bookings/presentation/widgets/booking_status_chip.dart';
import 'package:rodakuu/features/vehicles/domain/entities/vehicle.dart';
import 'package:rodakuu/features/vehicles/presentation/widgets/vehicle_image.dart';

/// Layar rincian lengkap transaksi pemesanan dan opsi pembatalan pesanan.
class BookingDetailScreen extends ConsumerWidget {
  const BookingDetailScreen({super.key, required this.bookingId});

  final String bookingId;

  Future<void> _confirmCancel(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(AppStrings.cancelBookingConfirmTitle),
          content: const Text(AppStrings.cancelBookingConfirmMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(AppStrings.actionCancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Batalkan'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      final success = await ref
          .read(cancelBookingControllerProvider.notifier)
          .cancelBooking(bookingId);

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pesanan berhasil dibatalkan.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingAsync = ref.watch(bookingDetailProvider(bookingId));

    ref.listen<AsyncValue<void>>(cancelBookingControllerProvider, (
      previous,
      next,
    ) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(failureMessage(next.error))));
      }
    });

    final isCancelling = ref.watch(cancelBookingControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(title: const Text('Detail Pesanan')),
      body: switch (bookingAsync) {
        AsyncData(:final value) => _buildContent(
          context,
          ref,
          value,
          isCancelling,
        ),
        AsyncError(:final error) => AppErrorView(
          message: failureMessage(error),
          onRetry: () => ref.invalidate(bookingDetailProvider(bookingId)),
        ),
        _ => const Center(child: AppLoading()),
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    Booking booking,
    bool isCancelling,
  ) {
    final theme = Theme.of(context);
    final vehicle = booking.vehicle;
    final vehicleName = vehicle?.fullName ?? 'Kendaraan';
    final vehicleType = vehicle?.type ?? VehicleType.mobil;

    return SingleChildScrollView(
      child: ResponsiveCenter(
        maxWidth: 640,
        padding: EdgeInsets.symmetric(
          horizontal: context.screenHorizontalPadding,
          vertical: AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Status Pesanan',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.navy900,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                BookingStatusChip(status: booking.status, isLarge: true),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Blok Kendaraan
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: Row(
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
                        Text(
                          vehicleName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.navy900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${formatRupiah(booking.pricePerDay)} / hari',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Blok Rincian Sewa
            Text(
              'Rincian Sewa',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.navy900,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    context,
                    label: 'Tanggal Sewa',
                    value: formatDateRange(booking.startDate, booking.endDate),
                  ),
                  const Divider(height: AppSpacing.lg),
                  _buildDetailRow(
                    context,
                    label: 'Durasi',
                    value: '${booking.totalDays} hari',
                  ),
                  const Divider(height: AppSpacing.lg),
                  _buildDetailRow(
                    context,
                    label: 'Lokasi Pengambilan',
                    value: booking.pickupLocation,
                  ),
                  if (booking.notes != null &&
                      booking.notes!.trim().isNotEmpty) ...[
                    const Divider(height: AppSpacing.lg),
                    _buildDetailRow(
                      context,
                      label: 'Catatan',
                      value: booking.notes!,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Blok Rincian Biaya
            Text(
              'Rincian Pembayaran',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.navy900,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    context,
                    label: 'Harga Sewa',
                    value:
                        '${formatRupiah(booking.pricePerDay)} × ${booking.totalDays} hari',
                  ),
                  const Divider(height: AppSpacing.lg),
                  _buildDetailRow(
                    context,
                    label: 'Total Biaya',
                    value: formatRupiah(booking.totalPrice),
                    isBold: true,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.navy50,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          size: 18,
                          color: AppColors.navy600,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            AppStrings.paymentNotice,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.navy900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Info Waktu Pembuatan
            Center(
              child: Text(
                'Dibuat pada: ${formatDate(booking.createdAt)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textDisabled,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Tombol Batalkan (hanya jika status 'menunggu')
            if (booking.status.isWaiting)
              AppButton.secondary(
                text: 'Batalkan Pesanan',
                isLoading: isCancelling,
                onPressed: () => _confirmCancel(context, ref),
              ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required String label,
    required String value,
    bool isBold = false,
  }) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Text(
          value,
          textAlign: TextAlign.right,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            color: AppColors.navy900,
          ),
        ),
      ],
    );
  }
}
