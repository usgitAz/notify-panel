import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/user.dart';

abstract interface class UserRepository {
  Future<Either<Failure, User>> getByExternalId(String externalId);

  Future<Either<Failure, User>> create({
    required String externalId,
    String? email,
  });

  Future<Either<Failure, User>> update(
    String externalId, {
    String? email,
    bool? isActive,
  });
}
