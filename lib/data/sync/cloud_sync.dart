import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:drift/drift.dart';

import '../db/app_database.dart';
import '../settings/settings_store.dart';

/// 云同步账户信息。
class SyncUser {
  const SyncUser({required this.id, required this.email, this.displayName, this.role = 'user'});
  final String id;
  final String email;
  final String? displayName;
  final String role;

  Map<String, dynamic> toJson() => {'id': id, 'email': email, 'display_name': displayName, 'role': role};
  static SyncUser fromJson(Map<String, dynamic> j) => SyncUser(
        id: j['id'] as String,
        email: j['email'] as String,
        displayName: j['display_name'] as String?,
        role: (j['role'] as String?) ?? 'user',
      );
}

class SyncException implements Exception {
  const SyncException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;
  bool get unauthorized => statusCode == 401;
  @override
  String toString() => message;
}

/// 构建时从 .env 注入的默认服务器与证书指纹（自签证书时 App 内固定校验）。
const envSyncServer = String.fromEnvironment('SYNC_SERVER_URL');
const envSyncCertSha256 = String.fromEnvironment('SYNC_CERT_SHA256');

/// 规范化证书指纹：去掉冒号与空白，转小写。
String normalizeFingerprint(String s) => s.replaceAll(RegExp(r'[\s:]'), '').toLowerCase();

/// 同步服务器 HTTP 客户端。自签证书时只信任与 [certSha256] 指纹一致的证书。
Dio createSyncDio(String baseUrl, {String? certSha256}) {
  final dio = Dio(BaseOptions(
    baseUrl: baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 60),
    contentType: 'application/json',
  ));
  final pin = certSha256 == null || certSha256.isEmpty ? null : normalizeFingerprint(certSha256);
  if (pin != null) {
    dio.httpClientAdapter = IOHttpClientAdapter(createHttpClient: () {
      final c = HttpClient();
      c.badCertificateCallback = (cert, host, port) => sha256.convert(cert.der).toString() == pin;
      return c;
    });
  }
  return dio;
}

/// 云同步（spec 5.6）：本地优先，按 updated_at 增量推送，按服务器 seq 增量拉取，last-write-wins。
///
/// 所有带 SyncColumns 的表参与同步（附件文件不同步）；代码表、交易日历、K 线缓存、本机设置不同步。
class CloudSync {
  CloudSync({
    required this.db,
    required this.settings,
    required this.secrets,
    Dio Function(String url, String? cert)? dioFactory,
    DateTime Function()? now,
  })  : _dioFactory = dioFactory ?? ((u, c) => createSyncDio(u, certSha256: c)),
        _now = now ?? DateTime.now;

  final AppDatabase db;
  final SettingsStore settings;
  final SecretStore secrets;
  final Dio Function(String url, String? cert) _dioFactory;
  final DateTime Function() _now;

  static const _kServer = 'sync.server';
  static const _kCert = 'sync.cert_sha256';
  static const _kUser = 'sync.user';
  static const _kCursor = 'sync.cursor';
  static const _kLastSync = 'sync.last_sync_at';
  static const _kSyncedUser = 'sync.synced_user_id';
  static const _kAccess = 'sync_access_token';
  static const _kRefresh = 'sync_refresh_token';
  static const _batch = 500;

  /// 参与同步的表（按依赖顺序无要求：各表独立，外键为软关联）。
  List<TableInfo<Table, dynamic>> get tables => [
        db.journalEntries,
        db.marketSnapshots,
        db.quickPhrases,
        db.entryTemplates,
        db.predictions,
        db.predictionResults,
        db.reviewNotes,
        db.thresholdRules,
        db.revisions,
        db.aiAnalyses,
        db.accounts,
        db.trades,
        db.positionSnapshots,
        db.importBatches,
        db.columnMappings,
        db.agentThreads,
        db.agentMessages,
        db.agentMemories,
      ];

  // ───────────── 配置与账户 ─────────────

  Future<String> server() async => await settings.raw(_kServer) ?? envSyncServer;
  Future<String> certSha256() async => await settings.raw(_kCert) ?? envSyncCertSha256;

  Future<void> setServer(String url, {String? cert}) async {
    await settings.setRaw(_kServer, url.trim());
    if (cert != null) await settings.setRaw(_kCert, cert.trim());
  }

  Future<SyncUser?> user() async {
    final raw = await settings.raw(_kUser);
    if (raw == null || raw.isEmpty) return null;
    return SyncUser.fromJson((jsonDecode(raw) as Map).cast<String, dynamic>());
  }

  Future<DateTime?> lastSyncAt() async {
    final v = int.tryParse(await settings.raw(_kLastSync) ?? '');
    return v == null ? null : DateTime.fromMillisecondsSinceEpoch(v, isUtc: true);
  }

