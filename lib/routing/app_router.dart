import 'package:flutter/material.dart';
import 'package:flutter_sample_apps/features/notes/detail_screen.dart';
import 'package:flutter_sample_apps/features/notes/favorites_screen.dart';
import 'package:flutter_sample_apps/features/notes/notes_screen.dart' show NotesScreen;
import 'package:flutter_sample_apps/features/profile/profile_screen.dart';
import 'package:flutter_sample_apps/features/root/root_screen.dart';
import 'package:go_router/go_router.dart';

final router = GoRouter(
  initialLocation: '/notes',
  routes: [
    // BottomNavigationBar
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          RootScreen(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
                path: '/notes',
                builder: (context, state) => const NotesScreen(),
                routes: [
                  GoRoute(
                    path: 'detail/:index',
                    builder: (context, state) {
                      final index = int.parse(state.pathParameters['index']!);
                      return DetailScreen(index: index);
                    },
                  ),
                ]),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/favorites',
              builder: (context, state) => const FavoritesScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
  errorPageBuilder: (context, state) {
    return MaterialPage(
      key: state.pageKey,
      child: Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Text(
            state.error.toString(),
            style: const TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  },
);