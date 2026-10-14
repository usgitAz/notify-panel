import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/constants/storage_keys.dart';
import 'core/providers/core_providers.dart';
import 'core/providers/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final initialTheme = _parseThemeMode(prefs.getString(StorageKeys.themeMode));

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        initialThemeModeProvider.overrideWithValue(initialTheme),
      ],
      child: const NotifyPanelApp(),
    ),
  );
}

ThemeMode _parseThemeMode(String? value) => switch (value) {
  'light' => ThemeMode.light,
  'dark' => ThemeMode.dark,
  _ => ThemeMode.system,
};
