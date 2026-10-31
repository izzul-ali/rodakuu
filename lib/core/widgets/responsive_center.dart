import 'package:material_ui/material_ui.dart';

/// Membatasi lebar maksimum konten dan memusatkannya di bagian tengah atas layar.
class ResponsiveCenter extends StatelessWidget {
  const ResponsiveCenter({
    super.key,
    required this.child,
    this.maxWidth = 640.0,
    this.padding = EdgeInsets.zero,
    this.heightFactor,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;
  final double? heightFactor;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      heightFactor: heightFactor,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
