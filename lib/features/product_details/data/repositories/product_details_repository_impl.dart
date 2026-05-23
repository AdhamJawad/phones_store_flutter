import '../../../../core/errors/result.dart';
import '../../../../core/network/handlers/network_handler.dart';
import '../../../../data/repositories/base_repository_impl.dart';
import '../../../products/domain/entities/product.dart';
import '../../domain/entities/product_cta_config.dart';
import '../../domain/entities/product_details.dart';
import '../../domain/repositories/product_details_repository.dart';
import '../datasources/product_details_remote_data_source.dart';

class ProductDetailsRepositoryImpl extends BaseRepositoryImpl
    implements ProductDetailsRepository {
  ProductDetailsRepositoryImpl({
    required NetworkHandler networkHandler,
    required ProductDetailsRemoteDataSource remoteDataSource,
  })  : _remoteDataSource = remoteDataSource,
        super(networkHandler);

  final ProductDetailsRemoteDataSource _remoteDataSource;

  @override
  Future<Result<ProductDetails>> getProductDetails(int productId) {
    return guard(() async {
      final product = await _remoteDataSource.getProductDetails(productId);
      return ProductDetails(
        product: product,
        ctaConfig: _buildCtaConfig(product),
      );
    });
  }

  @override
  Future<Result<List<Product>>> getRelatedProducts({
    required int productId,
    required int categoryId,
  }) {
    return guard(() async {
      final products = await _remoteDataSource.getRelatedProducts(
        categoryId: categoryId,
      );

      return products
          .where((product) => product.id != productId)
          .take(6)
          .toList(growable: false);
    });
  }

  ProductCtaConfig _buildCtaConfig(Product product) {
    if (product.status != 'available') {
      return const ProductCtaConfig(
        type: ProductCtaType.unavailable,
        titleKey: 'product_details.cta_unavailable_title',
        subtitleKey: 'product_details.cta_unavailable_subtitle',
        enabled: false,
      );
    }

    if (product.isInventory) {
      final hasInStockVariant = product.variants.isEmpty ||
          product.variants.any((variant) => variant.stockQuantity > 0);

      return ProductCtaConfig(
        type: ProductCtaType.inventoryBuyNow,
        titleKey: 'product_details.cta_inventory_title',
        subtitleKey: hasInStockVariant
            ? 'product_details.cta_inventory_subtitle'
            : 'product_details.cta_inventory_out_of_stock_subtitle',
        enabled: hasInStockVariant,
      );
    }

    return const ProductCtaConfig(
      type: ProductCtaType.marketplaceRequestOrder,
      titleKey: 'product_details.cta_marketplace_title',
      subtitleKey: 'product_details.cta_marketplace_subtitle',
      enabled: true,
    );
  }
}
