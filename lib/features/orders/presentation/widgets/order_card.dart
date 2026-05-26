import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/app_network_image.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_payment_method.dart';
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
    final theme = Theme.of(context);

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
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                order.isInventory
                                    ? 'orders.type_inventory'.tr()
                                    : 'orders.type_marketplace'.tr(),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Align(
                                alignment: Alignment.topRight,
                                child: OrderStatusBadge(status: order.status),
                              ),
                            ),
                          ],
                        ),
                        if (order.variant != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            order.variant!.colorName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                runSpacing: 8,
                children: [
                  Text(
                    '${order.totalPrice.toStringAsFixed(0)} ${'products.currency'.tr()}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    _paymentLabel(order.paymentMethod).tr(),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              if (trailing != null) ...[const SizedBox(height: 14), trailing!],
            ],
          ),
        ),
      ),
    );
  }

  String _paymentLabel(OrderPaymentMethod method) {
    return switch (method) {
      OrderPaymentMethod.wallet => 'orders.payment_wallet',
      OrderPaymentMethod.stripe => 'orders.payment_stripe',
      OrderPaymentMethod.cod => 'orders.payment_cod',
    };
  }
}
