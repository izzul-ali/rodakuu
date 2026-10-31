import 'package:material_ui/material_ui.dart';
import 'package:rodakuu/core/theme/app_colors.dart';
import 'package:rodakuu/core/theme/app_spacing.dart';
import 'package:rodakuu/features/vehicles/domain/entities/vehicle.dart';

/// Pilihan filter jenis kendaraan (Semua, Mobil, Motor) di atas daftar.
class VehicleTypeSelector extends StatelessWidget {
  const VehicleTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  final VehicleType? selectedType;
  final ValueChanged<VehicleType?> onTypeChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ChoiceChip(
            label: const Text('Semua'),
            selected: selectedType == null,
            onSelected: (_) => onTypeChanged(null),
            showCheckmark: false,
            selectedColor: AppColors.navy900,
          ),
          const SizedBox(width: AppSpacing.sm),
          ChoiceChip(
            label: const Text('Mobil'),
            selected: selectedType == VehicleType.mobil,
            onSelected: (_) => onTypeChanged(VehicleType.mobil),
            showCheckmark: false,
            selectedColor: AppColors.navy900,
          ),
          const SizedBox(width: AppSpacing.sm),
          ChoiceChip(
            label: const Text('Motor'),
            selected: selectedType == VehicleType.motor,
            onSelected: (_) => onTypeChanged(VehicleType.motor),
            showCheckmark: false,
            selectedColor: AppColors.navy900,
          ),
        ],
      ),
    );
  }
}
