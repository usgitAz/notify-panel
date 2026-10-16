import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_datasource.dart';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl({required this._remote});

  final UserRemoteDataSource _remote;

  @override
  Future<Either<Failure, User>> getByExternalId(String externalId) =>
      _remote.getByExternalId(externalId);

  @override
  Future<Either<Failure, User>> create({
    required String externalId,
    String? email,
  }) => _remote.create(externalId: externalId, email: email);

  @override
  Future<Either<Failure, User>> update(
    String externalId, {
    String? email,
    bool? isActive,
  }) => _remote.update(externalId, email: email, isActive: isActive);
}
