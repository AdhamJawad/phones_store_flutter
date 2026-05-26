import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/route_stub_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/widgets/auth_bootstrap_page.dart';
import '../../features/device_requests/presentation/pages/create_device_request_page.dart';
import '../../features/device_requests/presentation/pages/device_requests_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/orders/presentation/pages/order_details_page.dart';
import '../../features/orders/presentation/pages/orders_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/product_details/presentation/pages/product_details_page.dart';
import '../../features/products/domain/entities/product.dart';
import '../../features/products/presentation/models/products_query.dart';
import '../../features/products/presentation/pages/products_page.dart';
import '../../features/profile/presentation/pages/profile_edit_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/seller_marketplace/presentation/pages/listing_form_page.dart';
import '../../features/seller_marketplace/presentation/pages/seller_dashboard_page.dart';
import '../../features/seller_marketplace/presentation/pages/seller_listings_page.dart';
import '../../features/wallet/presentation/pages/recharge_requests_page.dart';
import '../../features/wallet/presentation/pages/wallet_page.dart';
import '../../features/wallet/presentation/pages/wallet_transactions_page.dart';
import '../shell/main_shell_page.dart';
import 'app_routes.dart';

final class AppRouter {
  const AppRouter._();

  static GoRouter create(AuthRouterNotifier authRouterNotifier) {
    return GoRouter(
      initialLocation: AppRoutes.splash,
      refreshListenable: authRouterNotifier,
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          pageBuilder: (_, state) =>
              _buildPage(state, const AuthBootstrapPage()),
        ),
        GoRoute(
          path: AppRoutes.login,
          pageBuilder: (_, state) => _buildPage(state, const LoginPage()),
        ),
        GoRoute(
          path: AppRoutes.register,
          pageBuilder: (_, state) => _buildPage(state, const RegisterPage()),
        ),
        StatefulShellRoute.indexedStack(
          builder: (_, _, navigationShell) {
            return MainShellPage(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.home,
                  pageBuilder: (_, state) =>
                      _buildPage(state, const HomePage()),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.products,
                  pageBuilder: (_, state) {
                    final categoryId = int.tryParse(
                      state.uri.queryParameters['categoryId'] ?? '',
                    );

                    return _buildPage(
                      state,
                      ProductsPage(
                        query: ProductsQuery(
                          source: state.uri.queryParameters['source'],
                          categoryId: categoryId,
                          categoryName:
                              state.uri.queryParameters['categoryName'],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.orders,
                  pageBuilder: (_, state) => _buildPage(
                    state,
                    const OrdersPage(initialTab: OrdersTab.buyer),
                  ),
                  routes: [
                    GoRoute(
                      path: 'sales',
                      pageBuilder: (_, state) => _buildPage(
                        state,
                        const OrdersPage(initialTab: OrdersTab.sales),
                      ),
                    ),
                    GoRoute(
                      path: ':orderId',
                      pageBuilder: (_, state) {
                        final orderId = int.tryParse(
                          state.pathParameters['orderId'] ?? '',
                        );
                        if (orderId == null) {
                          return _buildPage(
                            state,
                            const RouteStubPage(title: 'Invalid order'),
                          );
                        }
                        return _buildPage(
                          state,
                          OrderDetailsPage(orderId: orderId),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.wallet,
                  pageBuilder: (_, state) =>
                      _buildPage(state, const WalletPage()),
                  routes: [
                    GoRoute(
                      path: 'transactions',
                      pageBuilder: (_, state) =>
                          _buildPage(state, const WalletTransactionsPage()),
                    ),
                    GoRoute(
                      path: 'recharge-requests',
                      pageBuilder: (_, state) =>
                          _buildPage(state, const RechargeRequestsPage()),
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.profile,
                  pageBuilder: (_, state) =>
                      _buildPage(state, const ProfilePage()),
                  routes: [
                    GoRoute(
                      path: 'edit',
                      pageBuilder: (_, state) =>
                          _buildPage(state, const ProfileEditPage()),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '${AppRoutes.products}/:productId',
          pageBuilder: (_, state) {
            final productId = int.tryParse(
              state.pathParameters['productId'] ?? '',
            );
            if (productId == null) {
              return _buildPage(
                state,
                const RouteStubPage(title: 'Invalid product'),
              );
            }

            return _buildPage(
              state,
              ProductDetailsPage(
                productId: productId,
                heroTag: state.uri.queryParameters['heroTag'],
              ),
            );
          },
        ),
        GoRoute(
          path: AppRoutes.notifications,
          pageBuilder: (_, state) =>
              _buildPage(state, const NotificationsPage()),
        ),
        GoRoute(
          path: AppRoutes.sellerDashboard,
          pageBuilder: (_, state) =>
              _buildPage(state, const SellerDashboardPage()),
        ),
        GoRoute(
          path: AppRoutes.sellerListings,
          pageBuilder: (_, state) =>
              _buildPage(state, const SellerListingsPage()),
          routes: [
            GoRoute(
              path: 'create',
              pageBuilder: (_, state) =>
                  _buildPage(state, const ListingFormPage.create()),
            ),
            GoRoute(
              path: ':productId/edit',
              pageBuilder: (_, state) {
                final product = state.extra;
                if (product is! Product) {
                  return _buildPage(
                    state,
                    const RouteStubPage(title: 'Listing unavailable'),
                  );
                }
                return _buildPage(
                  state,
                  ListingFormPage.edit(product: product),
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.deviceRequests,
          pageBuilder: (_, state) =>
              _buildPage(state, const DeviceRequestsPage()),
          routes: [
            GoRoute(
              path: 'create',
              pageBuilder: (_, state) =>
                  _buildPage(state, const CreateDeviceRequestPage()),
            ),
          ],
        ),
      ],
      redirect: (_, state) {
        final authState = authRouterNotifier.state;
        final isAuthenticated = authState.isAuthenticated;
        final path = state.matchedLocation;
        final isAuthRoute =
            path == AppRoutes.login || path == AppRoutes.register;
        final isProductsDetailRoute = path.startsWith('${AppRoutes.products}/');
        final isPublicRoute =
            path == AppRoutes.splash ||
            path == AppRoutes.home ||
            path == AppRoutes.products ||
            path == AppRoutes.login ||
            path == AppRoutes.register ||
            isProductsDetailRoute;
        final requestedLocation = state.uri.toString();

        if (authState.isRestoring && path != AppRoutes.splash) {
          return AppRoutes.splash;
        }

        if (!isAuthenticated && !isPublicRoute) {
          final from = Uri.encodeComponent(requestedLocation);
          return '${AppRoutes.login}?from=$from';
        }

        if (isAuthenticated && (path == AppRoutes.splash || isAuthRoute)) {
          final from = state.uri.queryParameters['from'];
          if (from != null && from.isNotEmpty) {
            return Uri.decodeComponent(from);
          }

          return AppRoutes.home;
        }

        if (authState.isUnauthenticated && path == AppRoutes.splash) {
          return AppRoutes.home;
        }

        return null;
      },
    );
  }

  static CustomTransitionPage<void> _buildPage(
    GoRouterState state,
    Widget child,
  ) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 260),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final fade = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        final slide = Tween<Offset>(
          begin: const Offset(0, 0.03),
          end: Offset.zero,
        ).animate(fade);

        return FadeTransition(
          opacity: fade,
          child: SlideTransition(position: slide, child: child),
        );
      },
    );
  }
}
