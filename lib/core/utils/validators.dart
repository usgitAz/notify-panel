/// Reusable form validators.
///
/// Each returns `null` when valid, or a error message.
abstract final class Validators {
  const Validators._();

  static String? required(String? value, {String field = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$field is required.';
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!regex.hasMatch(value.trim())) return 'Enter a valid email address.';
    return null;
  }

  static String? apiKey(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'API key is required.';
    }
    // Format: sk_<env>_<opaque> where opaque may contain [A-Za-z0-9_-].
    final regex = RegExp(r'^sk_[a-z]{2,8}_[A-Za-z0-9_\-]{16,}$');
    if (!regex.hasMatch(value.trim())) {
      return 'API key format looks invalid.';
    }
    return null;
  }

  static String? maxLength(String? value, int max, {String field = 'This'}) {
    if (value != null && value.length > max) {
      return '$field must be at most $max characters.';
    }
    return null;
  }
}
