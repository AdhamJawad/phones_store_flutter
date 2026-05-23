import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/app_network_image.dart';
import '../../domain/entities/order.dart';
import 'order_status_badge.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({
    required this.order,
    required this.onTap,
    super.key,
    this.trailing,
  });

  final Order order;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final product = order.product;
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
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: AppNetworkImage(
                      imageUrl: product?.primaryImageUrl,
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product?.displayTitle ?? '#${order.id}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          order.isInventory
                              ? 'orders.type_inventory'.tr()
                              : 'orders.type_marketplace'.tr(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                        ),
                        if (order.variant != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            order.variant!.colorName,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  OrderStatusBadge(status: order.status),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Text(
                    '${order.totalPrice.toStringAsFixed(0)} ${'products.currency'.tr()}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const Spacer(),
                  Text(
                    _paymentLabel(order.paymentMethod).tr(),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              if (trailing != null) ...[
                const SizedBox(height: 14),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _paymentLabel(dynamic method) {
    switch (method.name) {
      case 'wallet':
        return 'orders.payment_wallet';
      case 'stripe':
        return 'orders.payment_stripe';
      default:
        return 'orders.payment_cod';
    }
  }
}
