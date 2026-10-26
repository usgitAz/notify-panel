import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

import '../../../../core/network/page.dart';
import '../../../auth/presentation/providers/auth_scope_provider.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/list_users_usecase.dart';
import 'user_providers.dart';

final usersListProvider =
    AsyncNotifierProvider<UsersListNotifier, UsersListState>(
      UsersListNotifier.new,
    );

/// Filter options for the users list.
enum ActiveFilter { all, active, inactive }

class UsersListNotifier extends AsyncNotifier<UsersListState> {
  Future<void> applyFilter(ActiveFilter filter) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchWithFilter(filter));
  }

  @override
  Future<UsersListState> build() async {
    final scope = ref.watch(tenantScopeProvider);
    if (scope == null) {
      return const UsersListState(
        users: [],
        page: null,
        filter: ActiveFilter.all,
        limit: 20,
        isLoadingMore: false,
      );
    }
    return _fetch(offset: 0, reset: true);
  }

  Future<void> goToNextPage() async {
    final current = state.value;
    if (current == null || !current.hasNext) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final nextOffset =
          (current.page?.offset ?? 0) + (current.page?.limit ?? 20);
      return _fetchPage(offset: nextOffset, filter: current.filter);
    });
  }

  Future<void> goToPrevPage() async {
    final current = state.value;
    if (current == null || !current.hasPrev) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final prevOffset =
          ((current.page?.offset ?? 0) - (current.page?.limit ?? 20)).clamp(
            0,
            1 << 31,
          );
      return _fetchPage(offset: prevOffset, filter: current.filter);
    });
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasNext || current.isLoadingMore) return;

    state = AsyncValue.data(current.copyWith(isLoadingMore: true));

    final nextOffset =
        (current.page?.offset ?? 0) + (current.page?.limit ?? 20);
    final result = await ref
        .read(listUsersUseCaseProvider)
        .call(
          ListUsersParams(
            isActive: switch (current.filter) {
              ActiveFilter.all => null,
              ActiveFilter.active => true,
              ActiveFilter.inactive => false,
            },
            limit: current.limit,
            offset: nextOffset,
          ),
        );

    result.match(
      (failure) {
        state = AsyncValue.error(failure, StackTrace.current);
      },
      (nextPage) {
        state = AsyncValue.data(
          current.copyWith(
            users: [...current.users, ...nextPage.items],
            page: nextPage,
            isLoadingMore: false,
          ),
        );
      },
    );
  }

  Future<void> refresh() async {
    final current = state.value;
    if (current == null) return;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchWithFilter(current.filter));
  }

  Future<void> setLimit(int limit) async {
    final current = state.value;
    if (current == null || current.limit == limit) return;
    state = AsyncValue.data(current.copyWith(limit: limit));
    await refresh();
  }

  Future<UsersListState> _fetch({
    required int offset,
    required bool reset,
  }) async {
    final filter = reset
        ? ActiveFilter.all
        : state.value?.filter ?? ActiveFilter.all;
    final limit = state.value?.limit ?? 20;

    final isActive = switch (filter) {
      ActiveFilter.all => null,
      ActiveFilter.active => true,
      ActiveFilter.inactive => false,
    };

    final result = await ref
        .read(listUsersUseCaseProvider)
        .call(
          ListUsersParams(isActive: isActive, limit: limit, offset: offset),
        );

    return result.match((failure) => throw failure, (page) {
      final users = reset
          ? page.items
          : [...?state.value?.users, ...page.items];
      return UsersListState(
        users: users,
        page: page,
        filter: filter,
        limit: limit,
        isLoadingMore: false,
      );
    });
  }

  Future<UsersListState> _fetchPage({
    required int offset,
    required ActiveFilter filter,
  }) async {
    final limit = state.value?.limit ?? 20;
    final isActive = switch (filter) {
      ActiveFilter.all => null,
      ActiveFilter.active => true,
      ActiveFilter.inactive => false,
    };

    final result = await ref
        .read(listUsersUseCaseProvider)
        .call(
          ListUsersParams(isActive: isActive, limit: limit, offset: offset),
        );

    return result.match(
      (failure) => throw failure,
      (page) => UsersListState(
        users: page.items,
        page: page,
        filter: filter,
        limit: limit,
        isLoadingMore: false,
      ),
    );
  }

  Future<UsersListState> _fetchWithFilter(ActiveFilter filter) async {
    final limit = state.value?.limit ?? 20;
    final isActive = switch (filter) {
      ActiveFilter.all => null,
      ActiveFilter.active => true,
      ActiveFilter.inactive => false,
    };

    final result = await ref
        .read(listUsersUseCaseProvider)
        .call(ListUsersParams(isActive: isActive, limit: limit, offset: 0));

    return result.match(
      (failure) => throw failure,
      (page) => UsersListState(
        users: page.items,
        page: page,
        filter: filter,
        limit: limit,
        isLoadingMore: false,
      ),
    );
  }
}

@immutable
class UsersListState {
  final List<User> users;

  final Page<User>? page;
  final ActiveFilter filter;
  final int limit;
  final bool isLoadingMore;
  const UsersListState({
    required this.users,
    required this.page,
    required this.filter,
    required this.limit,
    required this.isLoadingMore,
  });

  bool get hasNext => page?.hasNext ?? false;
  bool get hasPrev => page?.hasPrev ?? false;
  int get total => page?.total ?? 0;

  UsersListState copyWith({
    List<User>? users,
    Page<User>? page,
    ActiveFilter? filter,
    int? limit,
    bool? isLoadingMore,
  }) => UsersListState(
    users: users ?? this.users,
    page: page ?? this.page,
    filter: filter ?? this.filter,
    limit: limit ?? this.limit,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
  );
}
