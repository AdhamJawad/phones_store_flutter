import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../../core/widgets/app_surface_card.dart';
import '../../../../presentation/routing/app_routes.dart';
import '../../../../presentation/theme/app_radii.dart';
import '../../../../presentation/theme/app_spacing.dart';
import '../../../auth/presentation/models/auth_state.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../orders/domain/entities/order.dart';
import '../../../orders/domain/entities/order_payment_method.dart';
import '../../../orders/presentation/widgets/order_checkout_sheet.dart';
import '../../../products/domain/entities/product.dart';
import '../../../products/domain/entities/product_variant.dart';
import '../../domain/entities/product_cta_config.dart';
import '../providers/product_details_providers.dart';
import '../widgets/product_details_badge.dart';
import '../widgets/product_details_info_card.dart';
import '../widgets/product_image_gallery.dart';
import '../widgets/product_image_viewer.dart';
import '../widgets/product_related_section.dart';
import '../widgets/product_seller_card.dart';
import '../widgets/product_specification_row.dart';
import '../widgets/product_sticky_cta_bar.dart';
import '../widgets/product_variant_selector.dart';

class ProductDetailsPage extends ConsumerWidget {
  const ProductDetailsPage({required this.productId, super.key, this.heroTag});

  final int productId;
  final String? heroTag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productDetailsControllerProvider(productId));
    final controller = ref.read(
      productDetailsControllerProvider(productId).notifier,
    );
    final authState = ref.watch(authControllerProvider);

    final product = state.product;
    final galleryUrls = state.galleryUrls;

    if (state.isLoading && product == null) {
      return const _ProductDetailsLoadingPage();
    }

    if (state.hasError && product == null) {
      return Scaffold(
        appBar: AppBar(leading: const AppBackButton()),
        body: AppErrorState(
          title: 'product_details.error_title'.tr(),
          message: state.errorMessage!,
          actionLabel: 'common.retry'.tr(),
          onRetry: controller.load,
        ),
      );
    }

    if (product == null) {
      return Scaffold(
        appBar: AppBar(leading: const AppBackButton()),
        body: AppEmptyState(
          title: 'product_details.empty_title'.tr(),
          message: 'product_details.empty_message'.tr(),
        ),
      );
    }

    final selectedVariant = _findSelectedVariant(
      product: product,
      selectedVariantId: state.selectedVariantId,
    );

    final effectivePrice =
        product.price + (selectedVariant?.priceModifier ?? 0);
    final ctaConfig = state.ctaConfig!;
    final isSelfProduct =
        authState.session?.user.id == product.seller?.id &&
        authState.isAuthenticated;
    final canSubmitOrder =
        ctaConfig.enabled &&
        !isSelfProduct &&
        (!product.isInventory ||
            selectedVariant == null ||
            selectedVariant.stockQuantity > 0);

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text('product_details.title'.tr()),
      ),
      bottomNavigationBar: ProductStickyCtaBar(
        title: isSelfProduct
            ? 'orders.self_purchase_title'.tr()
            : ctaConfig.titleKey.tr(),
        subtitle: isSelfProduct
            ? 'orders.self_purchase_subtitle'.tr()
            : ctaConfig.subtitleKey.tr(),
        buttonLabel: isSelfProduct
            ? 'orders.self_purchase_button'.tr()
            : _ctaButtonLabel(ctaConfig.type).tr(),
        enabled: canSubmitOrder,
        onPressed: canSubmitOrder
            ? () => _handleOrderCta(
                context,
                ref,
                authState: authState,
                product: product,
                selectedVariant: selectedVariant,
              )
            : null,
      ),
      body: RefreshIndicator(
        onRefresh: controller.refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
              sliver: SliverToBoxAdapter(
                child: ProductImageGallery(
                  imageUrls: galleryUrls,
                  selectedIndex: state.safeSelectedImageIndex,
                  heroTag: heroTag ?? 'product-image-${product.id}',
                  onImageChanged: controller.selectImage,
                  onPreviewRequested: (index) {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ProductImageViewer(
                          imageUrls: galleryUrls,
                          initialIndex: index,
                        ),
                        fullscreenDialog: true,
                      ),
                    );
                  },
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: ProductDetailsInfoCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ProductDetailsBadge(
                            label: product.isInventory
                                ? 'products.source_inventory'.tr()
                                : 'products.source_marketplace'.tr(),
                            color: product.isInventory
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.secondary,
                          ),
                          ProductDetailsBadge(
                            label: _conditionLabel(product.condition).tr(),
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                            textColor: Theme.of(context).colorScheme.onSurface,
                          ),
                          ProductDetailsBadge(
                            label: _statusLabel(product.status).tr(),
                            color: product.status == 'available'
                                ? const Color(0xFF16A34A)
                                : Theme.of(context).colorScheme.error,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        product.displayTitle,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.w900,
                              height: 1.3,
                            ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${effectivePrice.toStringAsFixed(0)} ${'products.currency'.tr()}',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.place_outlined, size: 18),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              product.location ??
                                  product.seller?.location ??
                                  'product_details.location_unknown'.tr(),
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (product.isInventory && product.variants.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: ProductVariantSelector(
                    variants: product.variants,
                    selectedVariantId: state.selectedVariantId,
                    onSelect: controller.selectVariant,
                  ),
                ),
              ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              sliver: SliverToBoxAdapter(
                child: ProductSellerCard(product: product),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              sliver: SliverToBoxAdapter(
                child: ProductDetailsInfoCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'product_details.specifications_title'.tr(),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 12),
                      ProductSpecificationRow(
                        label: 'product_details.brand_label'.tr(),
                        value: product.brand,
                      ),
                      ProductSpecificationRow(
                        label: 'product_details.model_label'.tr(),
                        value: product.model,
                      ),
                      if (product.category?.name != null)
                        ProductSpecificationRow(
                          label: 'product_details.category_label'.tr(),
                          value: product.category!.name,
                        ),
                      if ((product.color ?? '').trim().isNotEmpty)
                        ProductSpecificationRow(
                          label: 'product_details.color_label'.tr(),
                          value: product.color!,
                        ),
                      if ((product.accessories ?? '').trim().isNotEmpty)
                        ProductSpecificationRow(
                          label: 'product_details.accessories_label'.tr(),
                          value: product.accessories!,
                        ),
                      ProductSpecificationRow(
                        label: 'product_details.disassembled_label'.tr(),
                        value: product.disassembledIs
                            ? 'product_details.yes'.tr()
                            : 'product_details.no'.tr(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if ((product.description ?? '').trim().isNotEmpty ||
                (product.conditionNotes ?? '').trim().isNotEmpty ||
                (product.defects ?? '').trim().isNotEmpty ||
                (product.reasonDisassembly ?? '').trim().isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: ProductDetailsInfoCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'product_details.description_title'.tr(),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        if ((product.description ?? '').trim().isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            product.description!,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(height: 1.7),
                          ),
                        ],
                        if ((product.conditionNotes ?? '')
                            .trim()
                            .isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text(
                            'product_details.condition_notes_title'.tr(),
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            product.conditionNotes!,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(height: 1.7),
                          ),
                        ],
                        if ((product.defects ?? '').trim().isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text(
                            'product_details.defects_title'.tr(),
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            product.defects!,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(height: 1.7),
                          ),
                        ],
                        if ((product.reasonDisassembly ?? '')
                            .trim()
                            .isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text(
                            'product_details.reason_disassembly_title'.tr(),
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            product.reasonDisassembly!,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(height: 1.7),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: AppSectionHeader(
                title: 'product_details.related_title'.tr(),
                subtitle: 'product_details.related_subtitle'.tr(),
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              ),
            ),
            SliverToBoxAdapter(
              child: ProductRelatedSection(
                items: state.relatedProducts,
                isLoading: state.isRelatedLoading,
                onTapProduct: (relatedProduct) {
                  context.pushReplacement(
                    AppRoutes.productDetails(relatedProduct.id),
                  );
                },
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
    );
  }

  Future<void> _handleOrderCta(
    BuildContext context,
    WidgetRef ref, {
    required AuthState authState,
    required Product product,
    required ProductVariant? selectedVariant,
  }) async {
    if (!authState.isAuthenticated) {
      final from = Uri.encodeComponent(AppRoutes.productDetails(product.id));
      context.go('${AppRoutes.login}?from=$from');
      return;
    }

    final createdOrder = await showModalBottomSheet<Order>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) {
        return OrderCheckoutSheet(
          product: product,
          selectedVariant: selectedVariant,
          initialPaymentMethods: _paymentMethodsForProduct(product),
        );
      },
    );

    if (!context.mounted || createdOrder == null) {
      return;
    }

    context.push(AppRoutes.orderDetails(createdOrder.id));
  }

  String _ctaButtonLabel(ProductCtaType type) {
    switch (type) {
      case ProductCtaType.inventoryBuyNow:
        return 'product_details.cta_inventory_button';
      case ProductCtaType.marketplaceRequestOrder:
        return 'product_details.cta_marketplace_button';
      case ProductCtaType.unavailable:
        return 'product_details.cta_unavailable_button';
    }
  }

  List<OrderPaymentMethod> _paymentMethodsForProduct(Product product) {
    if (product.isInventory) {
      return const <OrderPaymentMethod>[
        OrderPaymentMethod.cod,
        OrderPaymentMethod.wallet,
        OrderPaymentMethod.stripe,
      ];
    }

    return const <OrderPaymentMethod>[
      OrderPaymentMethod.cod,
      OrderPaymentMethod.wallet,
    ];
  }

  ProductVariant? _findSelectedVariant({
    required Product product,
    required int? selectedVariantId,
  }) {
    if (selectedVariantId == null) {
      return null;
    }

    for (final variant in product.variants) {
      if (variant.id == selectedVariantId) {
        return variant;
      }
    }

    return null;
  }

  String _conditionLabel(String value) {
    switch (value) {
      case 'new':
        return 'products.condition_new';
      case 'used':
        return 'products.condition_used';
      default:
        return 'products.condition_used';
    }
  }

  String _statusLabel(String value) {
    switch (value) {
      case 'available':
        return 'product_details.status_available';
      case 'sold':
        return 'product_details.status_sold';
      default:
        return 'product_details.status_unavailable';
    }
  }
}

class _ProductDetailsLoadingPage extends StatelessWidget {
  const _ProductDetailsLoadingPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const AppBackButton()),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.page),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            AppSkeleton(
              child: AppSkeletonBox(
                height: 320,
                borderRadius: BorderRadius.all(Radius.circular(AppRadii.hero)),
              ),
            ),
            SizedBox(height: AppSpacing.md),
            AppSurfaceCard(
              child: AppSkeleton(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSkeletonBox(height: 18, width: 120),
                    SizedBox(height: AppSpacing.md),
                    AppSkeletonBox(height: 28, width: double.infinity),
                    SizedBox(height: AppSpacing.sm),
                    AppSkeletonBox(height: 20, width: 160),
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
