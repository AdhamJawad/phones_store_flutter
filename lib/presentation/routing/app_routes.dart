final class AppRoutes {
  AppRoutes._();

  static const splash = '/';
  static const login = '/login';
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
  static const sellerDashboard = '/seller';
  static const sellerListings = '/seller/listings';
  static const sellerListingCreate = '/seller/listings/create';
  static const deviceRequests = '/device-requests';
  static const deviceRequestsCreate = '/device-requests/create';

  static String productDetails(int productId) => '$products/$productId';
  static String orderDetails(int orderId) => '$orders/$orderId';
  static String sellerListingEdit(int productId) => '$sellerListings/$productId/edit';
}
