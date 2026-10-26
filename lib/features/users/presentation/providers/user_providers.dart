import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../auth/presentation/providers/auth_scope_provider.dart';
import '../../data/datasources/user_remote_datasource.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/usecases/create_user_usecase.dart';
import '../../domain/usecases/get_user_usecase.dart';
import '../../domain/usecases/list_users_usecase.dart';
import '../../domain/usecases/update_user_usecase.dart';

final createUserUseCaseProvider = Provider<CreateUserUseCase>(
  (ref) => CreateUserUseCase(ref.watch(userRepositoryProvider)),
);

// ─── Use cases ───

final getUserUseCaseProvider = Provider<GetUserUseCase>(
  (ref) => GetUserUseCase(ref.watch(userRepositoryProvider)),
);

final listUsersUseCaseProvider = Provider<ListUsersUseCase>(
  (ref) => ListUsersUseCase(ref.watch(userRepositoryProvider)),
);

final updateUserUseCaseProvider = Provider<UpdateUserUseCase>(
  (ref) => UpdateUserUseCase(ref.watch(userRepositoryProvider)),
);

final userDetailProvider =
    AsyncNotifierProvider.family<UserDetailNotifier, User, String>(
      UserDetailNotifier.new,
    );

// ─── Data sources ───

final userRemoteDataSourceProvider = Provider<UserRemoteDataSource>(
  (ref) => UserRemoteDataSource(ref.watch(dioProvider)),
);
// ─── Repository ───

final userRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepositoryImpl(remote: ref.watch(userRemoteDataSourceProvider)),
);

// ─── Detail (AsyncNotifier + constructor arg) ───

class UserDetailNotifier extends AsyncNotifier<User> {
  final String externalId;

  UserDetailNotifier(this.externalId);

  @override
  Future<User> build() async {
    final scope = ref.watch(tenantScopeProvider);
    if (scope == null) {
      throw const AuthFailure(message: 'No active session.');
    }

    final result = await ref.watch(getUserUseCaseProvider).call(externalId);
    return result.match((failure) => throw failure, (user) => user);
  }

  /// Toggle the user's active flag. On success the state is replaced
  /// in-place so the UI never flickers through a loading phase.
  Future<Either<Failure, User>> toggleActive() async {
    final current = state.value;
    if (current == null) {
      return const Left(UnknownFailure(message: 'User not loaded.'));
    }

    final result = await ref
        .read(updateUserUseCaseProvider)
        .call(
          UpdateUserParams(
            externalId: current.externalId,
            isActive: !current.isActive,
          ),
        );

    return result.match((failure) => Left(failure), (user) {
      state = AsyncValue.data(user);
      return Right(user);
    });
  }

  /// Update the user's email. An empty string clears it.
  Future<Either<Failure, User>> updateEmail(String email) async {
    final current = state.value;
    if (current == null) {
      return const Left(UnknownFailure(message: 'User not loaded.'));
    }

    final result = await ref
        .read(updateUserUseCaseProvider)
        .call(UpdateUserParams(externalId: current.externalId, email: email));

    return result.match((failure) => Left(failure), (user) {
      state = AsyncValue.data(user);
      return Right(user);
    });
  }
}
