import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_paginated_footer_loader.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../../presentation/routing/app_routes.dart';
import '../../../../presentation/theme/app_radii.dart';
import '../../../../presentation/theme/app_spacing.dart';
import '../../../products/presentation/widgets/product_card_grid_delegate.dart';
import '../providers/device_catalog_providers.dart';
import '../widgets/device_card.dart';

class DevicesPage extends ConsumerStatefulWidget {
  const DevicesPage({super.key});

  @override
  ConsumerState<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends ConsumerState<DevicesPage>
    with AutomaticKeepAliveClientMixin<DevicesPage> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(deviceCatalogControllerProvider);
    final controller = ref.read(deviceCatalogControllerProvider.notifier);

    if (_searchController.text != state.query) {
      _searchController.value = TextEditingValue(
        text: state.query,
        selection: TextSelection.collapsed(offset: state.query.length),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('devices.title'.tr()),
        actions: [
          IconButton(
            tooltip: 'compare.title'.tr(),
            onPressed: () => context.push(AppRoutes.deviceCompare),
            icon: const Icon(Icons.compare_arrows_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.refresh,
          child: NotificationListener<ScrollEndNotification>(
            onNotification: (notification) {
              final metrics = notification.metrics;
              if (metrics.pixels >= metrics.maxScrollExtent - 300) {
                controller.loadMore();
              }
              return false;
            },
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'devices.title'.tr(),
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'devices.subtitle'.tr(),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        TextField(
                          controller: _searchController,
                          textInputAction: TextInputAction.search,
                          onSubmitted: controller.submitSearch,
                          decoration: InputDecoration(
                            hintText: 'devices.search_hint'.tr(),
                            prefixIcon: const Icon(Icons.search_rounded),
                            suffixIcon: state.query.trim().isEmpty
                                ? null
                                : IconButton(
                                    onPressed: controller.clearSearch,
                                    icon: const Icon(Icons.close_rounded),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: AppSectionHeader(
                    title: 'devices.brand_filter_title'.tr(),
                    subtitle: 'devices.brand_filter_subtitle'.tr(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 56,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.page,
                        8,
                        AppSpacing.page,
                        4,
                      ),
                      scrollDirection: Axis.horizontal,
                      itemCount: state.availableBrands.length + 1,
                      separatorBuilder: (_, _) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final isAll = index == 0;
                        final brand = isAll
                            ? null
                            : state.availableBrands[index - 1];
                        final selected = isAll
                            ? state.selectedBrand == null
                            : state.selectedBrand == brand;
                        return ChoiceChip(
                          label: Text(
                            isAll ? 'devices.filter_all_brands'.tr() : brand!,
                          ),
                          selected: selected,
                          onSelected: (_) => controller.setBrand(brand),
                        );
                      },
                    ),
                  ),
                ),
                if (state.isLoading && !state.hasItems)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.page,
                      8,
                      AppSpacing.page,
                      24,
                    ),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        _buildLoadingCard,
                        childCount: 6,
                      ),
                      gridDelegate: buildProductCardGridDelegate(context),
                    ),
                  )
                else if (state.hasError && !state.hasItems)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: AppErrorState(
                      title: 'devices.error_title'.tr(),
                      message: state.errorMessage!,
                      actionLabel: 'common.retry'.tr(),
                      onRetry: controller.load,
                    ),
                  )
                else if (!state.hasItems)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: AppEmptyState(
                      title: 'devices.empty_title'.tr(),
                      message: 'devices.empty_message'.tr(),
                      actionLabel: 'devices.clear_filters'.tr(),
                      onAction: () async {
                        await controller.setBrand(null);
                        await controller.clearSearch();
                      },
                    ),
                  )
                else ...[
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.page,
                      12,
                      AppSpacing.page,
                      20,
                    ),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final device = state.items[index];
                        return DeviceCard(
                          device: device,
                          onTap: () =>
                              context.push(AppRoutes.deviceDetails(device.id)),
                        );
                      }, childCount: state.items.length),
                      gridDelegate: buildProductCardGridDelegate(context),
                    ),
                  ),
                  if (state.isLoadingMore)
                    const SliverToBoxAdapter(child: AppPaginatedFooterLoader()),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildLoadingCard(BuildContext context, int index) {
    return const _DeviceCardSkeleton();
  }
}

class _DeviceCardSkeleton extends StatelessWidget {
  const _DeviceCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return AppSkeleton(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadii.xl),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 6,
              child: AppSkeletonBox(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppRadii.xl),
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Padding(
                padding: EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSkeletonBox(height: 14, width: 90),
                    SizedBox(height: 8),
                    AppSkeletonBox(height: 18, width: double.infinity),
                    SizedBox(height: 8),
                    AppSkeletonBox(height: 18, width: 140),
                    Spacer(),
                    AppSkeletonBox(height: 14, width: 100),
                    SizedBox(height: 8),
                    AppSkeletonBox(height: 14, width: 120),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
