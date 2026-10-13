/// Route names and paths used across the app.
abstract final class AppRoutes {
  const AppRoutes._();

  // ─── Public ───
  static const String login = '/login';

  // ─── Shell (authenticated) ───
  static const String dashboard = '/dashboard';
  static const String users = '/users';
  static const String notifications = '/notifications';

  // ─── Users sub-routes ───
  static const String userCreate = 'create';
  static const String userDetail = ':externalId';
  static const String userEdit = 'edit';
  static const String deviceRegister = 'devices/register';

  // ─── Notifications sub-routes ───
  static const String notificationCompose = 'compose';
  static const String notificationDetail = ':id';

  // ─── Full paths (for go/push by path) ───
  static String userDetailPath(String externalId) => '$users/$externalId';
  static String deviceRegisterPath(String externalId) =>
      '$users/$externalId/$deviceRegister';
  static String notificationDetailPath(String id) => '$notifications/$id';
}
