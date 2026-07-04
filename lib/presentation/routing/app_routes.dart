final class AppRoutes {
  AppRoutes._();

  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const products = '/products';
  static const productDetailsSegment = 'details';
  static const orders = '/orders';
  static const ordersSales = '/orders/sales';
  static const wallet = '/wallet';
  static const walletTransactions = '/wallet/transactions';
  static const walletRechargeRequests = '/wallet/recharge-requests';
  static const notifications = '/notifications';
  static const profile = '/profile';
  static const profileEdit = '/profile/edit';
  static const devices = '/devices';
  static const deviceCompare = '/devices/compare';
  static const deviceCompareResult = '/devices/compare/result';
  static const aiAdvisor = '/ai-advisor';
  static const sellerDashboard = '/seller';
  static const sellerListings = '/seller/listings';
  static const sellerListingCreate = '/seller/listings/create';
  static const deviceRequests = '/device-requests';
  static const deviceRequestsCreate = '/device-requests/create';

  static String productDetails(int productId, {String? heroTag}) {
    final path = '$products/$productId';
    if (heroTag == null || heroTag.isEmpty) {
      return path;
    }

    return Uri(
      path: path,
      queryParameters: <String, String>{'heroTag': heroTag},
    ).toString();
  }

  static String orderDetails(int orderId) => '$orders/$orderId';
  static String deviceDetails(int deviceId) => '$devices/$deviceId';
  static String sellerListingEdit(int productId) =>
      '$sellerListings/$productId/edit';
}
