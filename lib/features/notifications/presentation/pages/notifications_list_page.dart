import 'package:flutter/material.dart' hide Notification;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../shared/widgets/async_value_widget.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../domain/entities/notification.dart';
import '../providers/notifications_list_provider.dart';

class NotificationsListPage extends ConsumerWidget {
  const NotificationsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(notificationsListProvider);
    final notifier = ref.read(notificationsListProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(onRefresh: notifier.refresh),
          const SizedBox(height: 16),
          _Filters(
            status: async.value?.statusFilter,
            channel: async.value?.channelFilter,
            onStatusChanged: notifier.setStatusFilter,
            onChannelChanged: notifier.setChannelFilter,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: AsyncValueWidget<NotificationsListState>(
              value: async,
              onRetry: notifier.refresh,
              data: (state) {
                if (state.notifications.isEmpty) {
                  final hasFilters =
                      state.statusFilter != null || state.channelFilter != null;
                  return EmptyState(
                    icon: Icons.notifications_none_outlined,
                    title: hasFilters
                        ? 'No notifications match these filters'
                        : 'No notifications yet',
                    message: hasFilters ? 'Try adjusting the filters above.' : 'Notifications sent from this tenant will appear here.',
                  );
                }

                return _NotificationsTable(
                  notifications: state.notifications,
                  onRowTap: (n) =>
                      context.go(AppRoutes.notificationDetailPath(n.id)),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          _Pagination(
            hasNext: async.value?.hasNext ?? false,
            hasPrev: async.value?.hasPrev ?? false,
            total: async.value?.total ?? 0,
            firstIndex: async.value?.page?.firstIndex ?? 0,
            lastIndex: async.value?.page?.lastIndex ?? 0,
            onNext: notifier.goToNextPage,
            onPrev: notifier.goToPrevPage,
            loading: async.isLoading,
          ),
        ],
      ),
    );
  }
}

// ─── Filters ───

class _Filters extends StatelessWidget {
  final NotificationStatus? status;

  final NotificationChannel? channel;
  final ValueChanged<NotificationStatus?> onStatusChanged;
  final ValueChanged<NotificationChannel?> onChannelChanged;
  const _Filters({
    required this.status,
    required this.channel,
    required this.onStatusChanged,
    required this.onChannelChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Status:', style: theme.textTheme.bodySmall),
            const SizedBox(width: 8),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('All')),
                ButtonSegment(value: 1, label: Text('Pending')),
                ButtonSegment(value: 2, label: Text('Delivered')),
                ButtonSegment(value: 3, label: Text('Failed')),
              ],
              selected: {_statusToIndex(status)},
              onSelectionChanged: (s) =>
                  onStatusChanged(_indexToStatus(s.first)),
              showSelectedIcon: false,
              style: const ButtonStyle(visualDensity: VisualDensity.compact),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Channel:', style: theme.textTheme.bodySmall),
            const SizedBox(width: 8),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('All')),
                ButtonSegment(value: 1, label: Text('Email')),
                ButtonSegment(value: 2, label: Text('Push')),
              ],
              selected: {_channelToIndex(channel)},
              onSelectionChanged: (s) =>
                  onChannelChanged(_indexToChannel(s.first)),
              showSelectedIcon: false,
              style: const ButtonStyle(visualDensity: VisualDensity.compact),
            ),
          ],
        ),
      ],
    );
  }

  static int _channelToIndex(NotificationChannel? c) => switch (c) {
    null => 0,
    NotificationChannel.email => 1,
    NotificationChannel.push => 2,
  };

  static NotificationChannel? _indexToChannel(int i) => switch (i) {
    0 => null,
    1 => NotificationChannel.email,
    2 => NotificationChannel.push,
    _ => null,
  };

  static NotificationStatus? _indexToStatus(int i) => switch (i) {
    0 => null,
    1 => NotificationStatus.pending,
    2 => NotificationStatus.delivered,
    3 => NotificationStatus.failed,
    _ => null,
  };

  static int _statusToIndex(NotificationStatus? s) => switch (s) {
    null => 0,
    NotificationStatus.pending => 1,
    NotificationStatus.delivered => 2,
    NotificationStatus.failed => 3,
  };
}

// ─── Header ───

class _Header extends StatelessWidget {
  final VoidCallback onRefresh;

