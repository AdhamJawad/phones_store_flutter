import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/app_network_image.dart';
import '../../../products/domain/entities/product_image.dart';

class ListingImageUploadGrid extends StatelessWidget {
  const ListingImageUploadGrid({
    required this.existingImages,
    required this.newImagePaths,
    required this.onAddImages,
    required this.onRemoveExisting,
    required this.onRemoveNew,
    super.key,
    this.isPicking = false,
  });

  final List<ProductImage> existingImages;
  final List<String> newImagePaths;
  final VoidCallback onAddImages;
  final ValueChanged<int> onRemoveExisting;
  final ValueChanged<String> onRemoveNew;
  final bool isPicking;

  @override
  Widget build(BuildContext context) {
    final totalCount = existingImages.length + newImagePaths.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'seller.images_title'.tr(),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          '${'seller.images_subtitle'.tr()} ($totalCount/5)',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1,
          children: [
            ...existingImages.map(
              (image) => _RemovableImageTile(
                child: AppNetworkImage(
                  imageUrl: image.url,
                  borderRadius: BorderRadius.circular(18),
                ),
                onRemove: () => onRemoveExisting(image.id),
              ),
            ),
            ...newImagePaths.map(
              (path) => _RemovableImageTile(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.file(
                    File(path),
                    fit: BoxFit.cover,
                  ),
                ),
                onRemove: () => onRemoveNew(path),
              ),
            ),
            if (totalCount < 5)
              InkWell(
                onTap: isPicking ? null : onAddImages,
                borderRadius: BorderRadius.circular(18),
                child: Ink(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  child: Center(
                    child: isPicking
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.add_photo_alternate_outlined),
                              const SizedBox(height: 6),
                              Text(
                                'seller.add_images'.tr(),
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                            ],
                          ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _RemovableImageTile extends StatelessWidget {
  const _RemovableImageTile({
    required this.child,
    required this.onRemove,
  });

  final Widget child;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: child),
        Positioned(
          top: 6,
          left: 6,
          child: Material(
            color: Colors.black54,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onRemove,
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
