import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/app_network_image.dart';
import '../../../products/domain/entities/product.dart';
import 'listing_status_badge.dart';

class ListingCard extends StatelessWidget {
  const ListingCard({
    required this.product,
    super.key,
    this.onEdit,
    this.onDelete,
    this.onTap,
    this.isDeleting = false,
  });

  final Product product;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;
  final bool isDeleting;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              SizedBox(
                width: 92,
                height: 92,
                child: AppNetworkImage(
                  imageUrl: product.primaryImageUrl ??
                      (product.images.isNotEmpty ? product.images.first.url : null),
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListingStatusBadge(status: product.status),
                    const SizedBox(height: 10),
                    Text(
                      product.displayTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${product.price.toStringAsFixed(0)} ${'products.currency'.tr()}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${_conditionLabel(product.condition).tr()} • ${product.color ?? 'products.location_unknown'.tr()}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 10),
                    if (onEdit != null || onDelete != null)
                      Row(
                        children: [
                          if (onEdit != null)
                            TextButton.icon(
                              onPressed: onEdit,
                              icon: const Icon(Icons.edit_outlined),
                              label: Text('seller.edit_listing'.tr()),
                            ),
                          if (onEdit != null && onDelete != null)
                            const SizedBox(width: 6),
                          if (onDelete != null)
                            TextButton.icon(
                              onPressed: isDeleting ? null : onDelete,
                              icon: isDeleting
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child:
                                          CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.delete_outline_rounded),
                              label: Text('seller.delete_listing'.tr()),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _conditionLabel(String value) {
    return switch (value) {
      'new' => 'products.condition_new',
      _ => 'products.condition_used',
    };
  }
}
