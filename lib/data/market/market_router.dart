import 'dart:async';

import 'sources.dart';

/// 单个数据源的健康状态（设置页展示）。
class SourceHealth {
  int successes = 0;
  int failures = 0;
  int consecutiveFailures = 0;
  DateTime? lastSuccess;
  DateTime? lastFailure;
  String? lastError;
  Duration? lastLatency;

  /// 熔断截止时间：在此之前跳过该源。
  DateTime? cooldownUntil;

  bool get healthy => consecutiveFailures == 0;
}

/// 所有数据源都失败时抛出。
class AllSourcesFailed implements Exception {
  AllSourcesFailed(this.capability, this.errors);
  final Capability capability;
  final Map<SourceId, Object> errors;

  @override
  String toString() =>
      '${capability.label}获取失败：${errors.entries.map((e) => '${e.key.label}(${e.value})').join('；')}';
}

/// 按能力路由到数据源：按优先级尝试，失败自动 fallback，连续失败的源指数退避（spec 5.3）。
class MarketRouter {
  MarketRouter(
    this.sources, {
    this.priority = const {},
    this.timeout = const Duration(seconds: 8),
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final List<MarketSource> sources;
  final Map<Capability, List<SourceId>> priority;
  final Duration timeout;
  final DateTime Function() _now;
  final Map<SourceId, SourceHealth> health = {};

  static const _baseCooldown = Duration(seconds: 15);
  static const _maxCooldown = Duration(minutes: 5);

  /// 某能力的默认优先级。
  static const defaultPriority = <Capability, List<SourceId>>{
    Capability.quotes: [SourceId.eastmoney, SourceId.tencent],
    Capability.intraday: [SourceId.eastmoney, SourceId.tencent],
    Capability.dailyKline: [SourceId.tushare, SourceId.eastmoney, SourceId.tencent],
    Capability.instruments: [SourceId.tushare, SourceId.eastmoney],
    Capability.calendar: [SourceId.tushare],
  };

  /// 某能力当前的有效顺序：用户配置 → 默认 → 其余支持该能力的源。
  List<MarketSource> orderFor(Capability c) {
    final supporting = sources.where((s) => s.capabilities.contains(c)).toList();
    final pref = priority[c] ?? defaultPriority[c] ?? const [];
    int rank(MarketSource s) {
      final i = pref.indexOf(s.id);
      return i < 0 ? pref.length + sources.indexOf(s) : i;
    }

    supporting.sort((a, b) => rank(a).compareTo(rank(b)));
    return supporting;
  }

  SourceHealth healthOf(SourceId id) => health.putIfAbsent(id, SourceHealth.new);

  Future<T> call<T>(Capability c, Future<T> Function(MarketSource s) fn) async {
    final errors = <SourceId, Object>{};
    final candidates = orderFor(c).where((s) => s.isAvailable).toList();
    if (candidates.isEmpty) {
      throw AllSourcesFailed(c, {});
    }
    // 先试不在熔断期的源；若全部熔断，仍按顺序尝试（避免永远拿不到数据）。
    final now = _now();
    final ready = candidates
        .where((s) => healthOf(s.id).cooldownUntil?.isAfter(now) != true)
        .toList();
    final order = ready.isEmpty ? candidates : ready;

    for (final s in order) {
      final h = healthOf(s.id);
      final started = _now();
      try {
        final result = await fn(s).timeout(timeout);
        h
          ..successes += 1
          ..consecutiveFailures = 0
          ..cooldownUntil = null
          ..lastSuccess = _now()
          ..lastLatency = _now().difference(started);
        return result;
      } on UnsupportedRequest catch (e) {
        errors[s.id] = e.message;
      } catch (e) {
        h
          ..failures += 1
          ..consecutiveFailures += 1
          ..lastFailure = _now()
          ..lastError = _describe(e);
        final factor = 1 << (h.consecutiveFailures - 1).clamp(0, 5);
        final cd = _baseCooldown * factor;
        h.cooldownUntil = _now().add(cd > _maxCooldown ? _maxCooldown : cd);
        errors[s.id] = h.lastError!;
      }
    }
    throw AllSourcesFailed(c, errors);
  }

  static String _describe(Object e) {
    final s = e.toString();
    if (e is TimeoutException) return '超时';
    if (s.contains('Connection closed') || s.contains('connection abort')) return '连接被断开（可能被限流）';
    return s.length > 120 ? '${s.substring(0, 120)}…' : s;
  }
}


