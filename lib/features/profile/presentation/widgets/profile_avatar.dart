import 'package:material_ui/material_ui.dart';
import 'package:rodakuu/core/theme/app_colors.dart';

/// Avatar profil berupa lingkaran dengan inisial nama pengguna.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, required this.name, this.size = 72});

  final String name;
  final double size;

  String get _initials {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '-';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }
    return '${parts[0].substring(0, 1)}${parts[1].substring(0, 1)}'
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: 'Foto profil inisial $_initials',
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: AppColors.navy900,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          _initials,
          style: theme.textTheme.titleLarge?.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
