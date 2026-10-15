import 'package:meta/meta.dart';

import '../../domain/entities/session.dart';

/// Authentication state of the app.
sealed class AuthState {
  const AuthState();
}

/// Transient state while restoring a session.
/// In practice, [initialSessionProvider] resolves at boot, so this is
/// rarely observed.
final class AuthUnknown extends AuthState {
  const AuthUnknown();
}

/// No valid session. The user must sign in.
final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// An active session.
@immutable
final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.session);

  final Session session;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthAuthenticated && other.session == session;

  @override
  int get hashCode => session.hashCode;
}
