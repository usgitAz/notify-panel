import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../users/domain/usecases/list_users_usecase.dart';
import '../../../users/presentation/providers/user_providers.dart';
import '../../data/datasources/health_remote_datasource.dart';
import '../../data/repositories/health_repository_impl.dart';
import '../../domain/entities/health_status.dart';
import '../../domain/repositories/health_repository.dart';
import '../../domain/usecases/check_health_usecase.dart';

// ─── DI ───

final healthRemoteDataSourceProvider = Provider<HealthRemoteDataSource>(
  (ref) => HealthRemoteDataSource(ref.watch(dioProvider)),
);

final healthRepositoryProvider = Provider<HealthRepository>(
  (ref) =>
      HealthRepositoryImpl(remote: ref.watch(healthRemoteDataSourceProvider)),
);

final checkHealthUseCaseProvider = Provider<CheckHealthUseCase>(
  (ref) => CheckHealthUseCase(ref.watch(healthRepositoryProvider)),
);

// ─── Health with 30s polling ───

class HealthNotifier extends AsyncNotifier<HealthStatus> {
  Timer? _timer;

  @override
  Future<HealthStatus> build() async {
    ref.onDispose(() => _timer?.cancel());
    _startPolling();
    return _check();
  }

  Future<HealthStatus> _check() async {
    final result = await ref
        .read(checkHealthUseCaseProvider)
        .call(const NoParams());
    // Use case always returns Right.
    return result.getRight().toNullable()!;
  }

  void _startPolling() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) async {
      try {
        final fresh = await _check();
        state = AsyncValue.data(fresh);
      } catch (e, st) {
        state = AsyncValue.error(e, st);
      }
    });
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_check);
  }
}

final healthProvider =
    AsyncNotifierProvider.autoDispose<HealthNotifier, HealthStatus>(
      HealthNotifier.new,
    );

// ─── User count (for the getting-started hint) ───

/// Returns the total number of users, or null when the call fails.
/// Only `0` triggers the getting-started card on the dashboard.
final userCountProvider = FutureProvider.autoDispose<int?>((ref) async {
  final result = await ref
      .watch(listUsersUseCaseProvider)
      .call(const ListUsersParams(limit: 1, offset: 0));
  return result.fold((_) => null, (page) => page.total);
});