  Future<Dio> _dio() async {
    final url = await server();
    if (url.isEmpty) throw const SyncException('未设置同步服务器地址');
    final cert = await certSha256();
    return _dioFactory(url, cert.isEmpty ? null : cert);
  }

  SyncException _wrap(DioException e) {
    final code = e.response?.statusCode;
    final data = e.response?.data;
    final detail = data is Map ? data['detail']?.toString() : null;
    if (detail != null) return SyncException(detail, statusCode: code);
    if (e.type == DioExceptionType.badCertificate || e.error is HandshakeException) {
      return const SyncException('服务器证书校验失败（证书指纹不匹配）');
    }
    if (code == null) return SyncException('无法连接同步服务器：${e.message ?? e.type.name}');
    return SyncException('同步服务器错误（$code）', statusCode: code);
  }

  /// 本机是否已有数据（登录新账户时提示合并）。
  Future<bool> hasLocalData() async {
    for (final t in ['journal_entries', 'trades', 'predictions', 'ai_analyses']) {
      final r = await db.customSelect('SELECT 1 FROM $t LIMIT 1').get();
      if (r.isNotEmpty) return true;
    }
    return false;
  }

  /// 上次同步的账户（与本次登录账户不同时需确认合并）。
  Future<String?> syncedUserId() => settings.raw(_kSyncedUser);

  Future<SyncUser> _authenticate(String path, Map<String, dynamic> body) async {
    final dio = await _dio();
    try {
      final r = await dio.post<Map<String, dynamic>>(path, data: body);
      final d = r.data!;
      await secrets.write(_kAccess, d['access_token'] as String);
      await secrets.write(_kRefresh, d['refresh_token'] as String);
      final u = SyncUser.fromJson((d['user'] as Map).cast<String, dynamic>());
      await settings.setRaw(_kUser, jsonEncode(u.toJson()));
      // 换了账户：从头同步
      if (await syncedUserId() != u.id) {
        await _resetCursors();
        await settings.setRaw(_kSyncedUser, u.id);
      }
      return u;
    } on DioException catch (e) {
      throw _wrap(e);
    }
  }

  Future<SyncUser> login(String email, String password, {String deviceName = 'StockNote'}) =>
      _authenticate('/api/auth/login', {'email': email, 'password': password, 'device_name': deviceName});

  Future<SyncUser> register(String email, String password, {String? displayName, String deviceName = 'StockNote'}) =>
      _authenticate('/api/auth/register',
          {'email': email, 'password': password, 'display_name': displayName, 'device_name': deviceName});

  /// 退出登录：本机数据保留，停止同步。
  Future<void> logout() async {
    final rt = await secrets.read(_kRefresh);
    if (rt != null) {
      try {
        await (await _dio()).post('/api/auth/logout', data: {'refresh_token': rt});
      } catch (_) {
        // 离线也允许退出
      }
    }
    await secrets.write(_kAccess, null);
    await secrets.write(_kRefresh, null);
    await settings.setRaw(_kUser, '');
  }

  Future<void> _resetCursors() async {
    await settings.setRaw(_kCursor, '0');
    for (final t in tables) {
      await settings.setRaw('sync.pushed.${t.actualTableName}', '0');
    }
  }

  /// 带令牌请求；访问令牌过期时用刷新令牌续期一次。
  Future<Response<T>> _authed<T>(Future<Response<T>> Function(Dio dio, Options o) send) async {
    final dio = await _dio();
    Options opts(String? t) => Options(headers: {'Authorization': 'Bearer ${t ?? ''}'});
    try {
      return await send(dio, opts(await secrets.read(_kAccess)));
    } on DioException catch (e) {
      if (e.response?.statusCode != 401) throw _wrap(e);
    }
    final rt = await secrets.read(_kRefresh);
    if (rt == null) throw const SyncException('请重新登录', statusCode: 401);
    try {
      final r = await dio.post<Map<String, dynamic>>('/api/auth/refresh', data: {'refresh_token': rt});
      await secrets.write(_kAccess, r.data!['access_token'] as String);
      await secrets.write(_kRefresh, r.data!['refresh_token'] as String);
    } on DioException catch (e) {
      final err = _wrap(e);
      throw SyncException(err.unauthorized ? '登录已过期，请重新登录' : err.message, statusCode: err.statusCode);
    }
    try {
      return await send(dio, opts(await secrets.read(_kAccess)));
    } on DioException catch (e) {
      throw _wrap(e);
    }
  }

  // ───────────── 同步 ─────────────

  /// 先推送本地改动，再拉取服务器改动。返回 (推送条数, 拉取条数)。
  Future<(int, int)> sync() async {
    if (await user() == null) throw const SyncException('未登录');
    final started = _now().millisecondsSinceEpoch;
    final lastSync = int.tryParse(await settings.raw(_kLastSync) ?? '') ?? 0;
    final pushed = await _push();
    final pulled = await _pull(lastSync);
    await settings.setRaw(_kLastSync, '$started');
    return (pushed, pulled);
  }

