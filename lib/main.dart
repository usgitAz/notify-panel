import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/constants/storage_keys.dart';
import 'core/providers/core_providers.dart';
import 'core/providers/theme_provider.dart';
import 'core/storage/secure_storage_impl.dart';
import 'features/auth/data/datasources/auth_local_datasource.dart';
import 'features/auth/presentation/providers/auth_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final theme = _parseThemeMode(prefs.getString(StorageKeys.themeMode));

  // Read persisted session synchronously at boot so AuthNotifier.build()
  // can stay synchronous (no splash screen needed).
  final secureStorage = SecureStorageImpl(const FlutterSecureStorage());
  final session = await AuthLocalDataSource(secureStorage).read();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        initialThemeModeProvider.overrideWithValue(theme),
        initialSessionProvider.overrideWithValue(session),
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
