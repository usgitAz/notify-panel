import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/page.dart';
import '../../domain/entities/notification.dart';
import '../../domain/usecases/list_notifications_usecase.dart';
import 'notification_providers.dart';

@immutable
class NotificationsListState {
  const NotificationsListState({
    required this.notifications,
    required this.page,
    required this.statusFilter,
    required this.channelFilter,
    required this.limit,
  });

  final List<Notification> notifications;
  final Page<Notification>? page;

  /// `null` means "All statuses".
  final NotificationStatus? statusFilter;

  /// `null` means "All channels".
  final NotificationChannel? channelFilter;

  final int limit;

  bool get hasNext => page?.hasNext ?? false;
  bool get hasPrev => page?.hasPrev ?? false;
  int get total => page?.total ?? 0;

  NotificationsListState copyWith({
    List<Notification>? notifications,
    Page<Notification>? page,
    NotificationStatus? Function()? statusFilter,
    NotificationChannel? Function()? channelFilter,
    int? limit,
  }) => NotificationsListState(
    notifications: notifications ?? this.notifications,
    page: page ?? this.page,
    statusFilter: statusFilter != null ? statusFilter() : this.statusFilter,
    channelFilter: channelFilter != null ? channelFilter() : this.channelFilter,
    limit: limit ?? this.limit,
  );
}

class NotificationsListNotifier extends AsyncNotifier<NotificationsListState> {
  @override
  Future<NotificationsListState> build() =>
      _fetch(status: null, channel: null, offset: 0);

  Future<NotificationsListState> _fetch({
    required NotificationStatus? status,
    required NotificationChannel? channel,
    required int offset,
  }) async {
    const limit = 20;
    final result = await ref
        .read(listNotificationsUseCaseProvider)
        .call(
          ListNotificationsParams(
            status: status,
            channel: channel,
            limit: limit,
            offset: offset,
          ),
        );

    return result.match(
      (failure) => throw failure,
      (page) => NotificationsListState(
        notifications: page.items,
        page: page,
        statusFilter: status,
        channelFilter: channel,
        limit: limit,
      ),
    );
  }

  Future<void> setStatusFilter(NotificationStatus? status) async {
    final current = state.value;
    if (current == null || current.statusFilter == status) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _fetch(status: status, channel: current.channelFilter, offset: 0),
    );
  }

  Future<void> setChannelFilter(NotificationChannel? channel) async {
    final current = state.value;
    if (current == null || current.channelFilter == channel) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _fetch(status: current.statusFilter, channel: channel, offset: 0),
    );
  }

  Future<void> refresh() async {
    final current = state.value;
    if (current == null) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _fetch(
        status: current.statusFilter,
        channel: current.channelFilter,
        offset: 0,
      ),
    );
  }

  Future<void> goToNextPage() async {
    final current = state.value;
    if (current == null || !current.hasNext) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final nextOffset =
          (current.page?.offset ?? 0) + (current.page?.limit ?? 20);
      return _fetch(
        status: current.statusFilter,
        channel: current.channelFilter,
        offset: nextOffset,
      );
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
      return _fetch(
        status: current.statusFilter,
        channel: current.channelFilter,
        offset: prevOffset,
      );
    });
  }
}

final notificationsListProvider =
    AsyncNotifierProvider<NotificationsListNotifier, NotificationsListState>(
      NotificationsListNotifier.new,
    );
