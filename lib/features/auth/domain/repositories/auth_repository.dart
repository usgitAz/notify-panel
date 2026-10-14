import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/session.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, Session>> login(String apiKey);
  Future<Either<Failure, Unit>> logout();
  Future<Either<Failure, Session?>> restore();
}
