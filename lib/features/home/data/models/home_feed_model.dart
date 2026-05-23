import '../../../products/data/models/category_model.dart';
import '../../../products/data/models/product_model.dart';
import '../../domain/entities/home_feed.dart';
import 'device_request_model.dart';

class HomeFeedModel extends HomeFeed {
  const HomeFeedModel({
    required super.categories,
    required super.featuredProducts,
    required super.deviceRequests,
  });

  factory HomeFeedModel.fromJson(Map<String, dynamic> json) {
    return HomeFeedModel(
      categories: _parseList(
        json['categories'],
        (value) => CategoryModel.fromJson(value),
      ),
      featuredProducts: _parseList(
        json['featured_products'],
        (value) => ProductModel.fromJson(value),
      ),
      deviceRequests: _parseList(
        json['device_requests'],
        (value) => DeviceRequestModel.fromJson(value),
      ),
    );
  }

  static List<T> _parseList<T>(
    Object? raw,
    T Function(Map<String, dynamic> json) fromJson,
  ) {
    if (raw is! List) {
      return <T>[];
    }

    return raw
        .whereType<Map>()
        .map((item) => fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }
}
