import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/session.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase implements UseCase<Session, String> {
  LoginUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, Session>> call(String apiKey) =>
      _repository.login(apiKey);
}
