import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_paginated_footer_loader.dart';
import '../providers/wallet_providers.dart';
import '../widgets/transaction_card.dart';
import '../widgets/wallet_empty_state.dart';

class WalletTransactionsPage extends ConsumerWidget {
  const WalletTransactionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(walletTransactionsControllerProvider);
    final controller = ref.read(walletTransactionsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text('wallet.transactions_title'.tr()),
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
                    title: 'wallet.transactions_error_title'.tr(),
                    message: state.errorMessage!,
                    actionLabel: 'common.retry'.tr(),
                    onRetry: controller.load,
                  ),
                )
              else if (!state.hasItems)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: WalletEmptyState(
                    title: 'wallet.empty_transactions_title'.tr(),
                    message: 'wallet.empty_transactions_message'.tr(),
                  ),
                )
              else ...[
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  sliver: SliverList.separated(
                    itemCount: state.items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return TransactionCard(transaction: state.items[index]);
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
}
