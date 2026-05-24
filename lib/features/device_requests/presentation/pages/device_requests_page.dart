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
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../home/domain/entities/device_request.dart';
import '../providers/device_requests_providers.dart';
import '../widgets/device_request_card.dart';

class DeviceRequestsPage extends ConsumerWidget {
  const DeviceRequestsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(deviceRequestsControllerProvider);
    final controller = ref.read(deviceRequestsControllerProvider.notifier);
    final authUser = ref.watch(authControllerProvider).session?.user;

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text('device_requests.title'.tr()),
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
                    'device_requests.subtitle'.tr(),
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
                    title: 'device_requests.error_title'.tr(),
                    message: state.errorMessage!,
                    actionLabel: 'common.retry'.tr(),
                    onRetry: controller.load,
                  ),
                )
              else if (!state.hasItems)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: AppEmptyState(
                    title: 'device_requests.empty_title'.tr(),
                    message: 'device_requests.empty_message'.tr(),
                    icon: Icons.phone_android_rounded,
                    actionLabel: 'device_requests.create_cta'.tr(),
                    onAction: () =>
                        context.push(AppRoutes.deviceRequestsCreate),
                  ),
                )
              else ...[
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  sliver: SliverList.separated(
                    itemCount: state.items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final request = state.items[index];
                      final isOwnRequest = authUser?.id == request.user?.id;
                      return MarketplaceDeviceRequestCard(
                        request: request,
                        canOffer: true,
                        isOwnRequest: isOwnRequest,
                        isOffering: state.offeringIds.contains(request.id),
                        onOffer: () => _sendOffer(context, ref, request),
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
        onPressed: () => context.push(AppRoutes.deviceRequestsCreate),
        icon: const Icon(Icons.add_rounded),
        label: Text('device_requests.create_cta'.tr()),
      ),
    );
  }

  Future<void> _sendOffer(
    BuildContext context,
    WidgetRef ref,
    DeviceRequest request,
  ) async {
    final result = await ref
        .read(deviceRequestsControllerProvider.notifier)
        .sendOffer(request.id);
    if (!context.mounted) {
      return;
    }

    switch (result) {
      case Success():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('device_requests.offer_success'.tr())),
        );
      case Error(:final failure):
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.message)));
    }
  }
}
