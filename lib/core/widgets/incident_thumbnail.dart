import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../constants/app_sizes.dart';
import '../theme/app_theme.dart';

/// Rounded incident photo with an icon placeholder when there is no image or it
/// fails to load.
class IncidentThumbnail extends StatelessWidget {
  const IncidentThumbnail({
    super.key,
    required this.fallbackIcon,
    this.imageUrl,
    this.imageBytes,
    this.size = AppSizes.thumbnailSize,
  });

  final IconData fallbackIcon;
  final String? imageUrl;
  final Uint8List? imageBytes;
  final double size;

  @override
  Widget build(BuildContext context) {
    final Widget placeholder = Container(
      color: AppColors.myReportsTile,
      child: Icon(fallbackIcon, size: size * 0.39, color: AppColors.primary),
    );

    final Widget image;
    if (imageBytes != null) {
      image = Image.memory(imageBytes!, fit: BoxFit.cover, gaplessPlayback: true);
    } else if (imageUrl != null && imageUrl!.trim().isNotEmpty) {
      image = Image.network(
        imageUrl!.trim(),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => placeholder,
      );
    } else {
      image = placeholder;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.thumbnailRadius),
      child: SizedBox(height: size, width: size, child: image),
    );
  }
}
