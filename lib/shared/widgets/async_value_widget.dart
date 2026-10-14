import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/error/failure.dart';
import 'error_view.dart';
import 'loading_indicator.dart';

/// Renders an [AsyncValue] as loading / error / data.
///
/// Centralizes the loading-spinner + retry pattern used across the app,
/// so screens don't reimplement it.
class AsyncValueWidget<T> extends StatelessWidget {
  const AsyncValueWidget({
    required this.value,
    required this.data,
    this.onRetry,
    this.loadingLabel,
    super.key,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final VoidCallback? onRetry;
  final String? loadingLabel;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      loading: () => LoadingIndicator(label: loadingLabel),
      error: (err, _) {
        final failure = err is Failure
            ? err
            : UnknownFailure(message: err.toString());
        return ErrorView(failure: failure, onRetry: onRetry);
      },
    );
  }
}
