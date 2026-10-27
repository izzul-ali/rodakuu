import 'package:material_ui/material_ui.dart';
import 'package:rodakuu/core/theme/app_colors.dart';

/// Indikator pemuatan data berputar dengan warna identitas navy.
class AppLoading extends StatelessWidget {
  const AppLoading({super.key, this.size = 28.0});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: const CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.navy900),
        ),
      ),
    );
  }
}
