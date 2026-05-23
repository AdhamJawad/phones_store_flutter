import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../presentation/theme/app_motion.dart';
import 'app_skeleton.dart';

class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    required this.imageUrl,
    super.key,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.height,
    this.width,
    this.iconSize = 28,
    this.heroTag,
  });

  final String? imageUrl;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final double? height;
  final double? width;
  final double iconSize;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    final effectiveUrl = imageUrl?.trim() ?? '';
    Widget image = effectiveUrl.isEmpty
        ? _ImageFallback(iconSize: iconSize)
        : CachedNetworkImage(
            imageUrl: effectiveUrl,
            fit: fit,
            height: height,
            width: width,
            fadeInDuration: AppMotion.medium,
            fadeOutDuration: AppMotion.fast,
            placeholderFadeInDuration: AppMotion.fast,
            placeholder: (_, _) => const AppSkeleton(
              child: ColoredBox(
                color: Color(0xFFF1F5F9),
                child: SizedBox.expand(),
              ),
            ),
            errorWidget: (_, _, _) => _ImageFallback(iconSize: iconSize),
          );

    if (heroTag != null && effectiveUrl.isNotEmpty) {
      image = Hero(
        tag: heroTag!,
        child: image,
      );
    }

    if (borderRadius == null) {
      return image;
    }

    return ClipRRect(
      borderRadius: borderRadius!,
      child: image,
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback({required this.iconSize});

  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.photo_camera_back_outlined,
          size: iconSize,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
