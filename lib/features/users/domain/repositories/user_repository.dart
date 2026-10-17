import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/network/page.dart';
import '../entities/user.dart';

abstract interface class UserRepository {
  Future<Either<Failure, Page<User>>> list({
    bool? isActive,
    int limit = 20,
    int offset = 0,
  });

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
