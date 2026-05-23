import '../../../home/domain/entities/device_request_page.dart';
import 'product_page.dart';

class SearchResults {
  const SearchResults({
    required this.query,
    required this.products,
    required this.deviceRequests,
  });

  final String query;
  final ProductPage products;
  final DeviceRequestPage deviceRequests;
}
