import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../domain/entities/order_payment_method.dart';
import '../providers/orders_providers.dart';
import '../widgets/order_status_badge.dart';
import '../widgets/order_timeline.dart';

class OrderDetailsPage extends ConsumerWidget {
  const OrderDetailsPage({required this.orderId, super.key});

  final int orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(orderDetailsControllerProvider(orderId));
    final controller = ref.read(
      orderDetailsControllerProvider(orderId).notifier,
    );

    if (state.isLoading && !state.hasData) {
      return Scaffold(
        appBar: AppBar(
          leading: const AppBackButton(),
          title: Text('orders.detail_title'.tr()),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (state.hasError && !state.hasData) {
      return Scaffold(
        appBar: AppBar(
          leading: const AppBackButton(),
          title: Text('orders.detail_title'.tr()),
        ),
        body: AppErrorState(
          title: 'orders.detail_error_title'.tr(),
          message: state.errorMessage!,
          actionLabel: 'common.retry'.tr(),
          onRetry: controller.load,
        ),
      );
    }

    final order = state.order;
    if (order == null) {
      return Scaffold(
        appBar: AppBar(
          leading: const AppBackButton(),
          title: Text('orders.detail_title'.tr()),
        ),
        body: AppEmptyState(
          title: 'orders.detail_empty_title'.tr(),
          message: 'orders.detail_empty_message'.tr(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text('orders.detail_title'.tr()),
      ),
      body: RefreshIndicator(
        onRefresh: controller.refresh,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          children: [
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '#${order.id}',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ),
                      OrderStatusBadge(status: order.status),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    order.isInventory
                        ? 'orders.type_inventory'.tr()
                        : 'orders.type_marketplace'.tr(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${order.totalPrice.toStringAsFixed(0)} ${'products.currency'.tr()}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (order.product != null)
              _SectionCard(
                child: Row(
                  children: [
                    SizedBox(
                      width: 86,
                      height: 86,
                      child: AppNetworkImage(
                        imageUrl: order.product!.primaryImageUrl,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.product!.displayTitle,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 6),
                          if (order.variant != null)
                            Text(
                              '${'orders.variant_label'.tr()}: ${order.variant!.colorName}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          const SizedBox(height: 6),
                          Text(
                            order.product!.location ??
                                'product_details.location_unknown'.tr(),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'orders.timeline_title'.tr(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 16),
                  OrderTimeline(order: order),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'orders.payment_and_delivery_title'.tr(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _DetailRow(
                    label: 'orders.payment_method_title'.tr(),
                    value: _paymentLabel(order.paymentMethod).tr(),
                  ),
                  _DetailRow(
                    label: 'orders.shipping_address_title'.tr(),
                    value: order.shippingAddress,
                  ),
                  if (order.createdAt != null)
                    _DetailRow(
                      label: 'orders.created_at_label'.tr(),
                      value: DateFormat(
                        'yyyy-MM-dd HH:mm',
                      ).format(order.createdAt!),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'orders.approvals_title'.tr(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _DetailRow(
                    label: 'orders.admin_approval_label'.tr(),
                    value: _approvalLabel(order.approvals.admin).tr(),
                  ),
                  _DetailRow(
                    label: 'orders.seller_approval_label'.tr(),
                    value: order.isMarketplace
                        ? _approvalLabel(order.approvals.seller).tr()
                        : 'orders.approval_not_applicable'.tr(),
                  ),
                ],
              ),
            ),
          ],
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

  String _approvalLabel(bool? value) {
    return switch (value) {
      true => 'orders.approval_yes',
      false => 'orders.approval_no',
      null => 'orders.approval_pending',
    };
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
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
      child: Padding(padding: const EdgeInsets.all(18), child: child),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
