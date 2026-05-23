import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/app_empty_state.dart';
import '../../../products/domain/entities/product.dart';
import '../../../products/presentation/widgets/product_card.dart';
import '../../../products/presentation/widgets/product_card_skeleton.dart';

class ProductRelatedSection extends StatelessWidget {
  const ProductRelatedSection({
    required this.items,
    required this.isLoading,
    required this.onTapProduct,
    super.key,
  });

  final List<Product> items;
  final bool isLoading;
  final ValueChanged<Product> onTapProduct;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: 290,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          scrollDirection: Axis.horizontal,
          itemBuilder: (_, index) => const SizedBox(
            width: 210,
            child: ProductCardSkeleton(),
          ),
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemCount: 3,
        ),
      );
    }

    if (items.isEmpty) {
      return AppEmptyState(
        title: 'product_details.related_empty_title'.tr(),
        message: 'product_details.related_empty_message'.tr(),
        compact: true,
      );
    }

    return SizedBox(
      height: 330,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final product = items[index];
          return SizedBox(
            width: 220,
            child: ProductCard(
              product: product,
              onTap: () => onTapProduct(product),
            ),
          );
        },
      ),
    );
  }
}
