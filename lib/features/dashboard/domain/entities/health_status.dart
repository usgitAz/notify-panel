import 'package:meta/meta.dart';

/// Result of probing one health endpoint.
@immutable
final class HealthProbe {
  const HealthProbe({required this.ok, this.status, this.checks, this.error});

  /// True when the endpoint reported a healthy/ready state.
  final bool ok;

  /// Raw status string from the backend (`healthy`, `ready`, `not ready`).
  final String? status;

  /// Sub-checks (readiness only): e.g. `{database: "ok", redis: "ok"}`.
  final Map<String, String>? checks;

  /// Human-readable error when the probe could not reach the backend.
  final String? error;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthProbe &&
          other.ok == ok &&
          other.status == status &&
          other.error == error &&
          _mapEquals(other.checks, checks);

  @override
  int get hashCode => Object.hash(
    ok,
    status,
    error,
    checks == null
        ? null
        : Object.hashAllUnordered(
            checks!.entries.map((e) => Object.hash(e.key, e.value)),
          ),
  );

  static bool _mapEquals(Map<String, String>? a, Map<String, String>? b) {
    if (identical(a, b)) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (final e in a.entries) {
      if (b[e.key] != e.value) return false;
    }
    return true;
  }
}

/// Combined health snapshot for the dashboard.
@immutable
final class HealthStatus {
  const HealthStatus({
    required this.liveness,
    required this.readiness,
    required this.checkedAt,
  });

  final HealthProbe liveness;
  final HealthProbe readiness;
  final DateTime checkedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthStatus &&
          other.liveness == liveness &&
          other.readiness == readiness &&
          other.checkedAt == checkedAt;

  @override
  int get hashCode => Object.hash(liveness, readiness, checkedAt);
}
