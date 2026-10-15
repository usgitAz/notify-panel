import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/session.dart';
import 'auth_state.dart';
import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/restore_session_usecase.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>(
  (ref) => AuthRemoteDataSource(ref.watch(dioProvider)),
);

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>(
  (ref) => AuthLocalDataSource(ref.watch(secureStorageProvider)),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    remote: ref.watch(authRemoteDataSourceProvider),
    local: ref.watch(authLocalDataSourceProvider),
    holder: ref.watch(apiKeyHolderProvider),
  ),
);

final loginUseCaseProvider = Provider<LoginUseCase>(
  (ref) => LoginUseCase(ref.watch(authRepositoryProvider)),
);

final logoutUseCaseProvider = Provider<LogoutUseCase>(
  (ref) => LogoutUseCase(ref.watch(authRepositoryProvider)),
);

final restoreSessionUseCaseProvider = Provider<RestoreSessionUseCase>(
  (ref) => RestoreSessionUseCase(ref.watch(authRepositoryProvider)),
);

// Initial session (overridden in main)

final initialSessionProvider = Provider<Session?>(
  (ref) => throw UnimplementedError(
    'initialSessionProvider must be overridden in main()',
  ),
);

// Auth state notifier

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    final holder = ref.watch(apiKeyHolderProvider);
    holder.onUnauthorized = _handleUnauthorized;
    ref.onDispose(() => holder.onUnauthorized = null);

    final session = ref.watch(initialSessionProvider);
    return session != null
        ? AuthAuthenticated(session)
        : const AuthUnauthenticated();
  }

  /// Attempts to sign in with [apiKey]. On success the state becomes
  /// [AuthAuthenticated]; on failure the state is unchanged and the
  /// failure is returned to the caller for display.
  Future<Either<Failure, Unit>> login(String apiKey) async {
    final result = await ref.read(loginUseCaseProvider).call(apiKey);
    return result.match((failure) => Left(failure), (session) {
      state = AuthAuthenticated(session);
      return const Right(unit);
    });
  }

  Future<void> logout() async {
    await ref.read(logoutUseCaseProvider).call(const NoParams());
    state = const AuthUnauthenticated();
  }

  void _handleUnauthorized() {
    // Triggered by AuthInterceptor on 401 (e.g., expired key).
    state = const AuthUnauthenticated();
  }
}

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
