import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/providers/api_key_holder.dart';
import '../../domain/entities/session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required this._remote,
    required this._local,
    required this._holder,
  });

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;
  final ApiKeyHolder _holder;

  @override
  Future<Either<Failure, Session>> login(String apiKey) async {
    final tenantResult = await _remote.fetchCurrentTenant(apiKey);
    if (tenantResult.isLeft()) {
      return Left(tenantResult.getLeft().toNullable()!);
    }

    final session = Session(
      apiKey: apiKey,
      tenant: tenantResult.getRight().toNullable()!,
    );
    await _local.save(session);
    _holder.set(apiKey);
    return Right(session);
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    await _local.clear();
    _holder.clear();
    return const Right(unit);
  }

  @override
  Future<Either<Failure, Session?>> restore() async {
    final session = await _local.read();
    if (session != null) _holder.set(session.apiKey);
    return Right(session);
  }
}
