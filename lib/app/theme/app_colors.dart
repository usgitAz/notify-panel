import 'package:flutter/material.dart';

/// Semantic colors that differ between light and dark modes.
/// Access via `Theme.of(context).extension<AppStatusColors>()!`.
@immutable
class AppStatusColors extends ThemeExtension<AppStatusColors> {
  final Color pending;
  final Color pendingSurface;
  final Color delivered;
  final Color deliveredSurface;
  final Color failed;
  final Color failedSurface;
  final Color info;

  const AppStatusColors({
    required this.pending,
    required this.pendingSurface,
    required this.delivered,
    required this.deliveredSurface,
    required this.failed,
    required this.failedSurface,
    required this.info,
  });

  static const light = AppStatusColors(
    pending: Color(0xFFB45309),
    pendingSurface: Color(0xFFFEF3C7),
    delivered: Color(0xFF047857),
    deliveredSurface: Color(0xFFD1FAE5),
    failed: Color(0xFFB91C1C),
    failedSurface: Color(0xFFFEE2E2),
    info: Color(0xFF1D4ED8),
  );

  static const dark = AppStatusColors(
    pending: Color(0xFFFBBF24),
    pendingSurface: Color(0xFF422006),
    delivered: Color(0xFF34D399),
    deliveredSurface: Color(0xFF022C22),
    failed: Color(0xFFF87171),
    failedSurface: Color(0xFF450A0A),
    info: Color(0xFF60A5FA),
  );

  @override
  AppStatusColors copyWith({
    Color? pending,
    Color? pendingSurface,
    Color? delivered,
    Color? deliveredSurface,
    Color? failed,
    Color? failedSurface,
    Color? info,
  }) {
    return AppStatusColors(
      pending: pending ?? this.pending,
      pendingSurface: pendingSurface ?? this.pendingSurface,
      delivered: delivered ?? this.delivered,
      deliveredSurface: deliveredSurface ?? this.deliveredSurface,
      failed: failed ?? this.failed,
      failedSurface: failedSurface ?? this.failedSurface,
      info: info ?? this.info,
    );
  }

  @override
  AppStatusColors lerp(AppStatusColors? other, double t) {
    if (other == null) return this;
    return AppStatusColors(
      pending: Color.lerp(pending, other.pending, t)!,
      pendingSurface: Color.lerp(pendingSurface, other.pendingSurface, t)!,
      delivered: Color.lerp(delivered, other.delivered, t)!,
      deliveredSurface: Color.lerp(
        deliveredSurface,
        other.deliveredSurface,
        t,
      )!,
      failed: Color.lerp(failed, other.failed, t)!,
      failedSurface: Color.lerp(failedSurface, other.failedSurface, t)!,
      info: Color.lerp(info, other.info, t)!,
    );
  }
}
