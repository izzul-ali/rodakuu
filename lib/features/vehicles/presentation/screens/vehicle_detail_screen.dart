import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rodakuu/core/config/app_strings.dart';
import 'package:rodakuu/core/error/error_mapper.dart';
import 'package:rodakuu/core/router/app_routes.dart';
import 'package:rodakuu/core/theme/app_colors.dart';
import 'package:rodakuu/core/theme/app_spacing.dart';
import 'package:rodakuu/core/utils/formatters.dart';
import 'package:rodakuu/core/utils/responsive.dart';
import 'package:rodakuu/core/widgets/app_button.dart';
import 'package:rodakuu/core/widgets/app_error_view.dart';
import 'package:rodakuu/core/widgets/app_loading.dart';
import 'package:rodakuu/core/widgets/responsive_center.dart';
import 'package:rodakuu/features/vehicles/domain/entities/vehicle.dart';
import 'package:rodakuu/features/vehicles/presentation/providers/vehicle_providers.dart';
import 'package:rodakuu/features/vehicles/presentation/widgets/spec_item.dart';
import 'package:rodakuu/features/vehicles/presentation/widgets/vehicle_image.dart';

/// Layar rincian lengkap kendaraan dengan galeri foto, spesifikasi, dan tombol pemesanan.
class VehicleDetailScreen extends ConsumerWidget {
  const VehicleDetailScreen({super.key, required this.vehicleId});

  final String vehicleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicleAsync = ref.watch(vehicleDetailProvider(vehicleId));
    final vehicle = vehicleAsync.value;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: switch (vehicleAsync) {
        AsyncData(:final value) => _VehicleDetailContent(vehicle: value),
        AsyncError(:final error) when vehicle == null => SafeArea(
          child: AppErrorView(
            message: failureMessage(error),
            onRetry: () => ref.invalidate(vehicleDetailProvider(vehicleId)),
          ),
        ),
        _ when vehicle != null => _VehicleDetailContent(vehicle: vehicle),
        _ => const Center(child: AppLoading()),
      },
      bottomNavigationBar: vehicle != null
          ? _VehicleDetailBottomBar(vehicle: vehicle)
          : null,
    );
  }
}

class _VehicleDetailContent extends StatelessWidget {
  const _VehicleDetailContent({required this.vehicle});

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: ResponsiveCenter(
        maxWidth: 640,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                VehicleImage(
                  type: vehicle.type,
                  imageUrl: vehicle.imageUrl,
                  aspectRatio: 16 / 10,
                  semanticLabel: vehicle.fullName,
                ),
                Positioned(
                  top: MediaQuery.paddingOf(context).top + AppSpacing.sm,
                  left: AppSpacing.md,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: IconButton(
                      tooltip: 'Kembali',
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.navy900,
                      ),
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go(AppRoutes.home);
                        }
                      },
                    ),
                  ),
                ),
                if (!vehicle.isAvailable)
                  Positioned(
                    top: MediaQuery.paddingOf(context).top + AppSpacing.sm,
                    right: AppSpacing.md,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.errorBg,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusSm,
                        ),
                        border: Border.all(color: AppColors.error),
                      ),
                      child: Text(
                        'Tidak tersedia',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.screenHorizontalPadding,
                vertical: AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          vehicle.fullName,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: AppColors.navy900,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.navy50,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusSm,
                          ),
                        ),
                        child: Text(
                          '${vehicle.year}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.navy900,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${vehicle.brand} • ${vehicle.type.label}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Spesifikasi',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.navy900,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final itemWidth =
                          (constraints.maxWidth - AppSpacing.md) / 2;
                      return Wrap(
                        spacing: AppSpacing.md,
                        runSpacing: AppSpacing.md,
                        children: [
                          SizedBox(
                            width: itemWidth,
                            child: SpecItem(
                              icon: vehicle.type == VehicleType.mobil
                                  ? Icons.directions_car_rounded
                                  : Icons.two_wheeler_rounded,
                              label: 'Jenis',
                              value: vehicle.type.label,
                            ),
                          ),
                          SizedBox(
                            width: itemWidth,
                            child: SpecItem(
                              icon: Icons.settings_rounded,
                              label: 'Transmisi',
                              value: vehicle.transmission.label,
                            ),
                          ),
                          SizedBox(
                            width: itemWidth,
                            child: SpecItem(
                              icon: Icons.local_gas_station_rounded,
                              label: 'Bahan Bakar',
                              value: vehicle.fuel.label,
                            ),
                          ),
                          SizedBox(
                            width: itemWidth,
                            child: SpecItem(
                              icon: Icons.airline_seat_recline_normal_rounded,
                              label: 'Kapasitas',
                              value: '${vehicle.seats} Kursi',
                            ),
                          ),
                          SizedBox(
                            width: itemWidth,
                            child: SpecItem(
                              icon: Icons.calendar_today_rounded,
                              label: 'Tahun',
                              value: '${vehicle.year}',
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Deskripsi',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.navy900,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    vehicle.description.isNotEmpty
                        ? vehicle.description
                        : 'Tidak ada deskripsi tambahan.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.navy900,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VehicleDetailBottomBar extends StatelessWidget {
  const _VehicleDetailBottomBar({required this.vehicle});

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: ResponsiveCenter(
          maxWidth: 640,
          heightFactor: 1.0,
          padding: EdgeInsets.symmetric(
            horizontal: context.screenHorizontalPadding,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Harga Sewa',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          formatRupiah(vehicle.pricePerDay),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: AppColors.navy900,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          ' / hari',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              SizedBox(
                width: 170,
                child: vehicle.isAvailable
                    ? AppButton.primary(
                        text: AppStrings.actionOrderNow,
                        onPressed: () {
                          context.push(AppRoutes.bookingForm(vehicle.id));
                        },
                      )
                    : const AppButton.primary(
                        text: 'Tidak tersedia',
                        onPressed: null,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
