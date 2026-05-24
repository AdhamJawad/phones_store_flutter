import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../../../presentation/routing/app_routes.dart';
import '../providers/seller_marketplace_providers.dart';
import '../widgets/listing_card.dart';
import '../widgets/seller_stat_card.dart';

class SellerDashboardPage extends ConsumerWidget {
  const SellerDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sellerDashboardControllerProvider);
    final controller = ref.read(sellerDashboardControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text('seller.dashboard_title'.tr()),
        actions: [
          IconButton(
            onPressed: () => context.push(AppRoutes.sellerListingCreate),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Text(
                  'seller.dashboard_subtitle'.tr(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            if (state.isLoading && !state.hasData)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state.hasError && !state.hasData)
              SliverFillRemaining(
                hasScrollBody: false,
                child: AppErrorState(
                  title: 'seller.dashboard_error_title'.tr(),
                  message: state.errorMessage!,
                  actionLabel: 'common.retry'.tr(),
                  onRetry: controller.load,
                ),
              )
            else if (!state.hasData)
              SliverFillRemaining(
                hasScrollBody: false,
                child: AppEmptyState(
                  title: 'seller.dashboard_empty_title'.tr(),
                  message: 'seller.dashboard_empty_message'.tr(),
                  icon: Icons.storefront_outlined,
                ),
              )
            else ...[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                sliver: SliverGrid(
                  delegate: SliverChildListDelegate.fixed([
                    SellerStatCard(
                      title: 'seller.total_listings'.tr(),
                      value: '${state.dashboard!.stats.totalListings}',
                      icon: Icons.inventory_2_outlined,
                      highlight: true,
                    ),
                    SellerStatCard(
                      title: 'seller.active_listings'.tr(),
                      value: '${state.dashboard!.stats.activeListings}',
                      icon: Icons.check_circle_outline_rounded,
                    ),
                    SellerStatCard(
                      title: 'seller.total_orders'.tr(),
                      value: '${state.dashboard!.stats.totalOrders}',
                      icon: Icons.receipt_long_outlined,
                    ),
                    SellerStatCard(
                      title: 'seller.total_sales'.tr(),
                      value: '${state.dashboard!.stats.totalSales}',
                      icon: Icons.shopping_bag_outlined,
                    ),
                  ]),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1.12,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 22,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'seller.wallet_reference_title'.tr(),
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w900),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${state.dashboard!.stats.walletBalance.toStringAsFixed(0)} ${'products.currency'.tr()}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        fontWeight: FontWeight.w900,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          FilledButton.tonal(
                            onPressed: () => context.push(AppRoutes.wallet),
                            child: Text('seller.open_wallet'.tr()),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: AppSectionHeader(
                  title: 'seller.recent_listings_title'.tr(),
                  subtitle: 'seller.recent_listings_subtitle'.tr(),
                  actionLabel: 'seller.view_all_listings'.tr(),
                  onAction: () => context.push(AppRoutes.sellerListings),
                ),
              ),
              if (state.dashboard!.recentListings.isEmpty)
                SliverToBoxAdapter(
                  child: AppEmptyState(
                    title: 'seller.listings_empty_title'.tr(),
                    message: 'seller.listings_empty_message'.tr(),
                    actionLabel: 'seller.create_listing'.tr(),
                    onAction: () => context.push(AppRoutes.sellerListingCreate),
                    compact: true,
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  sliver: SliverList.separated(
                    itemCount: state.dashboard!.recentListings.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final listing = state.dashboard!.recentListings[index];
                      return ListingCard(
                        product: listing,
                        onEdit: () => context.push(
                          AppRoutes.sellerListingEdit(listing.id),
                          extra: listing,
                        ),
                        onTap: () =>
                            context.push(AppRoutes.productDetails(listing.id)),
                      );
                    },
                  ),
                ),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.sellerListingCreate),
        label: Text('seller.create_listing'.tr()),
        icon: const Icon(Icons.add_rounded),
      ),
    );
  }
}
