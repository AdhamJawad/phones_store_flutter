import '../../../products/domain/entities/category.dart';
import '../../../products/domain/entities/product.dart';
import 'device_request.dart';

class HomeFeed {
  const HomeFeed({
    required this.categories,
    required this.featuredProducts,
    required this.deviceRequests,
  });

  final List<Category> categories;
  final List<Product> featuredProducts;
  final List<DeviceRequest> deviceRequests;
}
