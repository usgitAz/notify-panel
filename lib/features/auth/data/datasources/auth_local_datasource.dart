import 'dart:convert';

import '../../../../core/constants/storage_keys.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../domain/entities/session.dart';
import '../models/tenant_dto.dart';

class AuthLocalDataSource {
  AuthLocalDataSource(this._storage);

  final SecureStorage _storage;

  Future<void> save(Session session) async {
    await _storage.write(StorageKeys.apiKey, session.apiKey);
    final tenantJson = jsonEncode(
      TenantDto.fromEntity(session.tenant).toJson(),
    );
    await _storage.write(StorageKeys.tenant, tenantJson);
  }

  Future<Session?> read() async {
    final apiKey = await _storage.read(StorageKeys.apiKey);
    if (apiKey == null || apiKey.isEmpty) return null;

    final tenantJson = await _storage.read(StorageKeys.tenant);
    if (tenantJson == null || tenantJson.isEmpty) return null;

    try {
      final tenantMap = jsonDecode(tenantJson) as Map<String, dynamic>;
      final tenant = TenantDto.fromJson(tenantMap).toEntity();
      return Session(apiKey: apiKey, tenant: tenant);
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() async {
    await _storage.delete(StorageKeys.apiKey);
    await _storage.delete(StorageKeys.tenant);
  }
}
