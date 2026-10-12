import 'failure.dart';

/// Backend codes are stable; backend messages are not. This class is
/// the single place where we branch on [Failure.code] to produce
/// context-aware copy. Every unknown code falls through to a
/// generic message for its failure category.
abstract final class FailureMessages {
  static String of(Failure failure) => switch (failure) {
    AuthFailure() =>
      'Your API key is invalid or has expired. Please sign in again.',
    NotFoundFailure(:final code) => _notFound(code),
    ConflictFailure(:final code) => _conflict(code),
    ValidationFailure(:final code) => _validation(code),
    RateLimitFailure(:final retryAfter) =>
      retryAfter == null
          ? 'Too many requests. Please try again shortly.'
          : 'Too many requests. Try again in ${retryAfter.inSeconds}s.',
    ExternalServiceFailure(:final service) =>
      service == null
          ? 'A downstream service is unavailable. Please try again.'
          : 'The $service service is unavailable. Please try again.',
    ServerFailure() => 'Something went wrong on our side. Please try again.',
    NetworkFailure() => 'Network error. Check your connection and try again.',
    ParseFailure() => 'We received an unexpected response. Please try again.',
    UnknownFailure() => 'An unexpected error occurred.',
  };

  // ─── Category-specific helpers ───

  static String _notFound(String? code) => switch (code) {
    'USER_NOT_FOUND' => 'User not found.',
    'DEVICE_NOT_FOUND' => 'Device not found.',
    'NOTIFICATION_NOT_FOUND' => 'Notification not found.',
    _ => 'The requested resource was not found.',
  };

  static String _conflict(String? code) => switch (code) {
    'USER_ALREADY_EXISTS' => 'A user with this external ID already exists.',
    'USER_EXISTS_INACTIVE' =>
      'This user exists but is deactivated. Reactivate it to proceed.',
    'DEVICE_TOKEN_TAKEN' =>
      'This device token is already registered to another user.',
    'DEVICE_ALREADY_REGISTERED' =>
      'This device is already registered and active for this user.',
    _ => 'This action conflicts with an existing resource.',
  };

  static String _validation(String? code) => switch (code) {
    'USER_HAS_NO_EMAIL' =>
      'This user has no email address. Add one before sending email.',
    _ => 'Some fields are invalid. Please review and try again.',
  };

  // ─── Field-level helpers ───

  /// First error message for a leaf field (e.g., `external_id`),
  /// or an empty string when there is none.
  static String field(ValidationFailure failure, String leaf) =>
      failure.firstMessageForLeaf(leaf) ?? '';
}
