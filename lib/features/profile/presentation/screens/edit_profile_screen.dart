import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rodakuu/core/config/app_strings.dart';
import 'package:rodakuu/core/error/error_mapper.dart';
import 'package:rodakuu/core/theme/app_spacing.dart';
import 'package:rodakuu/core/utils/responsive.dart';
import 'package:rodakuu/core/utils/validators.dart';
import 'package:rodakuu/core/widgets/app_button.dart';
import 'package:rodakuu/core/widgets/app_error_view.dart';
import 'package:rodakuu/core/widgets/app_loading.dart';
import 'package:rodakuu/core/widgets/app_text_field.dart';
import 'package:rodakuu/core/widgets/responsive_center.dart';
import 'package:rodakuu/features/profile/domain/entities/profile.dart';
import 'package:rodakuu/features/profile/presentation/providers/edit_profile_controller.dart';
import 'package:rodakuu/features/profile/presentation/providers/profile_providers.dart';

/// Layar formulir perubahan nama dan nomor telepon profil pengguna.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isInitialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _initFields(Profile profile) {
    if (_isInitialized) return;
    _nameController.text = profile.fullName;
    _phoneController.text = profile.phone ?? '';
    _emailController.text = profile.email;
    _isInitialized = true;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await ref
        .read(editProfileControllerProvider.notifier)
        .updateProfile(
          fullName: _nameController.text.trim(),
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.profileUpdatedMessage)),
      );
      if (context.canPop()) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(editProfileControllerProvider, (
      previous,
      next,
    ) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(failureMessage(next.error))));
      }
    });

    final profileAsync = ref.watch(profileProvider);
    final isUpdating = ref.watch(editProfileControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Ubah Profil')),
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
          if (profile != null) {
            _initFields(profile);
          }

          return SingleChildScrollView(
            child: ResponsiveCenter(
              maxWidth: 440,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.screenHorizontalPadding,
                  vertical: AppSpacing.lg,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppTextField(
                        label: 'Nama lengkap',
                        hint: 'Masukkan nama lengkap',
                        controller: _nameController,
                        validator: Validators.fullName,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppTextField(
                        label: 'Nomor telepon',
                        hint: 'Contoh: 08123456789 atau +628123456789',
                        controller: _phoneController,
                        validator: Validators.phone,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.done,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppTextField(
                        label: 'Email',
                        controller: _emailController,
                        enabled: false,
                        readOnly: true,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      AppButton.primary(
                        text: AppStrings.actionSave,
                        isLoading: isUpdating,
                        onPressed: isUpdating ? null : _submit,
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
