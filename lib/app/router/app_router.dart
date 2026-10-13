import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/notifications/presentation/pages/notification_list_page.dart';
import '../../features/users/presentation/pages/user_lookup_page.dart';
import '../shell/app_shell.dart';
import 'app_routes.dart';

/// Router configuration.
abstract final class AppRouter {
  static GoRouter create() {
    return GoRouter(
      initialLocation: AppRoutes.dashboard,
      routes: [
        // ─── Shell ───
        ShellRoute(
          builder: (context, state, child) => AppShell(child: child),
          routes: [
            GoRoute(
              path: AppRoutes.dashboard,
              builder: (_, _) => const DashboardPage(),
            ),
            GoRoute(
              path: AppRoutes.users,
              builder: (_, _) => const UserLookupPage(),
            ),
            GoRoute(
              path: AppRoutes.notifications,
              builder: (_, _) => const NotificationListPage(),
            ),
          ],
        ),
        // ─── Error ───
        GoRoute(
          path: '/error',
          builder: (_, _) =>
              const Scaffold(body: Center(child: Text('Something went wrong'))),
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Page not found'),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => context.go(AppRoutes.dashboard),
                child: const Text('Go home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
