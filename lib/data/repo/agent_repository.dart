import 'dart:convert';

import 'package:drift/drift.dart';

import '../../core/ids.dart';
import '../db/app_database.dart';

/// 记忆分类（spec 3.5.3）。
enum MemoryKind {
  style('style', '交易风格'),
  rule('rule', '个人规则'),
  preference('preference', '偏好'),
  lesson('lesson', '经验教训'),
  watch('watch', '关注标的'),
  fact('fact', '其他事实');

  const MemoryKind(this.code, this.label);
  final String code;
  final String label;

  static MemoryKind fromCode(String? c) => values.firstWhere((k) => k.code == c, orElse: () => fact);
}

/// Agent 会话、消息与长期记忆（spec 3.5）。
class AgentRepository {
  AgentRepository(this._db, {DateTime Function()? now}) : _now = now ?? DateTime.now;
  final AppDatabase _db;
  final DateTime Function() _now;

  int get _ms => _now().millisecondsSinceEpoch;

  // ───────────── 会话 ─────────────

  Stream<List<AgentThread>> watchThreads() => (_db.select(_db.agentThreads)
        ..where((t) => t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.desc(t.pinned), (t) => OrderingTerm.desc(t.lastMessageAt)]))
      .watch();

  Future<AgentThread?> thread(String id) =>
      (_db.select(_db.agentThreads)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<AgentThread> createThread({String title = '新对话'}) async =>
      _db.into(_db.agentThreads).insertReturning(AgentThreadsCompanion.insert(
            id: newId(),
            createdAt: _ms,
            updatedAt: _ms,
            deviceId: await _db.deviceId(),
            title: title,
            lastMessageAt: _ms,
          ));

  Future<void> updateThread(String id,
      {String? title, bool? pinned, Value<String?> summary = const Value.absent(),
      Value<String?> summaryUpto = const Value.absent()}) async {
    await (_db.update(_db.agentThreads)..where((t) => t.id.equals(id))).write(AgentThreadsCompanion(
      title: title == null ? const Value.absent() : Value(title),
      pinned: pinned == null ? const Value.absent() : Value(pinned),
      summary: summary,
      summaryUptoMessageId: summaryUpto,
      updatedAt: Value(_ms),
    ));
  }

  Future<void> deleteThread(String id) => (_db.update(_db.agentThreads)..where((t) => t.id.equals(id)))
      .write(AgentThreadsCompanion(deletedAt: Value(_ms), updatedAt: Value(_ms)));

  // ───────────── 消息 ─────────────

  Stream<List<AgentMessage>> watchMessages(String threadId) => (_db.select(_db.agentMessages)
        ..where((m) => m.threadId.equals(threadId) & m.deletedAt.isNull())
        ..orderBy([(m) => OrderingTerm.asc(m.ts), (m) => OrderingTerm.asc(m.createdAt)]))
      .watch();

  Future<List<AgentMessage>> messages(String threadId) => (_db.select(_db.agentMessages)
        ..where((m) => m.threadId.equals(threadId) & m.deletedAt.isNull())
        ..orderBy([(m) => OrderingTerm.asc(m.ts), (m) => OrderingTerm.asc(m.createdAt)]))
      .get();

  /// 追加一条消息。[meta] 存在 toolCalls 列（assistant 的工具调用、tool 的摘要与确认卡片等）。
  Future<AgentMessage> addMessage(String threadId, String role, String content,
      {Map<String, dynamic>? meta, String? toolCallId, int? tokens}) async {
    // 同一毫秒写入多条时保持顺序
    final last = await (_db.select(_db.agentMessages)
          ..where((m) => m.threadId.equals(threadId))
          ..orderBy([(m) => OrderingTerm.desc(m.ts)])
          ..limit(1))
        .getSingleOrNull();
    final ts = last != null && last.ts >= _ms ? last.ts + 1 : _ms;
    final m = await _db.into(_db.agentMessages).insertReturning(AgentMessagesCompanion.insert(
          id: newId(),
          createdAt: ts,
          updatedAt: ts,
          deviceId: await _db.deviceId(),
          threadId: threadId,
          role: role,
          content: content,
          toolCalls: Value(meta == null ? null : jsonEncode(meta)),
          toolCallId: Value(toolCallId),
          ts: ts,
          tokens: Value(tokens),
        ));
    await (_db.update(_db.agentThreads)..where((t) => t.id.equals(threadId)))
        .write(AgentThreadsCompanion(lastMessageAt: Value(ts), updatedAt: Value(ts)));
    return m;
  }

  Future<void> updateMeta(String messageId, Map<String, dynamic> meta) =>
      (_db.update(_db.agentMessages)..where((m) => m.id.equals(messageId)))
          .write(AgentMessagesCompanion(toolCalls: Value(jsonEncode(meta)), updatedAt: Value(_ms)));

  // ───────────── 记忆 ─────────────

  Stream<List<AgentMemory>> watchMemories() => (_db.select(_db.agentMemories)
        ..where((m) => m.deletedAt.isNull())
        ..orderBy([
          (m) => OrderingTerm.desc(m.pinned),
          (m) => OrderingTerm.desc(m.importance),
          (m) => OrderingTerm.desc(m.updatedAt),
        ]))
      .watch();

  Future<List<AgentMemory>> activeMemories() => (_db.select(_db.agentMemories)
        ..where((m) => m.deletedAt.isNull() & m.status.equals('active')))
      .get();

  Future<AgentMemory> addMemory({
    required MemoryKind kind,
    required String content,
    String status = 'active',
    int importance = 3,
    String? sourceThreadId,
  }) async =>
      _db.into(_db.agentMemories).insertReturning(AgentMemoriesCompanion.insert(
            id: newId(),
            createdAt: _ms,
            updatedAt: _ms,
            deviceId: await _db.deviceId(),
            kind: kind.code,
            content: content.trim(),
            status: status,
            importance: Value(importance.clamp(1, 5)),
            sourceThreadId: Value(sourceThreadId),
          ));

  Future<void> updateMemory(String id,
      {String? content, MemoryKind? kind, String? status, bool? pinned, int? importance, int? lastUsedAt}) =>
      (_db.update(_db.agentMemories)..where((m) => m.id.equals(id))).write(AgentMemoriesCompanion(
        content: content == null ? const Value.absent() : Value(content.trim()),
        kind: kind == null ? const Value.absent() : Value(kind.code),
        status: status == null ? const Value.absent() : Value(status),
        pinned: pinned == null ? const Value.absent() : Value(pinned),
        importance: importance == null ? const Value.absent() : Value(importance.clamp(1, 5)),
        lastUsedAt: lastUsedAt == null ? const Value.absent() : Value(lastUsedAt),
        updatedAt: Value(_ms),
      ));

  Future<void> deleteMemory(String id) => (_db.update(_db.agentMemories)..where((m) => m.id.equals(id)))
      .write(AgentMemoriesCompanion(deletedAt: Value(_ms), updatedAt: Value(_ms)));

  /// 关键词检索（spec 3.5.3 MVP）：命中词数 + 置顶 + 重要度 + 最近使用。
  /// 中文按 2 字切分匹配，[query] 为空时按置顶 / 重要度排序。
  Future<List<AgentMemory>> searchMemories(String query, {String? kind, int limit = 8}) async {
    var list = await activeMemories();
    if (kind != null) list = list.where((m) => m.kind == kind).toList();
    final terms = memoryTerms(query);
    double score(AgentMemory m) {
      final hits = terms.where((t) => m.content.contains(t)).length;
      final recency = m.lastUsedAt == null ? 0 : (m.lastUsedAt! / 1e13);
      return hits * 10.0 + (m.pinned ? 5 : 0) + m.importance + recency;
    }

    final scored = [
      for (final m in list)
        if (terms.isEmpty || terms.any(m.content.contains)) (m, score(m)),
    ]..sort((a, b) => b.$2.compareTo(a.$2));
    return scored.take(limit).map((e) => e.$1).toList();
  }
}

/// 检索词：英文 / 数字按词，中文连续串切成 2 字片段。
Set<String> memoryTerms(String q) {
  final out = <String>{};
  for (final m in RegExp(r'[A-Za-z0-9.]+|[一-龥]+').allMatches(q)) {
    final w = m.group(0)!;
    if (RegExp(r'^[一-龥]+$').hasMatch(w)) {
      if (w.length <= 2) {
        out.add(w);
      } else {
        for (var i = 0; i + 2 <= w.length; i++) {
          out.add(w.substring(i, i + 2));
        }
      }
    } else if (w.length >= 2) {
      out.add(w.toUpperCase() == w ? w : w.toLowerCase());
    }
  }
  const stop = {'我的', '什么', '怎么', '一下', '现在', '今天', '这个', '那个', '可以', '是不', '不是'};
  return out.difference(stop);
}
