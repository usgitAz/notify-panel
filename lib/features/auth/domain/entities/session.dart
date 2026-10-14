import 'package:meta/meta.dart';

import 'tenant.dart';

/// Authenticated session: the API key plus the tenant it belongs to.
@immutable
final class Session {
  const Session({required this.apiKey, required this.tenant});

  final String apiKey;
  final Tenant tenant;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Session && other.apiKey == apiKey && other.tenant == tenant;

  @override
  int get hashCode => Object.hash(apiKey, tenant);

  @override
  String toString() => 'Session(apiKey: ***, tenant: ${tenant.name})';
}
