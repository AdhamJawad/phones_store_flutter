import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/order.dart';
import '../../domain/entities/order_status.dart';

class OrderTimeline extends StatelessWidget {
  const OrderTimeline({
    required this.order,
    super.key,
  });

  final Order order;

  @override
  Widget build(BuildContext context) {
    final steps = _buildSteps(order);
    return Column(
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final isLast = index == steps.length - 1;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: step.active
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outlineVariant,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 44,
                    color: step.active
                        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.35)
                        : Theme.of(context).colorScheme.outlineVariant,
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 0, bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.title.tr(),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      step.subtitle.tr(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  List<_TimelineStep> _buildSteps(Order order) {
    if (order.isInventory) {
      final approvedLike = order.status == OrderStatus.approved ||
          order.status == OrderStatus.shipping ||
          order.status == OrderStatus.completed;
      return <_TimelineStep>[
        _TimelineStep(
          title: 'orders.timeline_inventory_pending_title',
          subtitle: 'orders.timeline_inventory_pending_subtitle',
          active: true,
        ),
        _TimelineStep(
          title: 'orders.timeline_inventory_approved_title',
          subtitle: 'orders.timeline_inventory_approved_subtitle',
          active: approvedLike,
        ),
        _TimelineStep(
          title: 'orders.timeline_inventory_shipping_title',
          subtitle: 'orders.timeline_inventory_shipping_subtitle',
          active: order.status == OrderStatus.shipping ||
              order.status == OrderStatus.completed,
        ),
        _TimelineStep(
          title: 'orders.timeline_inventory_completed_title',
          subtitle: 'orders.timeline_inventory_completed_subtitle',
          active: order.status == OrderStatus.completed,
        ),
      ];
    }

    return <_TimelineStep>[
      _TimelineStep(
        title: 'orders.timeline_marketplace_pending_title',
        subtitle: 'orders.timeline_marketplace_pending_subtitle',
        active: true,
      ),
      _TimelineStep(
        title: 'orders.timeline_marketplace_admin_title',
        subtitle: order.approvals.admin == true
            ? 'orders.timeline_marketplace_admin_approved_subtitle'
            : 'orders.timeline_marketplace_admin_pending_subtitle',
        active: order.approvals.admin == true,
      ),
      _TimelineStep(
        title: 'orders.timeline_marketplace_seller_title',
        subtitle: order.approvals.seller == true
            ? 'orders.timeline_marketplace_seller_approved_subtitle'
            : 'orders.timeline_marketplace_seller_pending_subtitle',
        active: order.approvals.seller == true,
      ),
      _TimelineStep(
        title: 'orders.timeline_marketplace_completed_title',
        subtitle: 'orders.timeline_marketplace_completed_subtitle',
        active: order.status == OrderStatus.approved ||
            order.status == OrderStatus.completed,
      ),
    ];
  }
}

class _TimelineStep {
  const _TimelineStep({
    required this.title,
    required this.subtitle,
    required this.active,
  });

  final String title;
  final String subtitle;
  final bool active;
}
