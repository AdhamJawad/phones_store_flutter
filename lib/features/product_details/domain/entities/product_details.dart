import '../../../products/domain/entities/product.dart';
import '../../../products/domain/entities/product_image.dart';
import '../../../products/domain/entities/product_variant.dart';
import 'product_cta_config.dart';

class ProductDetails {
  const ProductDetails({
    required this.product,
    required this.ctaConfig,
  });

  final Product product;
  final ProductCtaConfig ctaConfig;

  List<ProductImage> get galleryImages {
    if (product.images.isNotEmpty) {
      return product.images;
    }

    final primaryImageUrl = product.primaryImageUrl;
    if (primaryImageUrl == null || primaryImageUrl.trim().isEmpty) {
      return const <ProductImage>[];
    }

    return <ProductImage>[
      ProductImage(
        id: product.id,
        url: primaryImageUrl,
        isPrimary: true,
      ),
    ];
  }

  List<ProductVariant> get variants => product.variants;

  ProductVariant? get defaultVariant {
    if (variants.isEmpty) {
      return null;
    }

    for (final variant in variants) {
      if (variant.stockQuantity > 0) {
        return variant;
      }
    }

    return variants.first;
  }
}
