import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rodakuu/core/config/app_strings.dart';
import 'package:rodakuu/core/error/error_mapper.dart';
import 'package:rodakuu/core/router/app_routes.dart';
import 'package:rodakuu/core/theme/app_colors.dart';
import 'package:rodakuu/core/theme/app_spacing.dart';
import 'package:rodakuu/core/utils/validators.dart';
import 'package:rodakuu/core/widgets/app_button.dart';
import 'package:rodakuu/core/widgets/app_text_field.dart';
import 'package:rodakuu/features/auth/domain/auth_repository.dart';
import 'package:rodakuu/features/auth/presentation/providers/register_controller.dart';
import 'package:rodakuu/features/auth/presentation/widgets/auth_scaffold.dart';

/// Layar Pendaftaran (Register) bagi pengguna baru.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final result = await ref
        .read(registerControllerProvider.notifier)
        .signUp(
          fullName: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
        );

    if (!mounted || result == null) return;

    if (result == SignUpResult.needsEmailVerification) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Periksa email Anda untuk verifikasi.')),
      );
      context.go(AppRoutes.login);
    } else {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(registerControllerProvider, (previous, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(failureMessage(next.error))));
      }
    });

    final isLoading = ref.watch(registerControllerProvider).isLoading;

    return AuthScaffold(
      title: 'Buat akun baru',
      subtitle: 'Mulai sewa kendaraan pilihan Anda dengan mudah.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              label: 'Nama lengkap',
              hint: 'Nama sesuai identitas',
              controller: _nameController,
              validator: Validators.fullName,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: 'Email',
              hint: 'nama@email.com',
              controller: _emailController,
              validator: Validators.email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: 'Kata sandi',
              hint: 'Minimal 8 karakter',
              controller: _passwordController,
              validator: Validators.password,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newPassword],
              suffixIcon: IconButton(
                tooltip: _obscurePassword
                    ? 'Tampilkan kata sandi'
                    : 'Sembunyikan kata sandi',
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.textSecondary,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: 'Konfirmasi kata sandi',
              hint: 'Ulangi kata sandi Anda',
              controller: _confirmPasswordController,
              validator: (value) =>
                  Validators.confirmPassword(value, _passwordController.text),
              obscureText: _obscureConfirmPassword,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.newPassword],
              onFieldSubmitted: (_) => _submit(),
              suffixIcon: IconButton(
                tooltip: _obscureConfirmPassword
                    ? 'Tampilkan konfirmasi kata sandi'
                    : 'Sembunyikan konfirmasi kata sandi',
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.textSecondary,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton.primary(
              text: AppStrings.actionRegister,
              isLoading: isLoading,
              onPressed: _submit,
            ),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text(
                  'Sudah punya akun?',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                TextButton(
                  onPressed: () => context.go(AppRoutes.login),
                  child: const Text('Masuk'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
