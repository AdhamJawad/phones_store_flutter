import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/result.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_paginated_footer_loader.dart';
import '../../../../presentation/routing/app_routes.dart';
import '../../../products/domain/entities/product.dart';
import '../providers/seller_marketplace_providers.dart';
import '../widgets/listing_card.dart';

class SellerListingsPage extends ConsumerWidget {
  const SellerListingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sellerListingsControllerProvider);
    final controller = ref.read(sellerListingsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text('seller.my_listings_title'.tr()),
        actions: [
          IconButton(
            onPressed: () => context.push(AppRoutes.sellerListingCreate),
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
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Text(
                    'seller.my_listings_subtitle'.tr(),
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
                    title: 'seller.listings_error_title'.tr(),
                    message: state.errorMessage!,
                    actionLabel: 'common.retry'.tr(),
                    onRetry: controller.load,
                  ),
                )
              else if (!state.hasItems)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: AppEmptyState(
                    title: 'seller.listings_empty_title'.tr(),
                    message: 'seller.listings_empty_message'.tr(),
                    actionLabel: 'seller.create_listing'.tr(),
                    onAction: () => context.push(AppRoutes.sellerListingCreate),
                    icon: Icons.inventory_2_outlined,
                  ),
                )
              else ...[
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  sliver: SliverList.separated(
                    itemCount: state.items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final listing = state.items[index];
                      return ListingCard(
                        product: listing,
                        isDeleting: state.deletingIds.contains(listing.id),
                        onEdit: () => context.push(
                          AppRoutes.sellerListingEdit(listing.id),
                          extra: listing,
                        ),
                        onDelete: () => _confirmDelete(context, ref, listing),
                        onTap: () => context.push(AppRoutes.productDetails(listing.id)),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.sellerListingCreate),
        label: Text('seller.create_listing'.tr()),
        icon: const Icon(Icons.add_rounded),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Product listing,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('seller.delete_dialog_title'.tr()),
        content: Text('seller.delete_dialog_message'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('common.cancel'.tr()),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('seller.delete_listing'.tr()),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) {
      return;
    }

    final result = await ref
        .read(sellerListingsControllerProvider.notifier)
        .deleteListing(listing.id);
    if (!context.mounted) {
      return;
    }

    switch (result) {
      case Success():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('seller.delete_success'.tr())),
        );
      case Error(:final failure):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
    }
  }
}
