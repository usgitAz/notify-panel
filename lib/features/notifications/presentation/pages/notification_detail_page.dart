import 'package:flutter/material.dart' hide Notification;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../shared/widgets/async_value_widget.dart';
import '../../../../shared/widgets/json_viewer.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../domain/entities/notification.dart';
import '../providers/notification_detail_provider.dart';

class NotificationDetailPage extends ConsumerWidget {
  const NotificationDetailPage({required this.notificationId, super.key});

  final String notificationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(notificationDetailProvider(notificationId));
    final notifier = ref.read(
      notificationDetailProvider(notificationId).notifier,
    );

    return AsyncValueWidget<NotificationDetailState>(
      value: async,
      onRetry: () => ref.invalidate(notificationDetailProvider(notificationId)),
      data: (state) => _Body(state: state, notifier: notifier),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.state, required this.notifier});

  final NotificationDetailState state;
  final NotificationDetailNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final n = state.notification;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(state: state, notifier: notifier),
              const SizedBox(height: 24),
              _InfoCard(notification: n),
              const SizedBox(height: 16),
              _ContentCard(notification: n),
              if (n.lastError != null && n.lastError!.isNotEmpty) ...[
                const SizedBox(height: 16),
                _ErrorCard(message: n.lastError!),
              ],
              if (n.payload.isNotEmpty) ...[
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: JsonViewer(data: n.payload),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Text(
                'Created ${_formatDate(n.createdAt)}'
                ' · Updated ${_formatDate(n.updatedAt)}',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    return '${local.year}-${_pad(local.month)}-${_pad(local.day)} '
        '${_pad(local.hour)}:${_pad(local.minute)}:${_pad(local.second)}';
  }

  static String _pad(int n) => n.toString().padLeft(2, '0');
}

// ─── Header ───

class _Header extends StatelessWidget {
  const _Header({required this.state, required this.notifier});

  final NotificationDetailState state;
  final NotificationDetailNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final n = state.notification;

    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.notifications),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Notification', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 4),
              SelectableText(
                n.id,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        StatusBadge(label: _statusLabel(n.status), tone: _statusTone(n.status)),
        const SizedBox(width: 12),
        _PollingIndicator(state: state, notifier: notifier),
        IconButton(
          tooltip: 'Refresh',
          icon: const Icon(Icons.refresh),
          onPressed: notifier.refresh,
        ),
      ],
    );
  }

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

class _PollingIndicator extends StatelessWidget {
  const _PollingIndicator({required this.state, required this.notifier});

  final NotificationDetailState state;
  final NotificationDetailNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (state.isPolling) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Live',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          TextButton(
            onPressed: notifier.stopPolling,
            style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
            child: const Text('Stop'),
          ),
        ],
      );
    }

    if (state.notification.isPending) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.pause_circle_outline,
            size: 16,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Text(
            'Polling stopped',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 4),
          TextButton(
            onPressed: notifier.resumePolling,
            style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
            child: const Text('Resume'),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}

// ─── Info card ───

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.notification});

  final Notification notification;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Details', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            _Row(
              label: 'Channel',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _channelIcon(notification.channel),
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(_channelLabel(notification.channel)),
                ],
              ),
            ),
            _Row(
              label: 'User',
              child: Text(notification.userExternalId ?? '—'),
            ),
            _Row(
              label: 'Attempts',
              child: Text(notification.attempts.toString()),
            ),
            _Row(
              label: 'User ID',
              child: SelectableText(
                notification.userId,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          ],
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
}

// ─── Content card ───

class _ContentCard extends StatelessWidget {
  const _ContentCard({required this.notification});

  final Notification notification;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final n = notification;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Message', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            if (n.title != null && n.title!.isNotEmpty) ...[
              Text(
                n.title!,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
            ],
            SelectableText(
              n.body,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Error card ───

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: scheme.onErrorContainer, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Last error',
                  style: TextStyle(
                    color: scheme.onErrorContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  message,
                  style: TextStyle(
                    color: scheme.onErrorContainer,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Info row ───

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: DefaultTextStyle.merge(
              style: theme.textTheme.bodyMedium ?? const TextStyle(),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
