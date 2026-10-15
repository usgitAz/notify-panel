import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/providers/auth_state.dart';
import '../../shared/widgets/confirm_dialog.dart';
import '../router/app_routes.dart';

class AppShell extends ConsumerWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.path;
    final index = _indexFor(location);
    final auth = ref.watch(authNotifierProvider);
    final tenantName = switch (auth) {
      AuthAuthenticated(:final session) => session.tenant.name,
      _ => '',
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(tenantName.isEmpty ? 'Notify Panel' : tenantName),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: () => _confirmLogout(context, ref),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: index,
            onDestinationSelected: (i) => context.go(_destinations[i].path),
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people_outline),
                selectedIcon: Icon(Icons.people),
                label: Text('Users'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.notifications_outlined),
                selectedIcon: Icon(Icons.notifications),
                label: Text('Notifications'),
              ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Sign out',
      message: 'You will need to sign in again with your API key.',
      confirmLabel: 'Sign out',
      destructive: true,
    );
    if (confirmed) {
      await ref.read(authNotifierProvider.notifier).logout();
    }
  }

  static const _destinations = [
    _Dest(AppRoutes.dashboard),
    _Dest(AppRoutes.users),
    _Dest(AppRoutes.notifications),
  ];

  int _indexFor(String location) {
    if (location.startsWith(AppRoutes.users)) return 1;
    if (location.startsWith(AppRoutes.notifications)) return 2;
    return 0;
  }
}

class _Dest {
  const _Dest(this.path);
  final String path;
}
