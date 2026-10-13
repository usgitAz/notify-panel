import 'package:fpdart/fpdart.dart';

import '../error/failure.dart';

/// Base contract for all use cases.
///
/// [T] is the success value type, [P] is the input parameter type.
/// Use [NoParams] when a use case takes no input.
abstract interface class UseCase<T, P> {
  Future<Either<Failure, T>> call(P params);
}

/// Marker type for use cases that require no input.
final class NoParams {
  const NoParams();
}
