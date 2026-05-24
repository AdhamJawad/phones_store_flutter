import 'package:flutter/material.dart';

import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/app_surface_card.dart';
import '../../../../presentation/theme/app_motion.dart';
import '../../../../presentation/theme/app_radii.dart';
import '../../../../presentation/theme/app_spacing.dart';

class ProductImageGallery extends StatefulWidget {
  const ProductImageGallery({
    required this.imageUrls,
    required this.selectedIndex,
    required this.onImageChanged,
    required this.onPreviewRequested,
    super.key,
    this.heroTag,
  });

  final List<String> imageUrls;
  final int selectedIndex;
  final ValueChanged<int> onImageChanged;
  final ValueChanged<int> onPreviewRequested;
  final String? heroTag;

  @override
  State<ProductImageGallery> createState() => _ProductImageGalleryState();
}

class _ProductImageGalleryState extends State<ProductImageGallery> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.selectedIndex);
  }

  @override
  void didUpdateWidget(covariant ProductImageGallery oldWidget) {
    super.didUpdateWidget(oldWidget);
    final currentPage = _pageController.hasClients
        ? _pageController.page?.round()
        : null;
    if (oldWidget.selectedIndex != widget.selectedIndex &&
        _pageController.hasClients &&
        currentPage != widget.selectedIndex) {
      _pageController.animateToPage(
        widget.selectedIndex,
        duration: AppMotion.medium,
        curve: AppMotion.emphasized,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return AspectRatio(
        aspectRatio: 1.05,
        child: AppSurfaceCard(
          padding: EdgeInsets.zero,
          borderRadius: BorderRadius.circular(AppRadii.hero),
          child: const Center(
            child: Icon(Icons.photo_camera_back_outlined, size: 42),
          ),
        ),
      );
    }

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1.05,
          child: AppSurfaceCard(
            padding: EdgeInsets.zero,
            borderRadius: BorderRadius.circular(AppRadii.hero),
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: widget.imageUrls.length,
                  onPageChanged: widget.onImageChanged,
                  itemBuilder: (context, index) {
                    return InkWell(
                      borderRadius: BorderRadius.circular(AppRadii.hero),
                      onTap: () => widget.onPreviewRequested(index),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        child: AppNetworkImage(
                          imageUrl: widget.imageUrls[index],
                          heroTag: index == 0 ? widget.heroTag : null,
                          borderRadius: BorderRadius.circular(AppRadii.lg),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        if (widget.imageUrls.length > 1) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List<Widget>.generate(widget.imageUrls.length, (index) {
              final selected = index == widget.selectedIndex;
              return AnimatedContainer(
                duration: AppMotion.fast,
                curve: AppMotion.emphasized,
                width: selected ? 20 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: selected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(
                          context,
                        ).colorScheme.outlineVariant.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(999),
                ),
              );
            }),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 78,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final selected = index == widget.selectedIndex;
                return InkWell(
                  onTap: () {
                    if (_pageController.hasClients) {
                      _pageController.animateToPage(
                        index,
                        duration: AppMotion.medium,
                        curve: AppMotion.emphasized,
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                  child: AnimatedContainer(
                    duration: AppMotion.fast,
                    width: 78,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                      border: Border.all(
                        color: selected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outlineVariant,
                        width: selected ? 1.6 : 1,
                      ),
                      color: Colors.white,
                    ),
                    child: AppNetworkImage(
                      imageUrl: widget.imageUrls[index],
                      borderRadius: BorderRadius.circular(AppRadii.xs),
                    ),
                  ),
                );
              },
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemCount: widget.imageUrls.length,
            ),
          ),
        ],
      ],
    );
  }
}
