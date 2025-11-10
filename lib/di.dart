import 'package:flutter/material.dart';
import 'package:flutter_sample_apps/auth/auth_service.dart';
import 'package:flutter_sample_apps/router/app_router/app_router.dart';
import 'package:flutter_sample_apps/router/app_router_refresher.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DI extends StatelessWidget {
  final Widget child;
  final SharedPreferences sharedPreferences;
  const DI({super.key, required this.child, required this.sharedPreferences});

  @override
  Widget build(BuildContext context) => MultiProvider(
    providers: [
      Provider<AuthService>(
        create: (context) => AuthService(sharedPreferences),
      ),
      Provider<GoRouter>(create: (context) => appRouter),
    ],
    child: MultiProvider(
      providers: [
        Provider(
          create:
              (context) => AppRouterRefresher(
            authService: context.read(),
            appRouter: context.read(),
          )..init(),
        ),
      ],
      child: child,
    ),
  );
}