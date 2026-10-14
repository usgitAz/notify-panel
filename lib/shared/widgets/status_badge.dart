import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Colored pill for statuses (notification, user, device).
///
/// Uses semantic colors from [AppStatusColors] so light/dark mode
/// and future palette changes stay in one place.
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    required this.label,
    required this.tone,
    this.icon,
    this.compact = false,
    super.key,
  });

  final String label;
  final StatusTone tone;
  final IconData? icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final status = Theme.of(context).extension<AppStatusColors>()!;
    final (fg, bg) = switch (tone) {
      StatusTone.pending => (status.pending, status.pendingSurface),
      StatusTone.delivered => (status.delivered, status.deliveredSurface),
      StatusTone.failed => (status.failed, status.failedSurface),
      StatusTone.info => (status.info, status.info.withValues(alpha: 0.12)),
      StatusTone.neutral => (
        Theme.of(context).colorScheme.onSurfaceVariant,
        Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: compact ? 12 : 14, color: fg),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

enum StatusTone { pending, delivered, failed, info, neutral }
