/// Holds the current API key in memory.
///
/// Bridges [AuthInterceptor] and the auth feature without creating a
/// circular dependency between Dio and the auth notifier.
///
/// The auth flow is responsible for writing/clearing this value; the
/// interceptor only reads.
class ApiKeyHolder {
  String? _value;

  String? get value => _value;

  void set(String? key) => _value = key;

  void clear() => _value = null;
}
