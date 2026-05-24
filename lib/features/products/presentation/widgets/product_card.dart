import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/widgets/app_surface_card.dart';
import '../../../../presentation/theme/app_motion.dart';
import '../../../../presentation/theme/app_radii.dart';
import '../../../../presentation/theme/app_spacing.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../domain/entities/product.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    required this.product,
    required this.onTap,
    super.key,
    this.compact = false,
    this.heroTag,
  });

  final Product product;
  final VoidCallback onTap;
  final bool compact;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textScaler = MediaQuery.textScalerOf(context);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.98, end: 1),
      duration: AppMotion.medium,
      curve: AppMotion.emphasized,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: AppSurfaceCard(
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: compact ? 1.20 : 1.20,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: AppNetworkImage(
                      imageUrl: product.primaryImageUrl,
                      heroTag: heroTag,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppRadii.xl),
                      ),
                    ),
                  ),
                  Positioned(
                    top: AppSpacing.sm,
                    left: AppSpacing.sm,
                    child: _Badge(
                      label: _conditionLabel(product.condition),
                      color: theme.colorScheme.surface.withValues(alpha: 0.92),
                      textColor: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isDense = constraints.maxHeight < 112;
                  final horizontalPadding = isDense ? 12.0 : 14.0;
                  final topPadding = isDense ? 12.0 : 14.0;
                  final bottomPadding = isDense ? 12.0 : 16.0;
                  final titleLines = isDense ? 1 : 2;

                  return Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      topPadding,
                      horizontalPadding,
                      bottomPadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.displayTitle,
                          maxLines: titleLines,
                          overflow: TextOverflow.ellipsis,
                          textScaler: textScaler,
                          style: TextStyle(fontSize: 12),
                        ),
                        const Spacer(),
                        Text(
                          '\$ ${product.price.toStringAsFixed(0)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textScaler: textScaler,
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        _MetaRow(
                          icon: Icons.place_outlined,
                          label:
                              product.location ??
                              product.seller?.location ??
                              'products.location_unknown'.tr(),
                          dense: isDense,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _conditionLabel(String value) {
    switch (value) {
      case 'new':
        return 'products.condition_new'.tr();
      case 'used':
        return 'products.condition_used'.tr();
      default:
        return value;
    }
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.icon, required this.label, this.dense = false});

  final IconData icon;
  final String label;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconSize = dense ? 14.0 : 16.0;
    final gap = dense ? 3.0 : 4.0;

    return Row(
      children: [
        Icon(icon, size: iconSize, color: theme.colorScheme.onSurfaceVariant),
        SizedBox(width: gap),
        Expanded(
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.color,
    this.textColor = Colors.white,
  });

  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: textColor,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
