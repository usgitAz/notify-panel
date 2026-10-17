import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/failure_messages.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../providers/user_providers.dart';

class UserLookupPage extends ConsumerStatefulWidget {
  const UserLookupPage({super.key});

  @override
  ConsumerState<UserLookupPage> createState() => _UserLookupPageState();
}

class _UserLookupPageState extends ConsumerState<UserLookupPage> {
  final _controller = TextEditingController();
  bool _searching = false;
  Failure? _failure;
  String? _notFoundId;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final externalId = _controller.text.trim();
    if (externalId.isEmpty) return;

    setState(() {
      _searching = true;
      _failure = null;
      _notFoundId = null;
    });

    final result = await ref.read(getUserUseCaseProvider).call(externalId);

    if (!mounted) return;

    setState(() => _searching = false);

    result.match((failure) {
      if (failure is NotFoundFailure) {
        setState(() => _notFoundId = externalId);
      } else {
        setState(() => _failure = failure);
      }
    }, (user) => context.go(AppRoutes.userDetailPath(user.externalId)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Find user', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                'Enter the external ID of a user to view or edit it.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              AppTextField(
                controller: _controller,
                label: 'External ID',
                hint: 'user_123',
                prefixIcon: const Icon(Icons.search),
                enabled: !_searching,
                autofocus: true,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _search(),
              ),
              const SizedBox(height: 16),
              AppButton(
                label: 'Search',
                onPressed: _search,
                loading: _searching,
                icon: Icons.search,
                expanded: true,
              ),
              if (_failure != null) ...[
                const SizedBox(height: 24),
                _MessageBanner(
                  icon: Icons.error_outline,
                  message: FailureMessages.of(_failure!),
                  tone: _BannerTone.error,
                ),
              ],
              if (_notFoundId != null) ...[
                const SizedBox(height: 24),
                _MessageBanner(
                  icon: Icons.person_off_outlined,
                  message: 'User "$_notFoundId" not found.',
                  tone: _BannerTone.warning,
                  actionLabel: 'Create user',
                  onAction: () => context.go(
                    AppRoutes.userCreatePath(externalId: _notFoundId),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

enum _BannerTone { warning, error }

class _MessageBanner extends StatelessWidget {
  const _MessageBanner({
    required this.icon,
    required this.message,
    required this.tone,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final _BannerTone tone;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = tone == _BannerTone.error
        ? scheme.errorContainer
        : scheme.tertiaryContainer;
    final fg = tone == _BannerTone.error
        ? scheme.onErrorContainer
        : scheme.onTertiaryContainer;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, color: fg, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(message, style: TextStyle(color: fg, fontSize: 13)),
              ),
            ],
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 12),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                onPressed: onAction,
                style: TextButton.styleFrom(foregroundColor: fg),
                child: Text(actionLabel!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
