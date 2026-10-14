import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class LogoutUseCase implements UseCase<Unit, NoParams> {
  LogoutUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(NoParams params) => _repository.logout();
}
