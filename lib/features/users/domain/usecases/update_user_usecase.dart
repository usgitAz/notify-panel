import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';

final class UpdateUserParams {
  const UpdateUserParams({required this.externalId, this.email, this.isActive});

  final String externalId;
  final String? email;
  final bool? isActive;
}

class UpdateUserUseCase implements UseCase<User, UpdateUserParams> {
  UpdateUserUseCase(this._repository);

  final UserRepository _repository;

  @override
  Future<Either<Failure, User>> call(UpdateUserParams params) =>
      _repository.update(
        params.externalId,
        email: params.email,
        isActive: params.isActive,
      );
}
