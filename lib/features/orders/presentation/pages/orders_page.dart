import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/result.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_paginated_footer_loader.dart';
import '../../../../presentation/routing/app_routes.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/order.dart';
import '../providers/orders_providers.dart';
import '../widgets/approval_action_bar.dart';
import '../widgets/order_card.dart';

enum OrdersTab {
  buyer,
  sales,
}

class OrdersPage extends ConsumerStatefulWidget {
  const OrdersPage({
    required this.initialTab,
    super.key,
  });

  final OrdersTab initialTab;

  @override
  ConsumerState<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends ConsumerState<OrdersPage> {
  late OrdersTab _currentTab;
  int? _busySalesOrderId;

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
  }

  @override
  void didUpdateWidget(covariant OrdersPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTab != widget.initialTab) {
      _currentTab = widget.initialTab;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final authUser = authState.session?.user;
    final isAuthenticated = authState.isAuthenticated;
    final isSeller = isAuthenticated && authUser != null;

    final buyerState = ref.watch(buyerOrdersControllerProvider);
    final buyerController = ref.read(buyerOrdersControllerProvider.notifier);
    final salesState = ref.watch(salesOrdersControllerProvider);
    final salesController = ref.read(salesOrdersControllerProvider.notifier);

    final activeState = _currentTab == OrdersTab.buyer ? buyerState : salesState;
    final onRefresh = _currentTab == OrdersTab.buyer
        ? buyerController.refresh
        : salesController.refresh;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: onRefresh,
        child: NotificationListener<ScrollEndNotification>(
          onNotification: (notification) {
            final metrics = notification.metrics;
            if (metrics.pixels >= metrics.maxScrollExtent - 220) {
              if (_currentTab == OrdersTab.buyer) {
                buyerController.loadMore();
              } else {
                salesController.loadMore();
              }
            }
            return false;
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: Text(
                    'orders.title'.tr(),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  child: Text(
                    'orders.subtitle'.tr(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 56,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    children: [
                      ChoiceChip(
                        label: Text('orders.buyer_tab'.tr()),
                        selected: _currentTab == OrdersTab.buyer,
                        onSelected: (_) {
                          setState(() {
                            _currentTab = OrdersTab.buyer;
                          });
                          context.go(AppRoutes.orders);
                        },
                      ),
                      const SizedBox(width: 10),
                      ChoiceChip(
                        label: Text('orders.sales_tab'.tr()),
                        selected: _currentTab == OrdersTab.sales,
                        onSelected: isSeller
                            ? (_) {
                                setState(() {
                                  _currentTab = OrdersTab.sales;
                                });
                                context.go(AppRoutes.ordersSales);
                              }
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
              if (!isAuthenticated)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: AppEmptyState(
                    title: 'orders.auth_required_title'.tr(),
                    message: 'orders.auth_required_message'.tr(),
                  ),
                )
              else if (_currentTab == OrdersTab.sales && !isSeller)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: AppEmptyState(
                    title: 'orders.sales_unavailable_title'.tr(),
                    message: 'orders.sales_unavailable_message'.tr(),
                  ),
                )
              else if (activeState.isLoading && !activeState.hasItems)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (activeState.hasError && !activeState.hasItems)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: AppErrorState(
                    title: 'orders.error_title'.tr(),
                    message: activeState.errorMessage!,
                    actionLabel: 'common.retry'.tr(),
                    onRetry: _currentTab == OrdersTab.buyer
                        ? buyerController.load
                        : salesController.load,
                  ),
                )
              else if (!activeState.hasItems)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: AppEmptyState(
                    title: _currentTab == OrdersTab.buyer
                        ? 'orders.empty_buyer_title'.tr()
                        : 'orders.empty_sales_title'.tr(),
                    message: _currentTab == OrdersTab.buyer
                        ? 'orders.empty_buyer_message'.tr()
                        : 'orders.empty_sales_message'.tr(),
                  ),
                )
              else ...[
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  sliver: SliverList.separated(
                    itemCount: activeState.items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final order = activeState.items[index];
                      return OrderCard(
                        order: order,
                        onTap: () => context.go(AppRoutes.orderDetails(order.id)),
                        trailing: _currentTab == OrdersTab.sales
                            ? _buildSalesActions(
                                context,
                                order: order,
                                salesController: salesController,
                              )
                            : null,
                      );
                    },
                  ),
                ),
                if (activeState.isLoadingMore)
                  const SliverToBoxAdapter(
                    child: AppPaginatedFooterLoader(),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget? _buildSalesActions(
    BuildContext context, {
    required Order order,
    required SalesOrdersController salesController,
  }) {
    if (order.approvals.seller != null) {
      return null;
    }

    final isBusy = _busySalesOrderId == order.id;
    return ApprovalActionBar(
      isBusy: isBusy,
      onApprove: () => _confirmAction(
        context,
        title: 'orders.approve_dialog_title'.tr(),
        message: 'orders.approve_dialog_message'.tr(),
        onConfirm: () => _handleSalesAction(
          order.id,
          () => salesController.approve(order.id),
        ),
      ),
      onReject: () => _confirmAction(
        context,
        title: 'orders.reject_dialog_title'.tr(),
        message: 'orders.reject_dialog_message'.tr(),
        onConfirm: () => _handleSalesAction(
          order.id,
          () => salesController.reject(order.id),
        ),
      ),
    );
  }

  Future<void> _confirmAction(
    BuildContext context, {
    required String title,
    required String message,
    required Future<void> Function() onConfirm,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('common.cancel'.tr()),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('common.ok'.tr()),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await onConfirm();
    }
  }

  Future<void> _handleSalesAction(
    int orderId,
    Future<Result<Order>> Function() action,
  ) async {
    setState(() {
      _busySalesOrderId = orderId;
    });
    final result = await action();
    if (!mounted) {
      return;
    }
    setState(() {
      _busySalesOrderId = null;
    });

    switch (result) {
      case Success<Order>():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('orders.sales_action_success'.tr())),
        );
      case Error<Order>(:final failure):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
    }
  }
}
