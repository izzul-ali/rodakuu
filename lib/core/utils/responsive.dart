import 'package:material_ui/material_ui.dart';
import 'package:rodakuu/core/theme/app_spacing.dart';

/// Extension pembantu untuk kebutuhan tata letak responsif pada [BuildContext].
extension ResponsiveContext on BuildContext {
  /// Lebar layar saat ini dalam satuan dp.
  double get screenWidth => MediaQuery.sizeOf(this).width;

  /// Tinggi layar saat ini dalam satuan dp.
  double get screenHeight => MediaQuery.sizeOf(this).height;

  /// Apakah layar saat ini tergolong sempit (lebar < 360 dp).
  bool get isCompactWidth => screenWidth < 360.0;

  /// Padding horizontal standar: 16 dp untuk layar sempit, 20 dp untuk normal/lebar.
  double get screenHorizontalPadding => isCompactWidth
      ? AppSpacing.screenHorizontalCompact
      : AppSpacing.screenHorizontal;
}
