import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_paginated_footer_loader.dart';
import '../../../../presentation/routing/app_routes.dart';
import '../../domain/entities/app_notification_item.dart';
import '../providers/notifications_providers.dart';
import '../widgets/notification_card.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationsControllerProvider);
    final controller = ref.read(notificationsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text('notifications.title'.tr()),
        actions: [
          TextButton(
            onPressed: state.isMarkingAllAsRead || state.unreadCount == 0
                ? null
                : () => _markAll(context, ref),
            child: state.isMarkingAllAsRead
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text('notifications.mark_all'.tr()),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.refresh,
        child: NotificationListener<ScrollEndNotification>(
          onNotification: (notification) {
            final metrics = notification.metrics;
            if (metrics.pixels >= metrics.maxScrollExtent - 220) {
              controller.loadMore();
            }
            return false;
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Text(
                    'notifications.subtitle'.tr(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              if (state.isLoading && !state.hasItems)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (state.hasError && !state.hasItems)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: AppErrorState(
                    title: 'notifications.error_title'.tr(),
                    message: state.errorMessage!,
                    actionLabel: 'common.retry'.tr(),
                    onRetry: controller.load,
                  ),
                )
              else if (!state.hasItems)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: AppEmptyState(
                    title: 'notifications.empty_title'.tr(),
                    message: 'notifications.empty_state_message'.tr(),
                    icon: Icons.notifications_none_rounded,
                  ),
                )
              else ...[
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  sliver: SliverList.separated(
                    itemCount: state.items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = state.items[index];
                      return NotificationCard(
                        notification: item,
                        isBusy: state.busyIds.contains(item.id),
                        onTap: () => _openNotification(context, ref, item),
                        onMarkAsRead: () => _markOne(context, ref, item),
                      );
                    },
                  ),
                ),
                if (state.isLoadingMore)
                  const SliverToBoxAdapter(child: AppPaginatedFooterLoader()),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _markAll(BuildContext context, WidgetRef ref) async {
    final result = await ref
        .read(notificationsControllerProvider.notifier)
        .markAllAsRead();
    if (!context.mounted) {
      return;
    }

    switch (result) {
      case Success():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('notifications.mark_all_success'.tr())),
        );
      case Error(:final failure):
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.message)));
    }
  }

  Future<void> _markOne(
    BuildContext context,
    WidgetRef ref,
    AppNotificationItem item,
  ) async {
    final result = await ref
        .read(notificationsControllerProvider.notifier)
        .markAsRead(item.id);
    if (!context.mounted) {
      return;
    }

    if (result case Error(:final failure)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.message)));
    }
  }

  Future<void> _openNotification(
    BuildContext context,
    WidgetRef ref,
    AppNotificationItem item,
  ) async {
    if (!item.isRead) {
      await _markOne(context, ref, item);
      if (!context.mounted) {
        return;
      }
    }

    final target = switch (item.type) {
      'order' => AppRoutes.orders,
      'action' => AppRoutes.ordersSales,
      'wallet' => AppRoutes.wallet,
      _ => null,
    };

    if (target != null) {
      context.go(target);
    }
  }
}
