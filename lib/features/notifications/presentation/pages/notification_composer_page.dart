import 'package:flutter/material.dart' hide Notification;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/error/failure_messages.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../providers/composer_provider.dart';
import '../providers/notifications_list_provider.dart';

class NotificationComposerPage extends ConsumerStatefulWidget {
  const NotificationComposerPage({this.prefillExternalId, super.key});

  final String? prefillExternalId;

  @override
  ConsumerState<NotificationComposerPage> createState() =>
      _NotificationComposerPageState();
}

class _NotificationComposerPageState
    extends ConsumerState<NotificationComposerPage> {
  final _formKey = GlobalKey<FormState>();
  final _recipientController = TextEditingController();
  final _subjectController = TextEditingController();
  final _bodyController = TextEditingController();
  final _fromController = TextEditingController();
  final _replyToController = TextEditingController();
  final _ccController = TextEditingController();
  final _bccController = TextEditingController();
  final _attachmentsController = TextEditingController();

  final _recipients = <String>[];
  bool _optionalExpanded = false;

  @override
  void initState() {
    super.initState();
    final to = widget.prefillExternalId;
    if (to != null && to.isNotEmpty) {
      _recipients.add(to);
      // Drop stale results from any earlier session
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final current = ref.read(composerProvider);
        if (!current.isSending && current.hasResults) {
          ref.read(composerProvider.notifier).reset();
        }
      });
    }
  }

  @override
  void dispose() {
    _recipientController.dispose();
    _subjectController.dispose();
    _bodyController.dispose();
    _fromController.dispose();
    _replyToController.dispose();
    _ccController.dispose();
    _bccController.dispose();
    _attachmentsController.dispose();
    super.dispose();
  }

  void _addRecipient() {
    final raw = _recipientController.text.trim();
    if (raw.isEmpty) return;

    // Support comma/newline batch entry
    final parts = raw
        .split(RegExp(r'[\n,]'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty);

    setState(() {
      for (final id in parts) {
        if (!_recipients.contains(id)) _recipients.add(id);
      }
      _recipientController.clear();
    });
  }

  void _removeRecipient(String id) {
    setState(() => _recipients.remove(id));
  }

  Future<void> _submit() async {
    if (_recipients.isEmpty) {
      AppSnackbar.error(context, 'Add at least one recipient.');
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) return;

    await ref
        .read(composerProvider.notifier)
        .sendBulk(
          recipients: List.unmodifiable(_recipients),
          subject: _subjectController.text.trim(),
          body: _bodyController.text.trim(),
          fromEmail: _optional(_fromController.text),
          replyTo: _optional(_replyToController.text),
          cc: _parseList(_ccController.text),
          bcc: _parseList(_bccController.text),
          attachments: _parseList(_attachmentsController.text),
        );

    // Results are visible now; the user can navigate to the list
    // to see the full notification records.
    ref.invalidate(notificationsListProvider);
  }

  void _reset() {
    setState(() {
      _recipients.clear();
      _recipientController.clear();
      _subjectController.clear();
      _bodyController.clear();
      _fromController.clear();
      _replyToController.clear();
      _ccController.clear();
      _bccController.clear();
      _attachmentsController.clear();
      _optionalExpanded = false;
    });
    ref.read(composerProvider.notifier).reset();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(composerProvider);
    final theme = Theme.of(context);
    final disabled = state.isSending || state.isDone;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(state: state),
                const SizedBox(height: 24),
                _SectionCard(
                  title: 'Recipients',
                  child: _RecipientsSection(
                    controller: _recipientController,
                    recipients: _recipients,
                    enabled: !disabled,
                    onAdd: _addRecipient,
                    onRemove: _removeRecipient,
                  ),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Message',
                  child: _ContentSection(
                    subjectController: _subjectController,
                    bodyController: _bodyController,
                    enabled: !disabled,
                  ),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Optional',
                  trailing: IconButton(
                    tooltip: _optionalExpanded ? 'Collapse' : 'Expand',
                    icon: Icon(
                      _optionalExpanded ? Icons.expand_less : Icons.expand_more,
                    ),
                    onPressed: disabled
                        ? null
                        : () => setState(
                            () => _optionalExpanded = !_optionalExpanded,
                          ),
                  ),
                  child: _optionalExpanded
                      ? _OptionalSection(
                          fromController: _fromController,
                          replyToController: _replyToController,
                          ccController: _ccController,
                          bccController: _bccController,
                          attachmentsController: _attachmentsController,
                          enabled: !disabled,
                        )
                      : Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            'From, Reply-To, CC, BCC, attachments.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 16),
                _SendSection(
                  state: state,
                  recipientCount: _recipients.length,
                  onSend: _submit,
                  onReset: _reset,
                  onViewList: () => context.go(AppRoutes.notifications),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String? _optional(String s) => s.trim().isEmpty ? null : s.trim();

  static List<String> _parseList(String text) => text
      .split(RegExp(r'[\n,]'))
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList(growable: false);
}

// ─── Header ───

class _Header extends StatelessWidget {
  const _Header({required this.state});

  final ComposerState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: state.isSending
              ? null
              : () => context.go(AppRoutes.notifications),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Compose notification',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                'Send an email to one or more users of this tenant.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Section wrapper ───

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                const Spacer(),
                ?trailing,
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

// ─── Recipients section ───

class _RecipientsSection extends StatelessWidget {
  const _RecipientsSection({
    required this.controller,
    required this.recipients,
    required this.enabled,
    required this.onAdd,
    required this.onRemove,
  });

  final TextEditingController controller;
  final List<String> recipients;
  final bool enabled;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppTextField(
                controller: controller,
                label: 'External ID',
                hint: 'user_123  (comma or newline for multiple)',
                enabled: enabled,
                onSubmitted: (_) => onAdd(),
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: AppButton(
                label: 'Add',
                icon: Icons.add,
                variant: AppButtonVariant.outlined,
                onPressed: enabled ? onAdd : null,
              ),
            ),
          ],
        ),
        if (recipients.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final id in recipients)
                InputChip(
                  label: Text(id),
                  onDeleted: enabled ? () => onRemove(id) : null,
                  deleteIcon: const Icon(Icons.close, size: 16),
                ),
            ],
          ),
        ] else ...[
          const SizedBox(height: 8),
          Text(
            'No recipients yet.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Content section ───

class _ContentSection extends StatelessWidget {
  const _ContentSection({
    required this.subjectController,
    required this.bodyController,
    required this.enabled,
  });

  final TextEditingController subjectController;
  final TextEditingController bodyController;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          controller: subjectController,
          label: 'Subject',
          hint: 'Welcome to our service',
          maxLength: 255,
          enabled: enabled,
          validator: (v) =>
              Validators.required(v, field: 'Subject') ??
              Validators.maxLength(v, 255, field: 'Subject'),
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: bodyController,
          label: 'Body',
          hint: 'Write your message here...',
          maxLines: 8,
          enabled: enabled,
          validator: (v) => Validators.required(v, field: 'Body'),
        ),
      ],
    );
  }
}

