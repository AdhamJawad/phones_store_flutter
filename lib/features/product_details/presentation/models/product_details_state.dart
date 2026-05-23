import '../../../../core/errors/failure.dart';
import '../../../products/domain/entities/product.dart';
import '../../domain/entities/product_cta_config.dart';
import '../../domain/entities/product_details.dart';

class ProductDetailsState {
  const ProductDetailsState({
    required this.isLoading,
    required this.isRefreshing,
    required this.isRelatedLoading,
    required this.selectedImageIndex,
    this.details,
    this.relatedProducts = const <Product>[],
    this.selectedVariantId,
    this.failure,
    this.errorMessage,
  });

  const ProductDetailsState.initial()
      : isLoading = true,
        isRefreshing = false,
        isRelatedLoading = false,
        selectedImageIndex = 0,
        details = null,
        relatedProducts = const <Product>[],
        selectedVariantId = null,
        failure = null,
        errorMessage = null;

  final bool isLoading;
  final bool isRefreshing;
  final bool isRelatedLoading;
  final int selectedImageIndex;
  final ProductDetails? details;
  final List<Product> relatedProducts;
  final int? selectedVariantId;
  final Failure? failure;
  final String? errorMessage;

  bool get hasData => details != null;
  bool get hasError => errorMessage != null && errorMessage!.trim().isNotEmpty;

  Product? get product => details?.product;

  ProductCtaConfig? get ctaConfig => details?.ctaConfig;

  List<String> get galleryUrls {
    final images = details?.galleryImages ?? const [];
    return images.map((image) => image.url).toList(growable: false);
  }

  int get safeSelectedImageIndex {
    final count = galleryUrls.length;
    if (count == 0) {
      return 0;
    }

    if (selectedImageIndex < 0) {
      return 0;
    }

    if (selectedImageIndex >= count) {
      return count - 1;
    }

    return selectedImageIndex;
  }

  ProductDetailsState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    bool? isRelatedLoading,
    int? selectedImageIndex,
    ProductDetails? details,
    List<Product>? relatedProducts,
    int? selectedVariantId,
    Failure? failure,
    String? errorMessage,
    bool clearDetails = false,
    bool clearRelated = false,
    bool clearSelectedVariant = false,
    bool clearFailure = false,
    bool clearError = false,
  }) {
    return ProductDetailsState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isRelatedLoading: isRelatedLoading ?? this.isRelatedLoading,
      selectedImageIndex: selectedImageIndex ?? this.selectedImageIndex,
      details: clearDetails ? null : details ?? this.details,
      relatedProducts: clearRelated ? const <Product>[] : relatedProducts ?? this.relatedProducts,
      selectedVariantId: clearSelectedVariant
          ? null
          : selectedVariantId ?? this.selectedVariantId,
      failure: clearFailure ? null : failure ?? this.failure,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
