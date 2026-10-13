import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/app_routes.dart';

/// Layout wrapper for all authenticated routes.
///
/// Renders a [NavigationRail] on the left and the active route in the
/// content area via [GoRouterState]'s matched location.
class AppShell extends StatelessWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final index = _indexFor(location);

    return Scaffold(
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
