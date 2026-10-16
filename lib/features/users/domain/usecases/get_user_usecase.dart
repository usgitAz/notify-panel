import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';

class GetUserUseCase implements UseCase<User, String> {
  GetUserUseCase(this._repository);

  final UserRepository _repository;

  @override
  Future<Either<Failure, User>> call(String externalId) =>
      _repository.getByExternalId(externalId);
}