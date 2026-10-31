import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rodakuu/core/config/app_constants.dart';
import 'package:rodakuu/core/config/app_strings.dart';
import 'package:rodakuu/core/error/error_mapper.dart';
import 'package:rodakuu/core/theme/app_colors.dart';
import 'package:rodakuu/core/theme/app_spacing.dart';
import 'package:rodakuu/core/utils/debouncer.dart';
import 'package:rodakuu/core/utils/responsive.dart';
import 'package:rodakuu/core/widgets/app_empty_view.dart';
import 'package:rodakuu/core/widgets/app_error_view.dart';
import 'package:rodakuu/core/widgets/responsive_center.dart';
import 'package:rodakuu/features/profile/presentation/providers/profile_providers.dart';
import 'package:rodakuu/features/vehicles/presentation/providers/vehicle_filter_controller.dart';
import 'package:rodakuu/features/vehicles/presentation/providers/vehicle_providers.dart';
import 'package:rodakuu/features/vehicles/presentation/widgets/vehicle_card.dart';
import 'package:rodakuu/features/vehicles/presentation/widgets/vehicle_card_skeleton.dart';
import 'package:rodakuu/features/vehicles/presentation/widgets/vehicle_filter_sheet.dart';
import 'package:rodakuu/features/vehicles/presentation/widgets/vehicle_type_selector.dart';

/// Layar utama katalog kendaraan (Beranda) dengan pencarian, filter, dan pengurutan.
class VehicleListScreen extends ConsumerStatefulWidget {
  const VehicleListScreen({super.key});

  @override
  ConsumerState<VehicleListScreen> createState() => _VehicleListScreenState();
}

class _VehicleListScreenState extends ConsumerState<VehicleListScreen> {
  final _searchController = TextEditingController();
  final _debouncer = Debouncer(delay: AppConstants.searchDebounce);

  @override
  void initState() {
    super.initState();
    _searchController.text = ref.read(vehicleFilterProvider).query;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debouncer.run(() {
      ref.read(vehicleFilterProvider.notifier).setQuery(value);
    });
  }

  void _openFilterSheet() {
    final currentFilter = ref.read(vehicleFilterProvider);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      builder: (context) {
        return VehicleFilterSheet(
          initialFilter: currentFilter,
          onApply: (newFilter) {
            ref.read(vehicleFilterProvider.notifier).setFilter(newFilter);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filter = ref.watch(vehicleFilterProvider);
    final vehiclesAsync = ref.watch(vehicleListProvider);

    final profileAsync = ref.watch(profileProvider);
    final firstName = profileAsync.value?.firstName;
    final greeting = (firstName != null && firstName.isNotEmpty)
        ? 'Halo, $firstName'
        : 'Halo';

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: 640,
          padding: EdgeInsets.symmetric(
            horizontal: context.screenHorizontalPadding,
          ),
          child: RefreshIndicator(
            color: AppColors.navy900,
            onRefresh: () async {
              ref.invalidate(vehicleListProvider);
              try {
                await ref.read(vehicleListProvider.future);
              } on Object {
                // Error ditangani oleh provider state.
              }
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: AppSpacing.lg,
                      bottom: AppSpacing.sm,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          greeting,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Mau sewa apa hari ini?',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: AppColors.navy900,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _searchController,
                                onChanged: _onSearchChanged,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.navy900,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Cari merek atau nama',
                                  prefixIcon: const Icon(
                                    Icons.search_rounded,
                                    color: AppColors.navy900,
                                  ),
                                  suffixIcon: _searchController.text.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.clear_rounded),
                                          tooltip: 'Hapus pencarian',
                                          onPressed: () {
                                            _searchController.clear();
                                            ref
                                                .read(
                                                  vehicleFilterProvider
                                                      .notifier,
                                                )
                                                .setQuery('');
                                            setState(() {});
                                          },
                                        )
                                      : null,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Container(
                              height: 52,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusMd,
                                ),
                                border: Border.all(
                                  color: AppColors.borderStrong,
                                ),
                              ),
                              child: IconButton(
                                tooltip: 'Filter kendaraan',
                                icon: Badge.count(
                                  count: filter.activeFilterCount,
                                  isLabelVisible: filter.activeFilterCount > 0,
                                  backgroundColor: AppColors.navy900,
                                  textColor: AppColors.white,
                                  child: const Icon(
                                    Icons.tune_rounded,
                                    color: AppColors.navy900,
                                  ),
                                ),
                                onPressed: _openFilterSheet,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        VehicleTypeSelector(
                          selectedType: filter.type,
                          onTypeChanged: (type) {
                            ref
                                .read(vehicleFilterProvider.notifier)
                                .setType(type);
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                    ),
                  ),
                ),
                switch (vehiclesAsync) {
                  AsyncData(:final value) when value.isEmpty =>
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: AppEmptyView(
                        title: AppStrings.emptyVehiclesTitle,
                        message: AppStrings.emptyVehiclesSubtitle,
                        actionTitle: AppStrings.actionReset,
                        onAction: () {
                          _searchController.clear();
                          ref.read(vehicleFilterProvider.notifier).reset();
                        },
                      ),
                    ),
                  AsyncData(:final value) => SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final vehicle = value[index];
                      return VehicleCard(vehicle: vehicle);
                    }, childCount: value.length),
                  ),
                  AsyncError(:final error) => SliverFillRemaining(
                    hasScrollBody: false,
                    child: AppErrorView(
                      message: failureMessage(error),
                      onRetry: () => ref.invalidate(vehicleListProvider),
                    ),
                  ),
                  _ => SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => const VehicleCardSkeleton(),
                      childCount: 4,
                    ),
                  ),
                },
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.xxl),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
