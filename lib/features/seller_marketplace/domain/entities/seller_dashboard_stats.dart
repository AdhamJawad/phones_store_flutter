class SellerDashboardStats {
  const SellerDashboardStats({
    required this.totalListings,
    required this.activeListings,
    required this.totalOrders,
    required this.totalSales,
    required this.walletBalance,
  });

  final int totalListings;
  final int activeListings;
  final int totalOrders;
  final int totalSales;
  final double walletBalance;
}
