import '../../../../core/network/dto/paginated_response_meta.dart';
import '../../domain/entities/product_page.dart';
import 'product_model.dart';

class ProductPageModel extends ProductPage {
  const ProductPageModel({
    required super.items,
    required super.meta,
  });

  factory ProductPageModel.fromEnvelope(Map<String, dynamic> envelope) {
    final rawData = envelope['data'];
    final rawMeta = envelope['meta'];

    return ProductPageModel(
      items: rawData is List
          ? rawData
              .whereType<Map>()
              .map((item) => ProductModel.fromJson(Map<String, dynamic>.from(item)))
              .toList(growable: false)
          : const <ProductModel>[],
      meta: rawMeta is Map<String, dynamic>
          ? PaginatedResponseMeta.fromJson(rawMeta)
          : rawMeta is Map
              ? PaginatedResponseMeta.fromJson(
                  Map<String, dynamic>.from(rawMeta),
                )
              : const PaginatedResponseMeta(
                  currentPage: 1,
                  lastPage: 1,
                  perPage: 0,
                  total: 0,
                  hasMorePages: false,
                ),
    );
  }
}
