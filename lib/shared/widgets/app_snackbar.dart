import 'package:flutter/material.dart';

/// Convenience helpers for showing consistent snackbars.
abstract final class AppSnackbar {
  const AppSnackbar._();

  static void success(BuildContext context, String message) =>
      _show(context, message, _Kind.success);

  static void error(BuildContext context, String message) =>
      _show(context, message, _Kind.error);

  static void info(BuildContext context, String message) =>
      _show(context, message, _Kind.info);

  static void _show(BuildContext context, String message, _Kind kind) {
    final scheme = Theme.of(context).colorScheme;
    final icon = switch (kind) {
      _Kind.success => Icons.check_circle_outline,
      _Kind.error => Icons.error_outline,
      _Kind.info => Icons.info_outline,
    };
    final color = switch (kind) {
      _Kind.success => scheme.primary,
      _Kind.error => scheme.error,
      _Kind.info => scheme.tertiary,
    };

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      );
  }
}

enum _Kind { success, error, info }
