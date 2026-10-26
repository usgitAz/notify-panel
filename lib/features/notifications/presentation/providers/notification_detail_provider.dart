import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notify_panel/core/error/failure.dart';

import '../../../../core/config/env.dart';
import '../../domain/entities/notification.dart';
import 'notification_providers.dart';
import '../../../auth/presentation/providers/auth_scope_provider.dart';

@immutable
class NotificationDetailState {
  const NotificationDetailState({
    required this.notification,
    required this.isPolling,
  });

  final Notification notification;

  /// True while automatic polling is active.
  final bool isPolling;

  NotificationDetailState copyWith({
    Notification? notification,
    bool? isPolling,
  }) => NotificationDetailState(
    notification: notification ?? this.notification,
    isPolling: isPolling ?? this.isPolling,
  );
}

class NotificationDetailNotifier
    extends AsyncNotifier<NotificationDetailState> {
  NotificationDetailNotifier(this.notificationId);

  final String notificationId;

  Timer? _timer;
  DateTime? _startedAt;

  @override
  Future<NotificationDetailState> build() async {
    final scope = ref.watch(tenantScopeProvider);
    if (scope == null) {
      throw const AuthFailure(message: 'No active session.');
    }

    ref.onDispose(_cancelTimer);

    final notification = await _load();

    if (notification.isPending) {
      _startPolling();
      return NotificationDetailState(
        notification: notification,
        isPolling: true,
      );
    }
    return NotificationDetailState(
      notification: notification,
      isPolling: false,
    );
  }

  Future<Notification> _load() async {
    final result = await ref
        .read(getNotificationUseCaseProvider)
        .call(notificationId);
    return result.match((failure) => throw failure, (n) => n);
  }

  void _startPolling() {
    _timer?.cancel();
    _startedAt = DateTime.now();
    _timer = Timer.periodic(Env.notificationPollingInterval, (_) => _tick());
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
    _startedAt = null;
  }

  void _stopPolling() {
    _cancelTimer();
    final current = state.value;
    if (current != null && current.isPolling) {
      state = AsyncValue.data(current.copyWith(isPolling: false));
    }
  }

  Future<void> _tick() async {
    final startedAt = _startedAt;
    if (startedAt == null) return;

    final elapsed = DateTime.now().difference(startedAt);
    if (elapsed >= Env.notificationPollingMaxDuration) {
      _stopPolling();
      return;
    }

    try {
      final notification = await _load();
      final current = state.value;
      if (current == null) return;

      if (!notification.isPending) {
        _cancelTimer();
        state = AsyncValue.data(
          NotificationDetailState(notification: notification, isPolling: false),
        );
      } else {
        state = AsyncValue.data(current.copyWith(notification: notification));
      }
    } catch (_) {
      // Stop on transient failures to avoid noisy polling;
      // the manual refresh button remains available.
      _stopPolling();
    }
  }

  /// Stop automatic polling. No-op if not polling.
  void stopPolling() => _stopPolling();

  /// Resume polling for a pending notification that stopped (timeout or
  /// manual stop). No-op if already polling or no longer pending.
  void resumePolling() {
    final current = state.value;
    if (current == null || !current.notification.isPending) return;
    if (current.isPolling) return;

    _startPolling();
    state = AsyncValue.data(current.copyWith(isPolling: true));
  }

  /// One-shot refresh. Does not affect polling state.
  Future<void> refresh() async {
    final current = state.value;
    if (current == null) return;

    try {
      final notification = await _load();
      if (!notification.isPending) {
        _cancelTimer();
      }
      state = AsyncValue.data(
        NotificationDetailState(
          notification: notification,
          isPolling: current.isPolling && notification.isPending,
        ),
      );
    } catch (_) {
      // Silent on manual refresh; the existing data stays visible.
    }
  }
}

final notificationDetailProvider =
    AsyncNotifierProvider.family<
      NotificationDetailNotifier,
      NotificationDetailState,
      String
    >(NotificationDetailNotifier.new);
