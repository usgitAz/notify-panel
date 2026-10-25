import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/error/failure_messages.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/async_value_widget.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../devices/presentation/widgets/device_section.dart';
import '../../domain/entities/user.dart';
import '../providers/user_providers.dart';
import '../widgets/edit_user_email_dialog.dart';

class UserDetailPage extends ConsumerWidget {
  final String externalId;

  const UserDetailPage({required this.externalId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userDetailProvider(externalId));

    return AsyncValueWidget<User>(
      value: userAsync,
      onRetry: () => ref.invalidate(userDetailProvider(externalId)),
      data: (user) => _UserDetailBody(externalId: externalId, user: user),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;

  final String value;
  final Widget? trailing;
  final bool isLast;
  const _InfoRow({
    required this.label,
    required this.value,
    this.trailing,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 120,
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
              ?trailing,
            ],
          ),
        ),
        if (!isLast)
          Divider(height: 1, color: theme.colorScheme.outlineVariant),
      ],
    );
  }
}

class _UserDetailBody extends ConsumerStatefulWidget {
  final String externalId;

  final User user;
  const _UserDetailBody({required this.externalId, required this.user});

  @override
  ConsumerState<_UserDetailBody> createState() => _UserDetailBodyState();
}

class _UserDetailBodyState extends ConsumerState<_UserDetailBody> {
  bool _toggling = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = widget.user;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.go(AppRoutes.users),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      user.externalId,
                      style: theme.textTheme.headlineSmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  StatusBadge(
                    label: user.isActive ? 'Active' : 'Inactive',
                    tone: user.isActive
                        ? StatusTone.delivered
                        : StatusTone.neutral,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Details', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 16),
                      _InfoRow(label: 'External ID', value: user.externalId),
                      _InfoRow(
                        label: 'Email',
                        value: user.email ?? '—',
                        trailing: IconButton(
                          tooltip: 'Edit email',
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          onPressed: _editEmail,
                        ),
                      ),
                      _InfoRow(
                        label: 'Status',
                        value: user.isActive ? 'Active' : 'Inactive',
                      ),
                      if (!user.isActive && user.deactivatedAt != null)
                        _InfoRow(
                          label: 'Deactivated',
                          value: _formatDate(user.deactivatedAt!),
                        ),
                      _InfoRow(
                        label: 'Created',
                        value: _formatDate(user.createdAt),
                      ),
                      _InfoRow(
                        label: 'Updated',
                        value: _formatDate(user.updatedAt),
                        isLast: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  AppButton(
                    label: user.isActive ? 'Deactivate' : 'Activate',
                    onPressed: _toggling ? null : _toggleActive,
                    loading: _toggling,
                    icon: user.isActive
                        ? Icons.person_off_outlined
                        : Icons.person_outline,
                    variant: user.isActive
                        ? AppButtonVariant.outlined
                        : AppButtonVariant.filled,
                  ),
                  AppButton(
                    label: 'Send notification',
                    icon: Icons.email_outlined,
                    variant: AppButtonVariant.outlined,
                    onPressed: () => context.go(
                      AppRoutes.notificationComposePath(to: user.externalId),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              DeviceSection(userExternalId: widget.externalId),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editEmail() async {
    final updated = await EditUserEmailDialog.show(
      context: context,
      initialEmail: widget.user.email,
    );
    if (updated == null) return;

    final result = await ref
        .read(userDetailProvider(widget.externalId).notifier)
        .updateEmail(updated);

    if (!mounted) return;
    result.match(
      (failure) => AppSnackbar.error(context, FailureMessages.of(failure)),
      (_) => AppSnackbar.success(context, 'Email updated.'),
    );
  }

  String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    return '${local.year}-${_pad(local.month)}-${_pad(local.day)} '
        '${_pad(local.hour)}:${_pad(local.minute)}';
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  Future<void> _toggleActive() async {
    final user = widget.user;
    final activating = !user.isActive;

    final confirmed = await ConfirmDialog.show(
      context: context,
      title: activating ? 'Activate user' : 'Deactivate user',
      message: activating
          ? 'The user will be able to receive notifications again.'
          : 'The user will no longer receive notifications. '
                'You can reactivate them later.',
      confirmLabel: activating ? 'Activate' : 'Deactivate',
      destructive: !activating,
    );
    if (!confirmed) return;

    setState(() => _toggling = true);

    final result = await ref
        .read(userDetailProvider(widget.externalId).notifier)
        .toggleActive();

    if (!mounted) return;
    setState(() => _toggling = false);

    result.match(
      (failure) => AppSnackbar.error(context, FailureMessages.of(failure)),
      (_) => AppSnackbar.success(
        context,
        activating ? 'User activated.' : 'User deactivated.',
      ),
    );
  }
}
