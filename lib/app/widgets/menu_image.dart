import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Gambar menu dari server dengan placeholder & fallback saat gagal dimuat.
class MenuImage extends StatelessWidget {
  const MenuImage({super.key, required this.url, this.width, this.height, this.borderRadius = 0, this.fit = BoxFit.cover});

  final String url;
  final double? width;
  final double? height;
  final double borderRadius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      width: width,
      height: height,
      color: AppColors.coral.withValues(alpha: 0.15),
      alignment: Alignment.center,
      child: const Icon(Icons.restaurant_rounded, color: AppColors.coral, size: 36),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: url.isEmpty
          ? fallback
          : CachedNetworkImage(
              imageUrl: url,
              width: width,
              height: height,
              fit: fit,
              fadeInDuration: const Duration(milliseconds: 200),
              placeholder: (_, _) => Container(
                width: width,
                height: height,
                color: AppColors.border.withValues(alpha: 0.5),
              ),
              errorWidget: (_, _, _) => fallback,
            ),
    );
  }
}
