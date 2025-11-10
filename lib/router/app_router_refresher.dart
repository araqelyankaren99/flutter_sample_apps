import 'package:flutter_sample_apps/auth/auth_service.dart';
import 'package:go_router/go_router.dart';

class AppRouterRefresher {
  final AuthService _authService;
  final GoRouter _appRouter;

  AppRouterRefresher({
    required AuthService authService,
    required GoRouter appRouter,
  }) : _authService = authService,
        _appRouter = appRouter;

  void init() {
    _authService.addListener(() {
      print('refresh');
      _appRouter.refresh();
    });
  }
}