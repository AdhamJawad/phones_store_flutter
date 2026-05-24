import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../../presentation/routing/app_routes.dart';
import '../../../../presentation/theme/app_spacing.dart';
import '../providers/wallet_providers.dart';
import '../widgets/balance_card.dart';
import '../widgets/recharge_request_card.dart';
import '../widgets/recharge_request_sheet.dart';
import '../widgets/transaction_card.dart';
import '../widgets/wallet_empty_state.dart';

class WalletPage extends ConsumerWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(walletDashboardControllerProvider);
    final controller = ref.read(walletDashboardControllerProvider.notifier);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: controller.refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  AppSpacing.page,
                  AppSpacing.page,
                  8,
                ),
                child: Text(
                  'wallet.title'.tr(),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  0,
                  AppSpacing.page,
                  14,
                ),
                child: Text(
                  'wallet.subtitle'.tr(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            if (state.isLoading && !state.hasData)
              const SliverPadding(
                padding: EdgeInsets.all(AppSpacing.page),
                sliver: SliverToBoxAdapter(
                  child: AppSkeleton(
                    child: AppSkeletonBox(
                      height: 220,
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                    ),
                  ),
                ),
              )
            else if (state.hasError && !state.hasData)
              SliverFillRemaining(
                hasScrollBody: false,
                child: AppErrorState(
                  title: 'wallet.error_title'.tr(),
                  message: state.errorMessage!,
                  actionLabel: 'common.retry'.tr(),
                  onRetry: controller.load,
                ),
              )
            else if (!state.hasData)
              SliverFillRemaining(
                hasScrollBody: false,
                child: WalletEmptyState(
                  title: 'wallet.empty_title'.tr(),
                  message: 'wallet.empty_message'.tr(),
                ),
              )
            else ...[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  0,
                  AppSpacing.page,
                  18,
                ),
                sliver: SliverToBoxAdapter(
                  child: BalanceCard(
                    summary: state.dashboard!.summary,
                    onRecharge: () => _openRechargeSheet(context),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: AppSectionHeader(
                  title: 'wallet.recent_transactions_title'.tr(),
                  actionLabel: 'wallet.view_all'.tr(),
                  onAction: () => context.push(AppRoutes.walletTransactions),
                ),
              ),
              if (state.dashboard!.recentTransactions.isEmpty)
                SliverToBoxAdapter(
                  child: WalletEmptyState(
                    title: 'wallet.empty_transactions_title'.tr(),
                    message: 'wallet.empty_transactions_message'.tr(),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page,
                    12,
                    AppSpacing.page,
                    6,
                  ),
                  sliver: SliverList.separated(
                    itemCount: state.dashboard!.recentTransactions.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return TransactionCard(
                        transaction: state.dashboard!.recentTransactions[index],
                      );
                    },
                  ),
                ),
              SliverToBoxAdapter(
                child: AppSectionHeader(
                  title: 'wallet.recent_recharges_title'.tr(),
                  actionLabel: 'wallet.view_all'.tr(),
                  onAction: () =>
                      context.push(AppRoutes.walletRechargeRequests),
                ),
              ),
              if (state.dashboard!.recentRechargeRequests.isEmpty)
                SliverToBoxAdapter(
                  child: WalletEmptyState(
                    title: 'wallet.empty_recharges_title'.tr(),
                    message: 'wallet.empty_recharges_message'.tr(),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page,
                    12,
                    AppSpacing.page,
                    24,
                  ),
                  sliver: SliverList.separated(
                    itemCount: state.dashboard!.recentRechargeRequests.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return RechargeRequestCard(
                        request: state.dashboard!.recentRechargeRequests[index],
                      );
                    },
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _openRechargeSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const RechargeRequestSheet(),
    );
  }
}
