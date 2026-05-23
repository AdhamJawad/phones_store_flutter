import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../products/domain/entities/product.dart';
import '../../../products/domain/entities/product_variant.dart';

class OrderSummaryCard extends StatelessWidget {
  const OrderSummaryCard({
    required this.product,
    required this.totalPrice,
    super.key,
    this.variant,
  });

  final Product product;
  final ProductVariant? variant;
  final double totalPrice;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'orders.summary_title'.tr(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              product.displayTitle,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            if (variant != null) ...[
              const SizedBox(height: 6),
              Text(
                '${'orders.variant_label'.tr()}: ${variant!.colorName}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  'orders.total_label'.tr(),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const Spacer(),
                Text(
                  '${totalPrice.toStringAsFixed(0)} ${'products.currency'.tr()}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
