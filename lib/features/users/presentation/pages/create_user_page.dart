import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/failure_messages.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../domain/usecases/create_user_usecase.dart';
import '../providers/user_providers.dart';

class CreateUserPage extends ConsumerStatefulWidget {
  const CreateUserPage({this.prefillExternalId, super.key});

  final String? prefillExternalId;

  @override
  ConsumerState<CreateUserPage> createState() => _CreateUserPageState();
}

class _CreateUserPageState extends ConsumerState<CreateUserPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _externalIdController;
  final _emailController = TextEditingController();

  bool _submitting = false;
  Failure? _failure;

  @override
  void initState() {
    super.initState();
    _externalIdController = TextEditingController(
      text: widget.prefillExternalId ?? '',
    );
  }

  @override
  void dispose() {
    _externalIdController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _submitting = true;
      _failure = null;
    });

    final email = _emailController.text.trim();
    final result = await ref
        .read(createUserUseCaseProvider)
        .call(
          CreateUserParams(
            externalId: _externalIdController.text.trim(),
            email: email.isEmpty ? null : email,
          ),
        );

    if (!mounted) return;
    setState(() => _submitting = false);

    result.match((failure) => setState(() => _failure = failure), (user) {
      AppSnackbar.success(context, 'User created.');
      context.go(AppRoutes.userDetailPath(user.externalId));
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final validation = _failure is ValidationFailure
        ? _failure as ValidationFailure
        : null;

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
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
                        Text('Create user', style: theme.textTheme.titleLarge),
                      ],
                    ),
                    const SizedBox(height: 24),
                    AppTextField(
                      controller: _externalIdController,
                      label: 'External ID',
                      hint: 'user_123',
                      helperText:
                          'Unique within your tenant. Cannot be changed later.',
                      enabled: !_submitting,
                      autofocus: widget.prefillExternalId == null,
                      validator: (v) =>
                          Validators.required(v, field: 'External ID') ??
                          Validators.maxLength(v, 255, field: 'External ID'),
                      errorText: validation?.firstMessageForLeaf('external_id'),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _emailController,
                      label: 'Email (optional)',
                      hint: 'user@example.com',
                      helperText: 'Required for email notifications. Can be added later.',
                      enabled: !_submitting,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.email,
                      errorText: validation?.firstMessageForLeaf('email'),
                    ),
                    if (_failure != null && validation == null) ...[
                      const SizedBox(height: 16),
                      _InlineError(message: FailureMessages.of(_failure!)),
                    ],
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: _submitting
                              ? null
                              : () => context.go(AppRoutes.users),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 12),
                        AppButton(
                          label: 'Create',
                          onPressed: _submit,
                          loading: _submitting,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: scheme.onErrorContainer, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: scheme.onErrorContainer, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