  const _Header({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Notifications', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(
                'History of every notification sent by this tenant.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Refresh',
          icon: const Icon(Icons.refresh),
          onPressed: onRefresh,
        ),
      ],
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;

  final int flex;
  final TextAlign align;
  const _HeaderCell(
    this.label, {
    required this.flex,
    this.align = TextAlign.left,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      flex: flex,
      child: Text(
        label,
        textAlign: align,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _NotificationRow extends StatelessWidget {
  final Notification notification;

  final VoidCallback onTap;
  const _NotificationRow({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final n = notification;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  n.id.substring(0, 8),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  n.userExternalId ?? '—',
                  style: theme.textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Icon(
                      _channelIcon(n.channel),
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _channelLabel(n.channel),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 4,
                child: Text(
                  n.title?.isNotEmpty == true ? n.title! : '(no subject)',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: n.title?.isNotEmpty == true
                        ? null
                        : theme.colorScheme.onSurfaceVariant,
                    fontStyle: n.title?.isNotEmpty == true
                        ? FontStyle.normal
                        : FontStyle.italic,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: StatusBadge(
                    label: _statusLabel(n.status),
                    tone: _statusTone(n.status),
                    compact: true,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  n.attempts.toString(),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  _formatDate(n.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(
                width: 24,
                child: Icon(Icons.chevron_right, size: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static IconData _channelIcon(NotificationChannel c) => switch (c) {
    NotificationChannel.email => Icons.email_outlined,
    NotificationChannel.push => Icons.notifications_outlined,
  };

  static String _channelLabel(NotificationChannel c) => switch (c) {
    NotificationChannel.email => 'Email',
    NotificationChannel.push => 'Push',
  };

  static String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    return '${local.year}-${_pad(local.month)}-${_pad(local.day)} '
        '${_pad(local.hour)}:${_pad(local.minute)}';
  }

  static String _pad(int n) => n.toString().padLeft(2, '0');

  static String _statusLabel(NotificationStatus s) => switch (s) {
    NotificationStatus.pending => 'Pending',
    NotificationStatus.delivered => 'Delivered',
    NotificationStatus.failed => 'Failed',
  };

  static StatusTone _statusTone(NotificationStatus s) => switch (s) {
    NotificationStatus.pending => StatusTone.pending,
    NotificationStatus.delivered => StatusTone.delivered,
    NotificationStatus.failed => StatusTone.failed,
  };
}

// ─── Table ───

class _NotificationsTable extends StatelessWidget {
  final List<Notification> notifications;

  final ValueChanged<Notification> onRowTap;
  const _NotificationsTable({
    required this.notifications,
    required this.onRowTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              border: Border(
                bottom: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
            ),
            child: Row(
              children: const [
                _HeaderCell('ID', flex: 2),
                _HeaderCell('User', flex: 3),
                _HeaderCell('Channel', flex: 2),
                _HeaderCell('Subject', flex: 4),
                _HeaderCell('Status', flex: 2),
                _HeaderCell('Attempts', flex: 1, align: TextAlign.center),
                _HeaderCell('Created', flex: 3),
                SizedBox(width: 24),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: notifications.length,
              separatorBuilder: (_, _) =>
                  Divider(height: 1, color: theme.colorScheme.outlineVariant),
              itemBuilder: (_, i) => _NotificationRow(
                notification: notifications[i],
                onTap: () => onRowTap(notifications[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Pagination ───

class _Pagination extends StatelessWidget {
  final bool hasNext;

  final bool hasPrev;
  final int total;
  final int firstIndex;
  final int lastIndex;
  final VoidCallback onNext;
  final VoidCallback onPrev;
  final bool loading;
  const _Pagination({
    required this.hasNext,
    required this.hasPrev,
    required this.total,
    required this.firstIndex,
    required this.lastIndex,
    required this.onNext,
    required this.onPrev,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          total == 0
              ? 'No results'
              : 'Showing $firstIndex–$lastIndex of $total',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        OutlinedButton.icon(
          onPressed: hasPrev && !loading ? onPrev : null,
          icon: const Icon(Icons.chevron_left, size: 18),
          label: const Text('Previous'),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: hasNext && !loading ? onNext : null,
          icon: const Icon(Icons.chevron_right, size: 18),
          label: const Text('Next'),
        ),
      ],
    );
  }
}
