/// Paths are relative to [Env.apiBaseUrl] (which already includes
/// `/api/v1`), except health endpoints which are relative to
/// [Env.healthBaseUrl].
abstract final class ApiEndpoints {
  const ApiEndpoints._();

  // ─── Health (outside /api/v1) ───
  static const String health = '/health';
  static const String healthReady = '/health/ready';

  // ─── Users ───
  static const String users = '/users';
  static String user(String externalId) =>
      '/users/${Uri.encodeComponent(externalId)}';

  // ─── Devices ───
  static String registerDevice(String externalId) =>
      '/users/${Uri.encodeComponent(externalId)}/device/register';
  static String userDevices(String externalId) =>
      '/users/${Uri.encodeComponent(externalId)}/devices';
  static String device(String deviceId) =>
      '/devices/${Uri.encodeComponent(deviceId)}';

  // ─── Notifications ───
  static const String notifications = '/notifications/';
  static const String sendEmail = '/notifications/email';
  static String notification(String id) =>
      '/notifications/${Uri.encodeComponent(id)}';
}
