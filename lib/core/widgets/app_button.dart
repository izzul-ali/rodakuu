import 'package:material_ui/material_ui.dart';
import 'package:rodakuu/core/theme/app_colors.dart';

enum _AppButtonVariant { primary, secondary, text }

/// Tombol terstandarisasi untuk aplikasi RodaKuu dengan dukungan loading dan varian.
class AppButton extends StatelessWidget {
  const AppButton.primary({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isFullWidth = true,
  }) : _variant = _AppButtonVariant.primary;

  const AppButton.secondary({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isFullWidth = true,
  }) : _variant = _AppButtonVariant.secondary;

  const AppButton.text({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isFullWidth = false,
  }) : _variant = _AppButtonVariant.text;

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? icon;
  final bool isFullWidth;
  final _AppButtonVariant _variant;

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = isLoading ? null : onPressed;

    Widget content;
    if (isLoading) {
      final indicatorColor = switch (_variant) {
        _AppButtonVariant.primary => AppColors.white,
        _AppButtonVariant.secondary => AppColors.navy900,
        _AppButtonVariant.text => AppColors.navy600,
      };
      content = SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.2,
          valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
        ),
      );
    } else if (icon != null) {
      content = Row(
        mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon!,
          const SizedBox(width: 8),
          Flexible(
            child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ],
      );
    } else {
      content = Text(text, maxLines: 1, overflow: TextOverflow.ellipsis);
    }

    final buttonWidget = switch (_variant) {
      _AppButtonVariant.primary => FilledButton(
        onPressed: effectiveOnPressed,
        child: content,
      ),
      _AppButtonVariant.secondary => OutlinedButton(
        onPressed: effectiveOnPressed,
        child: content,
      ),
      _AppButtonVariant.text => TextButton(
        onPressed: effectiveOnPressed,
        child: content,
      ),
    };

    if (isFullWidth && _variant != _AppButtonVariant.text) {
      return SizedBox(width: double.infinity, child: buttonWidget);
    }

    return buttonWidget;
  }
}
