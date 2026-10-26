import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../features/auth/presentation/providers/auth_providers.dart';
import '../../../../features/auth/presentation/providers/auth_state.dart';
import '../../../../shared/widgets/async_value_widget.dart';
import '../../domain/entities/health_status.dart';
import '../providers/health_provider.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final auth = ref.watch(authNotifierProvider);
    final tenantName = switch (auth) {
      AuthAuthenticated(:final session) => session.tenant.name,
      _ => '',
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(tenantName: tenantName),
              const SizedBox(height: 24),
              _HealthRow(),
              const SizedBox(height: 24),
              Text('Quick actions', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              const _QuickActions(),
              const SizedBox(height: 24),
              const _GettingStartedGate(),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Header ───

class _Header extends StatelessWidget {
  const _Header({required this.tenantName});

  final String tenantName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Dashboard', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(
          tenantName.isEmpty
              ? 'Overview of your notification service.'
              : 'Welcome back, $tenantName.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// ─── Health row ───

class _HealthRow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(healthProvider);
    final notifier = ref.read(healthProvider.notifier);

    return AsyncValueWidget<HealthStatus>(
      value: async,
      onRetry: notifier.refresh,
      data: (status) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _HealthCard(
              title: 'Service',
              subtitle: 'Liveness',
              probe: status.liveness,
              checkedAt: status.checkedAt,
              showChecks: false,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _HealthCard(
              title: 'Dependencies',
              subtitle: 'Readiness',
              probe: status.readiness,
              checkedAt: status.checkedAt,
              showChecks: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _HealthCard extends StatelessWidget {
  const _HealthCard({
    required this.title,
    required this.subtitle,
    required this.probe,
    required this.checkedAt,
    required this.showChecks,
  });

  final String title;
  final String subtitle;
  final HealthProbe probe;
  final DateTime checkedAt;
  final bool showChecks;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = theme.extension<AppStatusColors>()!;

    final (color, surface, label, icon) = probe.ok
        ? (
            status.delivered,
            status.deliveredSurface,
            'Operational',
            Icons.check_circle,
          )
        : probe.error != null
        ? (
            status.failed,
            status.failedSurface,
            'Unreachable',
            Icons.error_outline,
          )
        : (
            status.pending,
            status.pendingSurface,
            'Degraded',
            Icons.warning_amber_outlined,
          );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: theme.textTheme.titleSmall),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (probe.error != null) ...[
              const SizedBox(height: 12),
              Text(
                probe.error!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
            if (showChecks && probe.checks != null) ...[
              const SizedBox(height: 12),
              for (final e in probe.checks!.entries)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      Icon(
                        e.value == 'ok'
                            ? Icons.check_circle_outline
                            : Icons.error_outline,
                        size: 14,
                        color: e.value == 'ok'
                            ? status.delivered
                            : status.failed,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_capitalize(e.key)}: ${e.value}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
            ],
            const SizedBox(height: 12),
            Text(
              'Last checked ${_formatTime(checkedAt)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  static String _formatTime(DateTime dt) {
    final local = dt.toLocal();
    return '${_pad(local.hour)}:${_pad(local.minute)}:${_pad(local.second)}';
  }

  static String _pad(int n) => n.toString().padLeft(2, '0');
}

// ─── Quick actions ───

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionCard(
            icon: Icons.people_outline,
            title: 'Users',
            subtitle: 'Manage end-users of your tenant',
            onTap: () => context.go(AppRoutes.users),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _ActionCard(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Browse delivery history',
            onTap: () => context.go(AppRoutes.notifications),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _ActionCard(
            icon: Icons.edit_outlined,
            title: 'Compose',
            subtitle: 'Send an email to users',
            onTap: () => context.go(AppRoutes.notificationComposePath()),
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 24, color: theme.colorScheme.primary),
              const SizedBox(height: 12),
              Text(title, style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                subtitle,
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
}

// ─── Getting-started gate ───

class _GettingStartedGate extends ConsumerWidget {
  const _GettingStartedGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countAsync = ref.watch(userCountProvider);
    // Only render when we positively know the tenant has zero users.
    final count = countAsync.value;
    if (count != 0) return const SizedBox.shrink();
    return const _GettingStartedCard();
  }
}

class _GettingStartedCard extends StatelessWidget {
  const _GettingStartedCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.rocket_launch_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text('Getting started', style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 16),
            const _Step(
              number: 1,
              text: 'Create your first user',
              route: AppRoutes.users,
            ),
            const _Step(
              number: 2,
              text: 'Register a device for that user (optional)',
              route: AppRoutes.users,
            ),
            const _Step(
              number: 3,
              text: 'Send an email notification',
              route: null,
              compose: true,
            ),
            const SizedBox(height: 16),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: FilledButton.icon(
                onPressed: () => context.go(AppRoutes.users),
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: const Text('Go to users'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.number,
    required this.text,
    required this.route,
    this.compose = false,
  });

  final int number;
  final String text;
  final String? route;
  final bool compose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$number',
              style: TextStyle(
                color: theme.colorScheme.onPrimaryContainer,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
          if (route != null)
            TextButton(
              onPressed: () => context.go(route!),
              child: const Text('Go'),
            )
          else if (compose)
            TextButton(
              onPressed: () => context.go(AppRoutes.notificationComposePath()),
              child: const Text('Compose'),
            ),
        ],
      ),
    );
  }
}
