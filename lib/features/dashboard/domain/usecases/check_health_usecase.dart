import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/failure_messages.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/health_status.dart';
import '../repositories/health_repository.dart';

/// Runs both probes in parallel and returns a combined snapshot.
///
/// Never returns [Left] — per-probe failures are embedded in the
/// [HealthProbe]'s `error` field so the UI can show partial outages
/// (e.g., liveness ok but readiness down).
class CheckHealthUseCase implements UseCase<HealthStatus, NoParams> {
  CheckHealthUseCase(this._repository);

  final HealthRepository _repository;

  @override
  Future<Either<Failure, HealthStatus>> call(NoParams params) async {
    final results = await Future.wait([
      _repository.checkLiveness(),
      _repository.checkReadiness(),
    ]);

    HealthProbe probe(Either<Failure, HealthProbe> either) => either.fold(
      (f) => HealthProbe(ok: false, error: FailureMessages.of(f)),
      (p) => p,
    );

    return Right(
      HealthStatus(
        liveness: probe(results[0]),
        readiness: probe(results[1]),
        checkedAt: DateTime.now(),
      ),
    );
  }
}
