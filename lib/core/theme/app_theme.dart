import 'package:material_ui/material_ui.dart';
import 'package:rodakuu/core/theme/app_colors.dart';
import 'package:rodakuu/core/theme/app_spacing.dart';
import 'package:rodakuu/core/theme/app_typography.dart';

/// Konfigurasi tema terang aplikasi RodaKuu.
abstract final class AppTheme {
  static const ColorScheme colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.navy900,
    onPrimary: AppColors.white,
    primaryContainer: AppColors.navy50,
    onPrimaryContainer: AppColors.navy900,
    secondary: AppColors.navy600,
    onSecondary: AppColors.white,
    secondaryContainer: AppColors.navy100,
    onSecondaryContainer: AppColors.navy900,
    error: AppColors.error,
    onError: AppColors.white,
    surface: AppColors.white,
    onSurface: AppColors.navy900,
    onSurfaceVariant: AppColors.textSecondary,
    outline: AppColors.borderStrong,
    outlineVariant: AppColors.border,
    surfaceContainerHighest: AppColors.navy50,
  );

  static ThemeData light({bool useGoogleFonts = true}) {
    final typography = AppTypography.textTheme(useGoogleFonts: useGoogleFonts);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.white,
      textTheme: typography,
      dividerColor: AppColors.border,
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: AppBarThemeData(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.navy900,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.navy900),
        titleTextStyle: typography.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        titleTextStyle: typography.titleLarge,
        contentTextStyle: typography.bodyMedium,
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.all(AppSpacing.lg),
        hintStyle: typography.bodyLarge?.copyWith(
          color: AppColors.textDisabled,
        ),
        labelStyle: typography.bodyLarge?.copyWith(
          color: AppColors.textSecondary,
        ),
        helperStyle: typography.bodySmall,
        errorStyle: typography.bodySmall?.copyWith(color: AppColors.error),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.borderStrong, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.borderStrong, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.navy900, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll<Size>(Size.fromHeight(52)),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return AppColors.navy900.withValues(alpha: 0.38);
            }
            if (states.contains(WidgetState.pressed)) {
              return AppColors.navy800;
            }
            return AppColors.navy900;
          }),
          foregroundColor: const WidgetStatePropertyAll<Color>(AppColors.white),
          textStyle: WidgetStatePropertyAll<TextStyle?>(typography.labelLarge),
          shape: WidgetStatePropertyAll<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
          elevation: const WidgetStatePropertyAll<double>(0),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll<Size>(Size.fromHeight(52)),
          foregroundColor: const WidgetStatePropertyAll<Color>(
            AppColors.navy900,
          ),
          textStyle: WidgetStatePropertyAll<TextStyle?>(typography.labelLarge),
          side: const WidgetStatePropertyAll<BorderSide>(
            BorderSide(color: AppColors.navy900, width: 1),
          ),
          shape: WidgetStatePropertyAll<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
          elevation: const WidgetStatePropertyAll<double>(0),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: const WidgetStatePropertyAll<Color>(
            AppColors.navy600,
          ),
          textStyle: WidgetStatePropertyAll<TextStyle?>(typography.labelLarge),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.white,
        elevation: 0,
        height: 72,
        indicatorColor: AppColors.navy50,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return typography.labelSmall?.copyWith(
              color: AppColors.navy900,
              fontWeight: FontWeight.w600,
            );
          }
          return typography.labelSmall?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w400,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.navy900);
          }
          return const IconThemeData(color: AppColors.textSecondary);
        }),
      ),
      chipTheme: ChipThemeData(
        shape: const StadiumBorder(),
        side: const BorderSide(color: AppColors.border, width: 1),
        backgroundColor: AppColors.white,
        selectedColor: AppColors.navy900,
        labelStyle: typography.labelSmall,
        secondaryLabelStyle: typography.labelSmall?.copyWith(
          color: AppColors.white,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.navy900,
        contentTextStyle: typography.bodyMedium?.copyWith(
          color: AppColors.white,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
      ),
    );
  }
}
