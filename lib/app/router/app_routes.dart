abstract final class AppRoutes {
  const AppRoutes._();

  // ─── Public ───
  static const String login = '/login';

  // ─── Shell (authenticated) ───
  static const String dashboard = '/dashboard';
  static const String users = '/users';
  static const String notifications = '/notifications';

  // ─── Users sub-routes (relative for nested routing) ───
  static const String userCreate = 'create';
  static const String userDetail = ':externalId';
  static const String deviceRegister = 'devices/register';

  // ─── Notifications sub-routes ───
  static const String notificationCompose = 'compose';
  static const String notificationDetail = ':id';

  // ─── Full paths (for go/push by path) ───
  static String userCreatePath({String? externalId}) {
    final base = '$users/$userCreate';
    return externalId == null
        ? base
        : '$base?externalId=${Uri.encodeComponent(externalId)}';
  }

  static String userDetailPath(String externalId) =>
      '$users/${Uri.encodeComponent(externalId)}';

  static String deviceRegisterPath(String externalId) =>
      '$users/${Uri.encodeComponent(externalId)}/$deviceRegister';

  static String notificationDetailPath(String id) =>
      '$notifications/${Uri.encodeComponent(id)}';

  static String notificationComposePath({String? to}) {
    final base = '$notifications/$notificationCompose';
    return to == null ? base : '$base?to=${Uri.encodeComponent(to)}';
  }
}
