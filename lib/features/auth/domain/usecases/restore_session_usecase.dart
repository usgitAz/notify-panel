import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/session.dart';
import '../repositories/auth_repository.dart';

class RestoreSessionUseCase implements UseCase<Session?, NoParams> {
  RestoreSessionUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, Session?>> call(NoParams params) =>
      _repository.restore();
}
