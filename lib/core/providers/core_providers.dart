import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/dio_client.dart';
import '../storage/preferences_storage.dart';
import '../storage/preferences_storage_impl.dart';
import '../storage/secure_storage.dart';
import '../storage/secure_storage_impl.dart';
import 'api_key_holder.dart';

// ─── Main bootstrap ───

/// Must be overridden in `main.dart` after `SharedPreferences.getInstance()`.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main()',
  ),
);

// ─── Storage ───

final flutterSecureStorageProvider = Provider<FlutterSecureStorage>(
  (ref) => const FlutterSecureStorage(),
);

final secureStorageProvider = Provider<SecureStorage>(
  (ref) => SecureStorageImpl(ref.watch(flutterSecureStorageProvider)),
);

final preferencesStorageProvider = Provider<PreferencesStorage>(
  (ref) => PreferencesStorageImpl(ref.watch(sharedPreferencesProvider)),
);

// ─── API key holder ───

final apiKeyHolderProvider = Provider<ApiKeyHolder>((ref) => ApiKeyHolder());

// ─── Dio ───
final dioProvider = Provider<Dio>((ref) {
  final holder = ref.watch(apiKeyHolderProvider);
  return DioClient.create(
    getApiKey: () => holder.value,
    onUnauthorized: holder.notifyUnauthorized,
  );
});
