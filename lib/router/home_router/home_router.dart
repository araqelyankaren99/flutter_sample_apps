import 'package:flutter/material.dart';
import 'package:flutter_sample_apps/auth/auth_service.dart';
import 'package:flutter_sample_apps/pages/cart/cart_page.dart';
import 'package:flutter_sample_apps/pages/profile/orders_page.dart';
import 'package:flutter_sample_apps/pages/profile/profile_page.dart';
import 'package:flutter_sample_apps/pages/profile/settings_page.dart';
import 'package:flutter_sample_apps/pages/shop/feedbacks_item_page.dart';
import 'package:flutter_sample_apps/pages/shop/item_page.dart';
import 'package:flutter_sample_apps/pages/shop/shop_page.dart';
import 'package:flutter_sample_apps/router/dialog_page.dart';
import 'package:flutter_sample_apps/router/navigator_observer.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

enum HomeTab {
  shop,
  cart,
  profile;

  factory HomeTab.byIndex(int index) => values[index];
}

class HomeTabsPage extends StatelessWidget {
  final HomeTab tab;
  final Widget child;
  final ValueChanged<HomeTab> onTap;

  const HomeTabsPage({
    super.key,
    required this.tab,
    required this.child,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    body: child,
    bottomNavigationBar: BottomNavigationBar(
      currentIndex: tab.index,
      onTap: (index) => onTap(HomeTab.byIndex(index)),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.shop), label: 'Магазин'),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'Корзина',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
      ],
    ),
  );
}

final homeRoutes = [
  GoRoute(path: '/home', redirect: (context, state) => '/home/shop'),
  StatefulShellRoute.indexedStack(
    redirect: (context, state) {
      final authService = context.read<AuthService>();

      if (!authService.isLoggedIn) {
        return '/login';
      }

      if (state.uri.toString() == '/home') {
        return '/heom/shop';
      }

      return null;
    },
    builder: (context, state, shell) {
      return HomeTabsPage(
        tab: HomeTab.byIndex(shell.currentIndex),
        child: shell,
        onTap: (value) => shell.goBranch(value.index),
      );
    },
    branches: [
      StatefulShellBranch(
        observers: [NavigatorObserverImpl('ShopBranch')],
        routes: [
          GoRoute(
            name: 'shop',
            path: '/home/shop',
            builder: (context, state) => const ShopPage(),
            routes: [
              GoRoute(
                name: 'shop_item',
                path: 'item/:item_id',
                builder: (context, state) {
                  final itemId = int.parse(state.pathParameters['item_id']!);

                  return ItemPage(itemId: itemId, prefix: 'shop');
                },
                routes: [
                  GoRoute(
                    name: 'shop_feedback',
                    path: 'feedback',
                    builder: (context, state) {
                      final itemId = int.parse(
                        state.pathParameters['item_id']!,
                      );

                      return FeedbacksItemPage(itemId: itemId);
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      StatefulShellBranch(
        observers: [NavigatorObserverImpl('CartBranch')],
        routes: [
          GoRoute(
            name: 'cart',
            path: '/home/cart',
            builder: (context, state) => const CartPage(),
            routes: [
              GoRoute(
                name: 'cart_item',
                path: 'item/:item_id',
                builder: (context, state) {
                  final itemId = int.parse(state.pathParameters['item_id']!);

                  return ItemPage(itemId: itemId, prefix: 'cart');
                },
                routes: [
                  GoRoute(
                    name: 'cart_feedback',
                    path: 'feedback',
                    builder: (context, state) {
                      final itemId = int.parse(
                        state.pathParameters['item_id']!,
                      );

                      return FeedbacksItemPage(itemId: itemId);
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      StatefulShellBranch(
        observers: [NavigatorObserverImpl('ProfileBranch')],
        routes: [
          GoRoute(
            name: 'profile',
            path: '/home/profile',
            builder: (context, state) => const ProfilePage(),
            routes: [
              GoRoute(
                name: 'orders',
                path: 'orders',
                builder: (context, state) => const OrdersPage(),
              ),
              GoRoute(
                name: 'settings',
                path: 'settings',
                builder: (context, state) => const SettingsPage(),
                routes: [
                  GoRoute(
                    name: 'about',
                    path: 'about',
                    pageBuilder:
                        (context, state) =>
                    const DialogPage(child: SettingsAboutDialog()),
                  ),
                  GoRoute(
                    name: 'language',
                    path: 'language',
                    pageBuilder:
                        (context, state) =>
                    const DialogPage(child: SettingsLanguageDialog()),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  ),
];