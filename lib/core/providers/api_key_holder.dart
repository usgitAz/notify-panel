/// Holds the current API key in memory.
///
/// Bridges [AuthInterceptor] and the auth feature without creating a
/// circular dependency between Dio and the auth notifier.
///
/// The auth flow is responsible for writing/clearing this value; the
/// interceptor only reads.
class ApiKeyHolder {
  String? _value;

  /// Invoked when a 401 is detected. Set by AuthNotifier.
  void Function()? onUnauthorized;

  String? get value => _value;

  void set(String? key) => _value = key;

  /// Clears without notifying (used on explicit logout).
  void clear() => _value = null;

  /// Clears and notifies (used by AuthInterceptor on 401).
  void notifyUnauthorized() {
    _value = null;
    onUnauthorized?.call();
  }
}
