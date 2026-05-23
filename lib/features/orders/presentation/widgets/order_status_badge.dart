import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/order_status.dart';

class OrderStatusBadge extends StatelessWidget {
  const OrderStatusBadge({
    required this.status,
    super.key,
  });

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final (background, textColor, label) = switch (status) {
      OrderStatus.pending => (
          const Color(0xFFFFF7ED),
          const Color(0xFFC2410C),
          'orders.status_pending'.tr(),
        ),
      OrderStatus.approved => (
          const Color(0xFFECFDF5),
          const Color(0xFF15803D),
          'orders.status_approved'.tr(),
        ),
      OrderStatus.shipping => (
          const Color(0xFFE0F2FE),
          const Color(0xFF0369A1),
          'orders.status_shipping'.tr(),
        ),
      OrderStatus.completed => (
          const Color(0xFFDCFCE7),
          const Color(0xFF166534),
          'orders.status_completed'.tr(),
        ),
      OrderStatus.rejected => (
          const Color(0xFFFEF2F2),
          const Color(0xFFB91C1C),
          'orders.status_rejected'.tr(),
        ),
      OrderStatus.cancelled => (
          colorScheme.surfaceContainerHighest,
          colorScheme.onSurface,
          'orders.status_cancelled'.tr(),
        ),
      OrderStatus.unknown => (
          colorScheme.surfaceContainerHighest,
          colorScheme.onSurface,
          'orders.status_unknown'.tr(),
        ),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w800,
              ),
        ),
      ),
    );
  }
}
