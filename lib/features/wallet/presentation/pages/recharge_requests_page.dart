import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_paginated_footer_loader.dart';
import '../providers/wallet_providers.dart';
import '../widgets/recharge_request_card.dart';
import '../widgets/recharge_request_sheet.dart';
import '../widgets/wallet_empty_state.dart';

class RechargeRequestsPage extends ConsumerWidget {
  const RechargeRequestsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(rechargeRequestsControllerProvider);
    final controller = ref.read(rechargeRequestsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text('wallet.recharge_requests_title'.tr()),
        actions: [
          IconButton(
            onPressed: () => _openRechargeSheet(context),
            icon: const Icon(Icons.add_rounded),
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
              if (state.isLoading && !state.hasItems)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (state.hasError && !state.hasItems)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: AppErrorState(
                    title: 'wallet.recharge_error_title'.tr(),
                    message: state.errorMessage!,
                    actionLabel: 'common.retry'.tr(),
                    onRetry: controller.load,
                  ),
                )
              else if (!state.hasItems)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: WalletEmptyState(
                    title: 'wallet.empty_recharges_title'.tr(),
                    message: 'wallet.empty_recharges_message'.tr(),
                  ),
                )
              else ...[
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  sliver: SliverList.separated(
                    itemCount: state.items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return RechargeRequestCard(request: state.items[index]);
                    },
                  ),
                ),
                if (state.isLoadingMore)
                  const SliverToBoxAdapter(
                    child: AppPaginatedFooterLoader(),
                  ),
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openRechargeSheet(context),
        label: Text('wallet.recharge_cta'.tr()),
        icon: const Icon(Icons.add_rounded),
      ),
    );
  }

  Future<void> _openRechargeSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const RechargeRequestSheet(),
    );
  }
}