// ─── Optional section ───

class _OptionalSection extends StatelessWidget {
  const _OptionalSection({
    required this.fromController,
    required this.replyToController,
    required this.ccController,
    required this.bccController,
    required this.attachmentsController,
    required this.enabled,
  });

  final TextEditingController fromController;
  final TextEditingController replyToController;
  final TextEditingController ccController;
  final TextEditingController bccController;
  final TextEditingController attachmentsController;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          controller: fromController,
          label: 'From email (optional)',
          hint: 'noreply@yourdomain.com',
          enabled: enabled,
          validator: Validators.email,
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: replyToController,
          label: 'Reply-To (optional)',
          hint: 'support@yourdomain.com',
          enabled: enabled,
          validator: Validators.email,
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: ccController,
          label: 'CC (optional)',
          hint: 'Comma or newline separated emails',
          maxLines: 3,
          enabled: enabled,
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: bccController,
          label: 'BCC (optional)',
          hint: 'Comma or newline separated emails',
          maxLines: 3,
          enabled: enabled,
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: attachmentsController,
          label: 'Attachments (optional)',
          hint: 'One URL per line, max 10',
          maxLines: 3,
          enabled: enabled,
        ),
      ],
    );
  }
}

// ─── Send section (button + progress + results) ───

class _SendSection extends StatelessWidget {
  const _SendSection({
    required this.state,
    required this.recipientCount,
    required this.onSend,
    required this.onReset,
    required this.onViewList,
  });

  final ComposerState state;
  final int recipientCount;
  final VoidCallback onSend;
  final VoidCallback onReset;
  final VoidCallback onViewList;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!state.hasResults) ...[
              Row(
                children: [
                  Expanded(
                    child: Text(
                      recipientCount == 0
                          ? 'Add at least one recipient to send.'
                          : 'Ready to send to $recipientCount '
                                '${recipientCount == 1 ? "user" : "users"}.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  AppButton(
                    label: 'Send',
                    icon: Icons.send_outlined,
                    onPressed: recipientCount == 0 ? null : onSend,
                  ),
                ],
              ),
            ],

            if (state.hasResults) ...[
              // Progress
              Row(
                children: [
                  Expanded(
                    child: Text(
                      state.isDone
                          ? 'Completed: ${state.successCount} succeeded, '
                                '${state.failureCount} failed '
                                'of ${state.total}.'
                          : 'Sending… ${state.completed} of ${state.total}',
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
                  if (state.isSending)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: state.progress,
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
              const SizedBox(height: 16),

              // Results list
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 320),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: state.results.length,
                  separatorBuilder: (_, _) => Divider(
                    height: 1,
                    color: theme.colorScheme.outlineVariant,
                  ),
                  itemBuilder: (_, i) => _ResultRow(result: state.results[i]),
                ),
              ),

              if (state.isDone) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: onViewList,
                      icon: const Icon(Icons.list_alt, size: 18),
                      label: const Text('View notifications'),
                    ),
                    const SizedBox(width: 8),
                    AppButton(
                      label: 'Compose new',
                      icon: Icons.add,
                      variant: AppButtonVariant.outlined,
                      onPressed: onReset,
                    ),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.result});

  final RecipientResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final (icon, color) = switch (result.status) {
      RecipientStatus.pending => (
        Icons.schedule,
        theme.colorScheme.onSurfaceVariant,
      ),
      RecipientStatus.sending => (Icons.sync, theme.colorScheme.primary),
      RecipientStatus.delivered => (
        Icons.check_circle,
        theme.colorScheme.primary,
      ),
      RecipientStatus.failed => (Icons.error_outline, theme.colorScheme.error),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.externalId,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (result.failure != null)
                  Text(
                    FailureMessages.of(result.failure!),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
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
