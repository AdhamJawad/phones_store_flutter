import '../../domain/entities/seller_dashboard_stats.dart';

class SellerDashboardStatsModel extends SellerDashboardStats {
  const SellerDashboardStatsModel({
    required super.totalListings,
    required super.activeListings,
    required super.totalOrders,
    required super.totalSales,
    required super.walletBalance,
  });

  factory SellerDashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return SellerDashboardStatsModel(
      totalListings: (json['total_listings'] as num?)?.toInt() ?? 0,
      activeListings: (json['active_listings'] as num?)?.toInt() ?? 0,
      totalOrders: (json['total_orders'] as num?)?.toInt() ?? 0,
      totalSales: (json['total_sales'] as num?)?.toInt() ?? 0,
      walletBalance: (json['wallet_balance'] as num?)?.toDouble() ?? 0,
    );
  }
}
