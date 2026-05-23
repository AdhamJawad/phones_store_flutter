import '../../../../core/network/dto/paginated_response_meta.dart';
import '../../../home/data/models/device_request_page_model.dart';
import '../../domain/entities/search_results.dart';
import 'product_page_model.dart';

class SearchResultsModel extends SearchResults {
  const SearchResultsModel({
    required super.query,
    required super.products,
    required super.deviceRequests,
  });

  factory SearchResultsModel.fromJson(Map<String, dynamic> json) {
    return SearchResultsModel(
      query: json['query'] as String? ?? '',
      products: json['products'] is Map<String, dynamic>
          ? ProductPageModel.fromEnvelope(json['products'] as Map<String, dynamic>)
          : json['products'] is Map
              ? ProductPageModel.fromEnvelope(
                  Map<String, dynamic>.from(json['products'] as Map),
                )
              : const ProductPageModel(
                  items: [],
                  meta: PaginatedResponseMeta(
                    currentPage: 1,
                    lastPage: 1,
                    perPage: 0,
                    total: 0,
                    hasMorePages: false,
                  ),
                ),
      deviceRequests: json['device_requests'] is Map<String, dynamic>
          ? DeviceRequestPageModel.fromEnvelope(
              json['device_requests'] as Map<String, dynamic>,
            )
          : json['device_requests'] is Map
              ? DeviceRequestPageModel.fromEnvelope(
                  Map<String, dynamic>.from(json['device_requests'] as Map),
                )
              : const DeviceRequestPageModel(
                  items: [],
                  meta: PaginatedResponseMeta(
                    currentPage: 1,
                    lastPage: 1,
                    perPage: 0,
                    total: 0,
                    hasMorePages: false,
                  ),
                ),
    );
  }
}
