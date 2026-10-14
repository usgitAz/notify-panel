import 'package:flutter/material.dart';

import '../../core/error/failure.dart';
import '../../core/error/failure_messages.dart';

/// Displays a [Failure] with a friendly message and an optional retry.
class ErrorView extends StatelessWidget {
  const ErrorView({required this.failure, this.onRetry, super.key});

  final Failure failure;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final message = FailureMessages.of(failure);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_iconFor(failure), size: 56, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconFor(Failure failure) => switch (failure) {
    NetworkFailure() => Icons.wifi_off_outlined,
    AuthFailure() => Icons.lock_outline,
    NotFoundFailure() => Icons.search_off_outlined,
    ServerFailure() => Icons.cloud_off_outlined,
    _ => Icons.error_outline,
  };
}
