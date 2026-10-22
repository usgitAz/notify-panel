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
import '../../domain/entities/device.dart';
import '../../domain/usecases/register_device_usecase.dart';
import '../providers/device_providers.dart';

class RegisterDevicePage extends ConsumerStatefulWidget {
  const RegisterDevicePage({required this.externalId, super.key});

  final String externalId;

  @override
  ConsumerState<RegisterDevicePage> createState() => _RegisterDevicePageState();
}

class _RegisterDevicePageState extends ConsumerState<RegisterDevicePage> {
  final _formKey = GlobalKey<FormState>();
  final _tokenController = TextEditingController();
  final _nameController = TextEditingController();

  DevicePlatform _platform = DevicePlatform.ios;
  bool _submitting = false;
  Failure? _failure;

  @override
  void dispose() {
    _tokenController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _submitting = true;
      _failure = null;
    });

    final name = _nameController.text.trim();
    final result = await ref
        .read(registerDeviceUseCaseProvider)
        .call(
          RegisterDeviceParams(
            externalId: widget.externalId,
            platform: _platform,
            provider: PushProvider.fcm,
            token: _tokenController.text.trim(),
            deviceName: name.isEmpty ? null : name,
          ),
        );

    if (!mounted) return;
    setState(() => _submitting = false);

    result.match((failure) => setState(() => _failure = failure), (device) {
      ref.invalidate(deviceListProvider(widget.externalId));
      AppSnackbar.success(context, 'Device registered.');
      context.go(AppRoutes.userDetailPath(widget.externalId));
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final validation = _failure is ValidationFailure
        ? _failure as ValidationFailure
        : null;

    return SingleChildScrollView(
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
                          onPressed: () => context.go(
                            AppRoutes.userDetailPath(widget.externalId),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Register device',
                          style: theme.textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(left: 48),
                      child: Text(
                        'for user "${widget.externalId}"',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Platform
                    DropdownButtonFormField<DevicePlatform>(
                      initialValue: _platform,
                      decoration: const InputDecoration(labelText: 'Platform'),
                      items: const [
                        DropdownMenuItem(
                          value: DevicePlatform.ios,
                          child: Text('iOS'),
                        ),
                        DropdownMenuItem(
                          value: DevicePlatform.android,
                          child: Text('Android'),
                        ),
                        DropdownMenuItem(
                          value: DevicePlatform.web,
                          child: Text('Web'),
                        ),
                      ],
                      onChanged: _submitting
                          ? null
                          : (v) => v == null
                                ? null
                                : setState(() => _platform = v),
                    ),
                    const SizedBox(height: 16),

                    // FCM token
                    AppTextField(
                      controller: _tokenController,
                      label: 'FCM token',
                      hint: 'fcm_token_...',
                      helperText:
                          'Token generated by the Firebase SDK on the device.',
                      enabled: !_submitting,
                      validator: (v) =>
                          Validators.required(v, field: 'FCM token'),
                      errorText: validation?.firstMessageForLeaf('token'),
                    ),
                    const SizedBox(height: 16),

                    // Device name
                    AppTextField(
                      controller: _nameController,
                      label: 'Device name (optional)',
                      hint: 'e.g. iPhone 15 Pro',
                      maxLength: 100,
                      enabled: !_submitting,
                      validator: (v) =>
                          Validators.maxLength(v, 100, field: 'Device name'),
                      errorText: validation?.firstMessageForLeaf('device_name'),
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
                              : () => context.go(
                                  AppRoutes.userDetailPath(widget.externalId),
                                ),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 12),
                        AppButton(
                          label: 'Register',
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
