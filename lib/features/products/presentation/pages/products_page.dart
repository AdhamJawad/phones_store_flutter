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
import '../../../../presentation/theme/app_spacing.dart';
import '../../domain/entities/category.dart';
import '../models/products_query.dart';
import '../providers/products_providers.dart';
import '../widgets/category_chip_card.dart';
import '../widgets/product_card.dart';
import '../widgets/product_card_skeleton.dart';

class ProductsPage extends ConsumerStatefulWidget {
  const ProductsPage({
    required this.query,
    super.key,
  });

  final ProductsQuery query;

  @override
  ConsumerState<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends ConsumerState<ProductsPage>
    with AutomaticKeepAliveClientMixin<ProductsPage> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(productsControllerProvider(widget.query));
    final controller = ref.read(productsControllerProvider(widget.query).notifier);
    final categories = ref.watch(catalogCategoriesProvider);

    return SafeArea(
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
                        'products.title'.tr(),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'products.subtitle'.tr(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: _SourceFilters(
                  selectedSource: state.selectedSource,
                  onChanged: (source) async {
                    final uri = Uri(
                      path: AppRoutes.products,
                      queryParameters: _buildQueryParameters(
                        source: source,
                        categoryId: state.selectedCategoryId,
                        categoryName: state.selectedCategoryName,
                      ),
                    );
                    context.go(uri.toString());
                  },
                ),
              ),
              SliverToBoxAdapter(
                child: AppSectionHeader(
                  title: 'products.categories_filter_title'.tr(),
                  subtitle: state.selectedCategoryName == null
                      ? 'products.categories_filter_subtitle'.tr()
                      : '${'products.filtered_by'.tr()} ${state.selectedCategoryName}',
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 94,
                  child: categories.when(
                    data: (items) => ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.page,
                        12,
                        AppSpacing.page,
                        8,
                      ),
                      scrollDirection: Axis.horizontal,
                      itemCount: items.length + 1,
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return _AllCategoriesChip(
                            selected: state.selectedCategoryId == null,
                            onTap: () {
                              final uri = Uri(
                                path: AppRoutes.products,
                                queryParameters: _buildQueryParameters(
                                  source: state.selectedSource,
                                ),
                              );
                              context.go(uri.toString());
                            },
                          );
                        }

                        final category = items[index - 1];
                        return CategoryChipCard(
                          category: category,
                          isSelected: state.selectedCategoryId == category.id,
                          onTap: () {
                            final uri = Uri(
                              path: AppRoutes.products,
                              queryParameters: _buildQueryParameters(
                                source: state.selectedSource,
                                categoryId: category.id,
                                categoryName: category.name,
                              ),
                            );
                            context.go(uri.toString());
                          },
                        );
                      },
                    ),
                    loading: () => const _CategoriesSkeleton(),
                    error: (_, _) => const SizedBox.shrink(),
                  ),
                ),
              ),
              if (state.isLoading && !state.hasItems)
                const SliverPadding(
                  padding: EdgeInsets.fromLTRB(20, 8, 20, 24),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      _buildLoadingProduct,
                      childCount: 6,
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.68,
                    ),
                  ),
                )
              else if (state.hasError && !state.hasItems)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: AppErrorState(
                    title: 'products.error_title'.tr(),
                    message: state.errorMessage!,
                    actionLabel: 'common.retry'.tr(),
                    onRetry: controller.load,
                  ),
                )
              else if (!state.hasItems)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: AppEmptyState(
                    title: 'products.empty_title'.tr(),
                    message: 'products.empty_message'.tr(),
                    actionLabel: 'products.clear_filters'.tr(),
                    onAction: () {
                      context.go(AppRoutes.products);
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
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = state.items[index];
                        return ProductCard(
                          product: product,
                          onTap: () => context.go(AppRoutes.productDetails(product.id)),
                        );
                      },
                      childCount: state.items.length,
                    ),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.68,
                    ),
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
    );
  }

  static Widget _buildLoadingProduct(BuildContext context, int index) {
    return const ProductCardSkeleton();
  }

  Map<String, String> _buildQueryParameters({
    String? source,
    int? categoryId,
    String? categoryName,
  }) {
    return <String, String>{
      if (source != null && source.isNotEmpty) 'source': source,
      if (categoryId != null) 'categoryId': '$categoryId',
      if (categoryName != null && categoryName.isNotEmpty)
        'categoryName': categoryName,
    };
  }
}

class _SourceFilters extends StatelessWidget {
  const _SourceFilters({
    required this.selectedSource,
    required this.onChanged,
  });

  final String? selectedSource;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final filters = <({String? value, String label})>[
      (value: null, label: 'products.filter_all'.tr()),
      (value: 'user', label: 'products.source_marketplace'.tr()),
      (value: 'inventory', label: 'products.source_inventory'.tr()),
    ];

    return SizedBox(
      height: 56,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          8,
          AppSpacing.page,
          4,
        ),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final selected = selectedSource == filter.value;
          return ChoiceChip(
            label: Text(filter.label),
            selected: selected,
            onSelected: (_) => onChanged(filter.value),
          );
        },
      ),
    );
  }
}

class _AllCategoriesChip extends StatelessWidget {
  const _AllCategoriesChip({
    required this.selected,
    required this.onTap,
  });

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CategoryChipCard(
      category: Category(
        id: 0,
        name: 'products.all_categories'.tr(),
        slug: 'all',
      ),
      isSelected: selected,
      onTap: onTap,
    );
  }
}

class _CategoriesSkeleton extends StatelessWidget {
  const _CategoriesSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        12,
        AppSpacing.page,
        8,
      ),
      scrollDirection: Axis.horizontal,
      itemBuilder: (_, index) => const AppSkeleton(
        child: AppSkeletonBox(
          width: 120,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),
      separatorBuilder: (_, _) => const SizedBox(width: 12),
      itemCount: 4,
    );
  }
}
