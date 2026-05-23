import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../products/domain/entities/product.dart';
import 'product_details_info_card.dart';

class ProductSellerCard extends StatelessWidget {
  const ProductSellerCard({
    required this.product,
    super.key,
  });

  final Product product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final seller = product.seller;

    return ProductDetailsInfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.isInventory
                ? 'product_details.seller_store_title'.tr()
                : 'product_details.seller_title'.tr(),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  product.isInventory
                      ? Icons.storefront_rounded
                      : Icons.person_rounded,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      seller?.name ??
                          (product.isInventory
                              ? 'product_details.store_account'.tr()
                              : 'product_details.unknown_seller'.tr()),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      seller?.location ??
                          product.location ??
                          'product_details.location_unknown'.tr(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            product.isInventory
                ? 'product_details.inventory_flow_hint'.tr()
                : 'product_details.marketplace_flow_hint'.tr(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
