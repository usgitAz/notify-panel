/// Build-time configuration.
///
/// Override values via `--dart-define`:
/// flutter run -d chrome \
///   --dart-define=API_BASE_URL=http://localhost:8000/api/v1
class Env {
  const Env._();

  /// Base URL of the API, including the `/api/v1` suffix.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000/api/v1',
  );

  /// Base URL of the service root (without `/api/v1`).
  /// Used for `/health` and `/health/ready`.
  static String get healthBaseUrl {
    final uri = Uri.parse(apiBaseUrl);
    final stripped = uri.path.replaceFirst(RegExp(r'/api/v1/?$'), '');
    return uri.replace(path: stripped).toString();
  }

  /// `true` only in release builds.
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');

  // ─── Timeouts ───
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // ─── Notification polling ───
  static const Duration notificationPollingInterval = Duration(seconds: 5);
  static const Duration notificationPollingMaxDuration = Duration(seconds: 60);

  // ─── Pagination ───
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
}
