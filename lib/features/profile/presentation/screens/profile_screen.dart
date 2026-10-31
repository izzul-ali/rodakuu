import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rodakuu/core/config/app_strings.dart';
import 'package:rodakuu/core/router/app_routes.dart';
import 'package:rodakuu/core/theme/app_colors.dart';
import 'package:rodakuu/core/theme/app_spacing.dart';
import 'package:rodakuu/core/utils/responsive.dart';
import 'package:rodakuu/core/widgets/app_empty_view.dart';
import 'package:rodakuu/core/widgets/app_error_view.dart';
import 'package:rodakuu/core/widgets/app_loading.dart';
import 'package:rodakuu/core/widgets/responsive_center.dart';
import 'package:rodakuu/features/auth/presentation/providers/auth_providers.dart';
import 'package:rodakuu/features/profile/presentation/providers/profile_providers.dart';
import 'package:rodakuu/features/profile/presentation/widgets/profile_avatar.dart';
import 'package:rodakuu/features/profile/presentation/widgets/profile_menu_tile.dart';

/// Layar profil pengguna RodaKuu yang menampilkan identitas dan menu tindakan akun.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(AppStrings.logoutConfirmTitle),
          content: const Text(AppStrings.logoutConfirmMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(AppStrings.actionCancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(AppStrings.actionLogout),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await ref.read(authRepositoryProvider).signOut();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: profileAsync.when(
        loading: () => const Center(child: AppLoading()),
        error: (error, _) => Center(
          child: AppErrorView(
            title: AppStrings.errorLoadTitle,
            message: AppStrings.errorLoadSubtitle,
            onRetry: () => ref.refresh(profileProvider),
          ),
        ),
        data: (profile) {
          if (profile == null) {
            return const Center(
              child: AppEmptyView(
                title: 'Data profil belum tersedia',
                message: 'Silakan masuk kembali ke akun Anda.',
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.refresh(profileProvider),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ResponsiveCenter(
                maxWidth: 640,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.screenHorizontalPadding,
                    vertical: AppSpacing.xl,
                  ),
                  child: Column(
                    children: [
                      ProfileAvatar(name: profile.fullName),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        profile.fullName,
                        style: theme.textTheme.titleLarge,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        profile.email,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        profile.phone != null && profile.phone!.isNotEmpty
                            ? profile.phone!
                            : 'Belum diisi',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusLg,
                          ),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          children: [
                            ProfileMenuTile(
                              title: 'Ubah profil',
                              icon: Icons.person_outline_rounded,
                              onTap: () => context.push(AppRoutes.editProfile),
                            ),
                            const Divider(
                              height: 1,
                              thickness: 1,
                              color: AppColors.border,
                            ),
                            ProfileMenuTile(
                              title: AppStrings.actionLogout,
                              icon: Icons.logout_rounded,
                              isDestructive: true,
                              onTap: () => _confirmSignOut(context, ref),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
