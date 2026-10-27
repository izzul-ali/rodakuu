import 'package:material_ui/material_ui.dart';
import 'package:rodakuu/core/theme/app_colors.dart';
import 'package:rodakuu/core/theme/app_spacing.dart';
import 'package:rodakuu/core/theme/app_theme.dart';
import 'package:rodakuu/core/widgets/app_logo.dart';
import 'package:rodakuu/core/widgets/responsive_center.dart';

/// Tampilan layar ketika konfigurasi Supabase (env.json) belum diisi.
class ConfigErrorView extends StatelessWidget {
  const ConfigErrorView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: 440,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppLogo(fontSize: 32),
                const SizedBox(height: AppSpacing.xxl),
                const Icon(
                  Icons.settings_suggest_outlined,
                  size: 64,
                  color: AppColors.warning,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Konfigurasi belum lengkap',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: AppColors.navy900,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Salin berkas env.example.json menjadi env.json, lengkapi SUPABASE_URL dan SUPABASE_PUBLISHABLE_KEY, lalu jalankan kembali aplikasi.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Aplikasi root mandiri yang ditampilkan jika variabel env belum dikonfigurasi.
class ConfigErrorApp extends StatelessWidget {
  const ConfigErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RodaKuu',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      themeMode: ThemeMode.light,
      home: const ConfigErrorView(),
    );
  }
}
