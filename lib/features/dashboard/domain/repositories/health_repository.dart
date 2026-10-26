import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/health_status.dart';

abstract interface class HealthRepository {
  Future<Either<Failure, HealthProbe>> checkLiveness();
  Future<Either<Failure, HealthProbe>> checkReadiness();
}
