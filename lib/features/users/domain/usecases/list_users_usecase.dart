import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/network/page.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';

final class ListUsersParams {
  const ListUsersParams({this.isActive, this.limit = 20, this.offset = 0});

  /// Omit to include both active and inactive users.
  final bool? isActive;
  final int limit;
  final int offset;
}

class ListUsersUseCase implements UseCase<Page<User>, ListUsersParams> {
  ListUsersUseCase(this._repository);

  final UserRepository _repository;

  @override
  Future<Either<Failure, Page<User>>> call(ListUsersParams params) =>
      _repository.list(
        isActive: params.isActive,
        limit: params.limit,
        offset: params.offset,
      );
}
