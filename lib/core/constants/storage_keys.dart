/// Keys used across storage layers.
///
/// Kept in one place so we never lose track of what's written where.
abstract final class StorageKeys {
  // Secure storage
  static const String apiKey = 'auth.api_key';
  static const String tenant = 'auth.tenant';

  // Preferences
  static const String themeMode = 'prefs.theme_mode';
  static const String lastLoginEmail = 'prefs.last_login_email';
}
