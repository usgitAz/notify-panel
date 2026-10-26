import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_providers.dart';
import 'auth_state.dart';

/// ID of the active tenant, or `null` when unauthenticated.
///
/// Feature providers (users, devices, notifications, dashboard) watch
/// this so their state is automatically invalidated whenever the session
/// changes — login, logout, or tenant switch.=-0987675645321`  qwertyuiop[]\///
/// Why a derived provider instead of manual invalidation:
/// - Zero boilerplate at the auth layer
/// - Impossible to forget adding a new feature
/// - Riverpod handles rebuild ordering
final tenantScopeProvider = Provider<String?>((ref) {
  final auth = ref.watch(authNotifierProvider);
  return switch (auth) {
    AuthAuthenticated(:final session) => session.tenant.id,
    _ => null,
  };
});
