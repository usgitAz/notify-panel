import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/health_status.dart';
import '../../domain/repositories/health_repository.dart';
import '../datasources/health_remote_datasource.dart';

class HealthRepositoryImpl implements HealthRepository {
  HealthRepositoryImpl({required this._remote});

  final HealthRemoteDataSource _remote;

  @override
  Future<Either<Failure, HealthProbe>> checkLiveness() =>
      _remote.checkLiveness();

  @override
  Future<Either<Failure, HealthProbe>> checkReadiness() =>
      _remote.checkReadiness();
}