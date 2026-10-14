import 'package:flutter_riverpod/flutter_riverpod.dart';

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
