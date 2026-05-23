import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../products/domain/entities/product_variant.dart';
import 'product_details_info_card.dart';

class ProductVariantSelector extends StatelessWidget {
  const ProductVariantSelector({
    required this.variants,
    required this.selectedVariantId,
    required this.onSelect,
    super.key,
  });

  final List<ProductVariant> variants;
  final int? selectedVariantId;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ProductDetailsInfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'product_details.variants_title'.tr(),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'product_details.variants_subtitle'.tr(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: variants.map((variant) {
              final selected = selectedVariantId == variant.id;
              final inStock = variant.stockQuantity > 0;
              return InkWell(
                onTap: () => onSelect(variant.id),
                borderRadius: BorderRadius.circular(20),
                child: Ink(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? theme.colorScheme.primary.withValues(alpha: 0.12)
                        : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outlineVariant,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if ((variant.colorCode ?? '').trim().isNotEmpty) ...[
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Color(_parseHexColor(variant.colorCode!)),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            variant.colorName,
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        inStock
                            ? '${variant.stockQuantity} ${'product_details.stock_count'.tr()}'
                            : 'product_details.out_of_stock'.tr(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: inStock
                              ? theme.colorScheme.primary
                              : theme.colorScheme.error,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(growable: false),
          ),
        ],
      ),
    );
  }

  int _parseHexColor(String value) {
    final normalized = value.replaceAll('#', '').trim();
    if (normalized.length == 6) {
      return int.parse('0xFF$normalized');
    }

    return 0xFFCBD5E1;
  }
}
