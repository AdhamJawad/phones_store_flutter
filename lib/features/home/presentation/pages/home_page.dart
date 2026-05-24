import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../../../presentation/routing/app_routes.dart';
import '../../../../presentation/theme/app_branding.dart';
import '../../../../presentation/theme/app_radii.dart';
import '../../../../presentation/theme/app_spacing.dart';
import '../../../products/presentation/widgets/category_chip_card.dart';
import '../../../products/presentation/widgets/product_card.dart';
import '../../../products/presentation/widgets/product_card_skeleton.dart';
import '../../../products/presentation/widgets/product_card_grid_delegate.dart';
import '../providers/home_providers.dart';
import '../widgets/device_request_card.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with AutomaticKeepAliveClientMixin<HomePage> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(homeControllerProvider);
    final controller = ref.read(homeControllerProvider.notifier);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: controller.refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _HomeHero(
                onBrowseProducts: () => context.go(AppRoutes.products),
              ),
            ),
            if (state.isLoading && !state.hasData)
              SliverPadding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 24),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    _buildLoadingProduct,
                    childCount: 4,
                  ),
                  gridDelegate: buildProductCardGridDelegate(context),
                ),
              )
            else if (state.hasError && !state.hasData)
              SliverFillRemaining(
                hasScrollBody: false,
                child: AppErrorState(
                  title: 'home.load_failed_title'.tr(),
                  message: state.errorMessage!,
                  actionLabel: 'common.retry'.tr(),
                  onRetry: controller.load,
                ),
              )
            else if (!state.hasData)
              SliverFillRemaining(
                hasScrollBody: false,
                child: AppEmptyState(
                  title: 'home.empty_title'.tr(),
                  message: 'home.empty_message'.tr(),
                ),
              )
            else ...[
              SliverToBoxAdapter(
                child: AppSectionHeader(
                  title: 'home.categories_title'.tr(),
                  subtitle: 'home.categories_subtitle'.tr(),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 94,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.page,
                      12,
                      AppSpacing.page,
                      8,
                    ),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      final category = state.feed!.categories[index];
                      return CategoryChipCard(
                        category: category,
                        onTap: () {
                          final uri = Uri(
                            path: AppRoutes.products,
                            queryParameters: <String, String>{
                              'categoryId': '${category.id}',
                              'categoryName': category.name,
                            },
                          );
                          context.go(uri.toString());
                        },
                      );
                    },
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemCount: state.feed!.categories.length,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: AppSectionHeader(
                  title: 'home.featured_products_title'.tr(),
                  subtitle: 'home.featured_products_subtitle'.tr(),
                  actionLabel: 'home.show_all'.tr(),
                  onAction: () => context.go(AppRoutes.products),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  12,
                  AppSpacing.page,
                  16,
                ),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final product = state.feed!.featuredProducts[index];
                    final heroTag = 'home-featured-${product.id}-$index';
                    return ProductCard(
                      product: product,
                      heroTag: heroTag,
                      onTap: () => context.push(
                        AppRoutes.productDetails(product.id, heroTag: heroTag),
                      ),
                    );
                  }, childCount: state.feed!.featuredProducts.length),
                  gridDelegate: buildProductCardGridDelegate(context),
                ),
              ),
              SliverToBoxAdapter(
                child: AppSectionHeader(
                  title: 'home.device_requests_title'.tr(),
                  subtitle: 'home.device_requests_subtitle'.tr(),
                  actionLabel: 'home.show_all'.tr(),
                  onAction: () => context.push(AppRoutes.deviceRequests),
                ),
              ),
              if (state.feed!.deviceRequests.isEmpty)
                SliverToBoxAdapter(
                  child: AppEmptyState(
                    title: 'home.no_requests_title'.tr(),
                    message: 'home.no_requests_message'.tr(),
                    compact: true,
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page,
                    12,
                    AppSpacing.page,
                    28,
                  ),
                  sliver: SliverList.separated(
                    itemBuilder: (context, index) {
                      return DeviceRequestCard(
                        request: state.feed!.deviceRequests[index],
                      );
                    },
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemCount: state.feed!.deviceRequests.length,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  static Widget _buildLoadingProduct(BuildContext context, int index) {
    return const ProductCardSkeleton();
  }
}

class _HomeHero extends StatelessWidget {
  const _HomeHero({required this.onBrowseProducts});

  final VoidCallback onBrowseProducts;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.page,
        AppSpacing.page,
        AppSpacing.section,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: AppBranding.primaryHeroGradient,
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.20),
              blurRadius: 30,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.hero),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'home.hero_title'.tr(),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'home.hero_subtitle'.tr(),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.82),
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: AppSpacing.section),
                FilledButton.tonal(
                  onPressed: onBrowseProducts,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: theme.colorScheme.primary,
                  ),
                  child: Text('home.hero_cta'.tr()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