  Future<int> _push() async {
    var total = 0;
    for (final t in tables) {
      final name = t.actualTableName;
      final key = 'sync.pushed.$name';
      var wm = int.tryParse(await settings.raw(key) ?? '') ?? 0;
      var lastId = '';
      while (true) {
        final rows = await db.customSelect(
          'SELECT * FROM $name WHERE updated_at > ? OR (updated_at = ? AND id > ?) ORDER BY updated_at, id LIMIT ?',
          variables: [Variable.withInt(wm), Variable.withInt(wm), Variable.withString(lastId), Variable.withInt(_batch)],
        ).get();
        if (rows.isEmpty) break;
        await _authed((dio, o) => dio.post('/api/sync/push',
            options: o,
            data: {
              'changes': [for (final r in rows) {'tbl': name, 'data': r.data}],
            }));
        total += rows.length;
        wm = rows.last.data['updated_at'] as int;
        lastId = rows.last.data['id'] as String;
        if (rows.length < _batch) break;
      }
      // 水位线用 >= 语义保存（同毫秒的行下次会被重复推送，服务器判为相同不写入）
      await settings.setRaw(key, '${wm > 0 ? wm - 1 : 0}');
    }
    return total;
  }

  Future<int> _pull(int lastSync) async {
    var cursor = int.tryParse(await settings.raw(_kCursor) ?? '') ?? 0;
    final byName = {for (final t in tables) t.actualTableName: t};
    final columns = {
      for (final t in tables) t.actualTableName: {for (final c in t.$columns) c.name},
    };
    final touched = <TableInfo<Table, dynamic>>{};
    var total = 0;
    while (true) {
      final r = await _authed<Map<String, dynamic>>(
          (dio, o) => dio.get('/api/sync/pull', options: o, queryParameters: {'since': cursor, 'limit': _batch}));
      final body = r.data!;
      final changes = (body['changes'] as List).cast<Map>();
      await db.transaction(() async {
        for (final ch in changes) {
          final name = ch['tbl'] as String;
          final table = byName[name];
          if (table == null) continue; // 新版本才有的表
          final data = (ch['data'] as Map).cast<String, dynamic>();
          if (await _apply(table, columns[name]!, data, lastSync)) touched.add(table);
        }
      });
      total += changes.length;
      cursor = body['cursor'] as int;
      await settings.setRaw(_kCursor, '$cursor');
      if (body['has_more'] != true) break;
    }
    if (touched.isNotEmpty) {
      db.notifyUpdates({for (final t in touched) TableUpdate.onTable(t)});
    }
    return total;
  }

  /// 应用一行服务器数据。本地更新时更晚则保留本地（下次推送）。
  Future<bool> _apply(TableInfo<Table, dynamic> table, Set<String> cols, Map<String, dynamic> data, int lastSync) async {
    final name = table.actualTableName;
    final id = data['id'] as String?;
    final incomingAt = (data['updated_at'] as num?)?.toInt() ?? 0;
    if (id == null) return false;
    final local = await db
        .customSelect('SELECT * FROM $name WHERE id = ?', variables: [Variable.withString(id)])
        .getSingleOrNull();
    if (local != null) {
      final localAt = local.data['updated_at'] as int;
      if (localAt >= incomingAt) return false;
      // 本地在上次同步后也改过：被覆盖的本地版本写入修改历史，不丢数据
      if (localAt > lastSync && name != 'revisions') {
        await _recordConflict(name, local.data);
      }
    }
    final keys = data.keys.where(cols.contains).toList();
    await db.customStatement(
      'INSERT OR REPLACE INTO $name (${keys.join(', ')}) VALUES (${List.filled(keys.length, '?').join(', ')})',
      [for (final k in keys) data[k]],
    );
    return true;
  }

  Future<void> _recordConflict(String table, Map<String, dynamic> before) async {
    final entity = switch (table) {
      'journal_entries' => 'journal_entry',
      'predictions' => 'prediction',
      'trades' => 'trade',
      _ => table,
    };
    final now = _now().millisecondsSinceEpoch;
    final last = await db.customSelect(
      'SELECT MAX(revision_no) AS n FROM revisions WHERE entity_type = ? AND entity_id = ?',
      variables: [Variable.withString(entity), Variable.withString(before['id'] as String)],
    ).getSingle();
    await db.into(db.revisions).insert(RevisionsCompanion.insert(
          id: 'conflict-${before['id']}-$now',
          createdAt: now,
          updatedAt: now,
          deviceId: await db.deviceId(),
          entityType: entity,
          entityId: before['id'] as String,
          revisionNo: ((last.data['n'] as int?) ?? 0) + 1,
          before: before,
          changedFields: const ['sync_conflict'],
          ts: now,
        ));
  }
}
