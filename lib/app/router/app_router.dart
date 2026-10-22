import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/providers/auth_state.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/devices/presentation/pages/register_device_page.dart';
import '../../features/notifications/presentation/pages/notification_list_page.dart';
import '../../features/users/presentation/pages/create_user_page.dart';
import '../../features/users/presentation/pages/user_detail_page.dart';
import '../../features/users/presentation/pages/users_list_page.dart';
import '../shell/app_shell.dart';
import 'app_routes.dart';

/// Provides the app's [GoRouter], wired to the auth state for redirects.
final routerProvider = Provider<GoRouter>((ref) {
  // Bridges Riverpod's auth state changes to a Listenable that
  // GoRouter can observe to re-evaluate `redirect`.
  final refresh = ValueNotifier<int>(0);
  ref.listen(authNotifierProvider, (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: AppRoutes.dashboard,
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authNotifierProvider);
      final isOnLogin = state.matchedLocation == AppRoutes.login;

      return switch (auth) {
        AuthUnknown() => null,
        AuthAuthenticated() => isOnLogin ? AppRoutes.dashboard : null,
        AuthUnauthenticated() => isOnLogin ? null : AppRoutes.login,
      };
    },
    routes: [
      GoRoute(path: AppRoutes.login, builder: (_, _) => const LoginPage()),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            builder: (_, _) => const DashboardPage(),
          ),
          GoRoute(
            path: AppRoutes.users,
            builder: (_, _) => const UsersListPage(),
            routes: [
              GoRoute(
                path: AppRoutes.userCreate,
                builder: (context, state) {
                  final externalId = state.uri.queryParameters['externalId'];
                  return CreateUserPage(prefillExternalId: externalId);
                },
              ),
              GoRoute(
                path: AppRoutes.userDetail,
                builder: (context, state) => UserDetailPage(
                  externalId: state.pathParameters['externalId']!,
                ),
                routes: [
                  GoRoute(
                    path: AppRoutes.deviceRegister,
                    builder: (context, state) => RegisterDevicePage(
                      externalId: state.pathParameters['externalId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.notifications,
            builder: (_, _) => const NotificationListPage(),
          ),
        ],
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
});
