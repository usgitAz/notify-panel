import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';

final class CreateUserParams {
  const CreateUserParams({required this.externalId, this.email});

  final String externalId;
  final String? email;
}

class CreateUserUseCase implements UseCase<User, CreateUserParams> {
  CreateUserUseCase(this._repository);

  final UserRepository _repository;

  @override
  Future<Either<Failure, User>> call(CreateUserParams params) =>
      _repository.create(externalId: params.externalId, email: params.email);
}
