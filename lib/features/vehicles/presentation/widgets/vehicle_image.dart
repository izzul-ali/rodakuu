import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rodakuu/core/theme/app_colors.dart';
import 'package:rodakuu/features/vehicles/domain/entities/vehicle.dart';

/// Widget gambar kendaraan dengan rasio 16:10, fallback ikon, dan caching jaringan.
class VehicleImage extends StatelessWidget {
  const VehicleImage({
    super.key,
    required this.type,
    this.imageUrl,
    this.aspectRatio = 16 / 10,
    this.borderRadius,
    this.semanticLabel,
  });

  final VehicleType type;
  final String? imageUrl;
  final double aspectRatio;
  final BorderRadius? borderRadius;
  final String? semanticLabel;

  Widget _buildPlaceholder() {
    final iconData = switch (type) {
      VehicleType.mobil => Icons.directions_car_rounded,
      VehicleType.motor => Icons.two_wheeler_rounded,
    };

    return Container(
      color: AppColors.navy50,
      alignment: Alignment.center,
      child: Icon(iconData, size: 48, color: AppColors.navy600),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget imageContent;

    if (imageUrl != null && imageUrl!.trim().isNotEmpty) {
      imageContent = CachedNetworkImage(
        imageUrl: imageUrl!.trim(),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholder: (context, url) => _buildPlaceholder(),
        errorWidget: (context, url, error) => _buildPlaceholder(),
      );
    } else {
      imageContent = _buildPlaceholder();
    }

    final wrappedImage = Semantics(
      label: semanticLabel ?? 'Foto kendaraan',
      child: AspectRatio(aspectRatio: aspectRatio, child: imageContent),
    );

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: wrappedImage);
    }

    return wrappedImage;
  }
}
