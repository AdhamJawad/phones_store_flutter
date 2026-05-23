import '../../../products/domain/entities/product.dart';
import 'seller_dashboard_stats.dart';

class SellerDashboard {
  const SellerDashboard({
    required this.stats,
    required this.recentListings,
  });

  final SellerDashboardStats stats;
  final List<Product> recentListings;
}
