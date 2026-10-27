import 'package:material_ui/material_ui.dart';
import 'package:rodakuu/core/theme/app_colors.dart';

/// Wordmark logo tipografi resmi RodaKuu tanpa aset berkas gambar.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.fontSize = 28.0});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'Roda',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              color: AppColors.navy900,
              letterSpacing: -0.5,
            ),
          ),
          TextSpan(
            text: 'Kuu',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              color: AppColors.navy600,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}
