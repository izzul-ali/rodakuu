import 'package:material_ui/material_ui.dart';
import 'package:rodakuu/core/config/app_constants.dart';
import 'package:rodakuu/core/config/app_strings.dart';
import 'package:rodakuu/core/theme/app_colors.dart';
import 'package:rodakuu/core/theme/app_spacing.dart';
import 'package:rodakuu/core/utils/formatters.dart';
import 'package:rodakuu/core/widgets/app_button.dart';
import 'package:rodakuu/features/vehicles/domain/entities/vehicle.dart';
import 'package:rodakuu/features/vehicles/domain/entities/vehicle_filter.dart';

/// Lembar filter bawah (bottom sheet) untuk mengatur transmisi, harga, ketersediaan, dan pengurutan.
class VehicleFilterSheet extends StatefulWidget {
  const VehicleFilterSheet({
    super.key,
    required this.initialFilter,
    required this.onApply,
  });

  final VehicleFilter initialFilter;
  final ValueChanged<VehicleFilter> onApply;

  @override
  State<VehicleFilterSheet> createState() => _VehicleFilterSheetState();
}

class _VehicleFilterSheetState extends State<VehicleFilterSheet> {
  late Transmission? _transmission;
  late double _minPrice;
  late double _maxPrice;
  late bool _onlyAvailable;
  late VehicleSort _sort;

  @override
  void initState() {
    super.initState();
    _transmission = widget.initialFilter.transmission;
    _minPrice = widget.initialFilter.minPrice.toDouble();
    _maxPrice = widget.initialFilter.maxPrice.toDouble();
    _onlyAvailable = widget.initialFilter.onlyAvailable;
    _sort = widget.initialFilter.sort;
  }

  void _reset() {
    setState(() {
      _transmission = null;
      _minPrice = AppConstants.priceFilterMin.toDouble();
      _maxPrice = AppConstants.priceFilterMax.toDouble();
      _onlyAvailable = false;
      _sort = VehicleSort.newest;
    });
  }

  void _apply() {
    final updated = widget.initialFilter.copyWith(
      transmission: () => _transmission,
      minPrice: _minPrice.round(),
      maxPrice: _maxPrice.round(),
      onlyAvailable: _onlyAvailable,
      sort: _sort,
    );
    widget.onApply(updated);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.md,
          AppSpacing.xl,
          AppSpacing.xl,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.navy100,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter & Urutkan',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.navy900,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextButton(
                    onPressed: _reset,
                    child: const Text(AppStrings.actionReset),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Transmisi',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.navy900,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                children: [
                  ChoiceChip(
                    label: const Text('Semua'),
                    selected: _transmission == null,
                    onSelected: (_) => setState(() => _transmission = null),
                    showCheckmark: false,
                  ),
                  ChoiceChip(
                    label: const Text('Manual'),
                    selected: _transmission == Transmission.manual,
                    onSelected: (_) =>
                        setState(() => _transmission = Transmission.manual),
                    showCheckmark: false,
                  ),
                  ChoiceChip(
                    label: const Text('Matic'),
                    selected: _transmission == Transmission.matic,
                    onSelected: (_) =>
                        setState(() => _transmission = Transmission.matic),
                    showCheckmark: false,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Rentang Harga per Hari',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.navy900,
                    ),
                  ),
                  Text(
                    '${formatRupiah(_minPrice.round())} – ${formatRupiah(_maxPrice.round())}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.navy900,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              RangeSlider(
                values: RangeValues(_minPrice, _maxPrice),
                min: AppConstants.priceFilterMin.toDouble(),
                max: AppConstants.priceFilterMax.toDouble(),
                divisions:
                    (AppConstants.priceFilterMax -
                        AppConstants.priceFilterMin) ~/
                    AppConstants.priceFilterStep,
                activeColor: AppColors.navy900,
                inactiveColor: AppColors.navy100,
                onChanged: (values) {
                  setState(() {
                    _minPrice = values.start;
                    _maxPrice = values.end;
                  });
                },
              ),
              const SizedBox(height: AppSpacing.md),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Hanya yang tersedia',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.navy900,
                  ),
                ),
                activeThumbColor: AppColors.navy900,
                value: _onlyAvailable,
                onChanged: (val) => setState(() => _onlyAvailable = val),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Urutkan Berdasarkan',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.navy900,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                children: VehicleSort.values.map((sort) {
                  return ChoiceChip(
                    label: Text(sort.label),
                    selected: _sort == sort,
                    onSelected: (_) => setState(() => _sort = sort),
                    showCheckmark: false,
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton.primary(
                text: AppStrings.actionApply,
                onPressed: _apply,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
