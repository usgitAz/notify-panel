import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/storage_keys.dart';
import 'core_providers.dart';

/// Initial theme mode, loaded synchronously from SharedPreferences
/// in `main()` and injected via override.
///
/// Must be overridden before `runApp`.
final initialThemeModeProvider = Provider<ThemeMode>(
  (ref) => throw UnimplementedError(
    'initialThemeModeProvider must be overridden in main()',
  ),
);

/// Holds the current [ThemeMode] and persists changes.
class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ref.watch(initialThemeModeProvider);

  Future<void> set(ThemeMode mode) async {
    state = mode;
    await ref
        .read(preferencesStorageProvider)
        .setString(StorageKeys.themeMode, mode.name);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>(
  ThemeModeController.new,
);
