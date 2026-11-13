import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../db/app_database.dart';
import '../market/sources.dart';

/// 敏感凭证存储（API Key / token）。生产用系统安全存储，测试用内存实现。
abstract class SecretStore {
  Future<String?> read(String key);
  Future<void> write(String key, String? value);
}

class SecureSecretStore implements SecretStore {
  const SecureSecretStore();
  static const _storage = FlutterSecureStorage();

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String? value) => value == null || value.isEmpty
      ? _storage.delete(key: key)
      : _storage.write(key: key, value: value);
}

class MemorySecretStore implements SecretStore {
  MemorySecretStore([Map<String, String>? initial]) : _m = {...?initial};
  final Map<String, String> _m;

  @override
  Future<String?> read(String key) async => _m[key];

  @override
  Future<void> write(String key, String? value) async =>
      value == null || value.isEmpty ? _m.remove(key) : _m[key] = value;
}

abstract final class SecretKeys {
  static const tushareToken = 'tushare_token';
}

/// 非敏感偏好，存 app_meta 表（JSON 值）。
class SettingsStore {
  SettingsStore(this._db);

  final AppDatabase _db;

  static const _refreshKey = 'market.refresh_seconds';
  static const _priorityKey = 'market.source_priority';
  static const _lastSyncKey = 'sync.base_data_date';

  Future<String?> _get(String key) async =>
      (await (_db.select(_db.appMeta)..where((t) => t.key.equals(key))).getSingleOrNull())
          ?.value;

  Future<void> _set(String key, String value) => _db
      .into(_db.appMeta)
      .insertOnConflictUpdate(AppMetaCompanion.insert(key: key, value: value));

  /// 指数刷新间隔（秒），交易时段内使用。默认 5 秒。
  Future<int> refreshSeconds() async => int.tryParse(await _get(_refreshKey) ?? '') ?? 5;
  Future<void> setRefreshSeconds(int s) => _set(_refreshKey, '${s.clamp(3, 60)}');

  Future<Map<Capability, List<SourceId>>> sourcePriority() async {
    final raw = await _get(_priorityKey);
    if (raw == null) return {};
    final map = (jsonDecode(raw) as Map).cast<String, dynamic>();
    final out = <Capability, List<SourceId>>{};
    for (final e in map.entries) {
      final cap = Capability.values.where((c) => c.name == e.key).firstOrNull;
      if (cap == null) continue;
      out[cap] = [
        for (final s in (e.value as List).cast<String>()) ?SourceId.fromCode(s),
      ];
    }
    return out;
  }

  Future<void> setSourcePriority(Map<Capability, List<SourceId>> p) => _set(
      _priorityKey,
      jsonEncode({for (final e in p.entries) e.key.name: e.value.map((s) => s.code).toList()}));

  static const _watchlistKey = 'market.watchlist';

  Future<List<String>> watchlist() async {
    final raw = await _get(_watchlistKey);
    return raw == null ? [] : (jsonDecode(raw) as List).cast<String>();
  }

  Future<void> setWatchlist(List<String> codes) => _set(_watchlistKey, jsonEncode(codes));

  static const _defaultIndexKey = 'verify.default_index';

  /// 大盘 / 指数判断未关联标的时的默认判定指数，null 表示用内置默认（上证指数）。
  Future<String?> defaultIndex() => _get(_defaultIndexKey);
  Future<void> setDefaultIndex(String code) => _set(_defaultIndexKey, code);

  Future<String?> lastBaseSyncDate() => _get(_lastSyncKey);
  Future<void> setLastBaseSyncDate(String yyyymmdd) => _set(_lastSyncKey, yyyymmdd);
}

