import 'package:flutter/material.dart';
import 'package:flutter_sample_apps/auth/auth_service.dart';
import 'package:flutter_sample_apps/pages/login_page.dart';
import 'package:flutter_sample_apps/pages/register_page.dart';
import 'package:flutter_sample_apps/router/home_router/home_router.dart';
import 'package:flutter_sample_apps/router/navigator_observer.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

GoRouter? _router;

GoRouter get appRouter =>
    _router ??= GoRouter(
      observers: [NavigatorObserverImpl('AppRouter')],
      redirect: (context, state) {
        final authService = context.read<AuthService>();

        if (!authService.isLoggedIn) {
          return '/login';
        }

        return null;
      },
      initialLocation:
      WidgetsBinding.instance.platformDispatcher.defaultRouteName,
      routes: [
        GoRoute(path: '/', redirect: (context, state) => '/home'),
        ...homeRoutes,
        GoRoute(
          name: 'login',
          path: '/login',
          builder: (context, state) => const LoginPage(),
          redirect: (context, state) {
            final authService = context.read<AuthService>();

            if (authService.isLoggedIn) {
              return '/home';
            }

            return null;
          },
        ),
        GoRoute(
          name: 'register',
          path: '/register',
          builder: (context, state) => const RegisterPage(),
          redirect: (context, state) {
            final authService = context.read<AuthService>();

            if (authService.isLoggedIn) {
              return '/home';
            }

            return null;
          },
        ),
      ],
    );