import '../../core/calendar/trading_calendar.dart';
import '../../core/time/market_clock.dart';
import '../../domain/journal/vocab.dart';
import '../db/app_database.dart';
import '../market/market_service.dart';
import '../market/models.dart';
import '../repo/ai_analysis_repository.dart';
import '../repo/journal_repository.dart';
import '../repo/prediction_repository.dart';
import '../settings/settings_store.dart';
import 'ai_settings.dart';
import 'llm.dart';

/// 分析结果中的展望（会生成 AI 判断）。
class AiOutlook {
  const AiOutlook({required this.target, required this.horizon, required this.direction, this.confidence});
  final String target;

  /// close | t1 | t3 | t5
  final String horizon;

  /// up | down | range
  final String direction;

  /// 0–1
  final double? confidence;
}

/// 解析后的结构化分析（spec 3.1.2 输出格式）。
class MarketAnalysis {
  const MarketAnalysis({
    this.sentimentScore,
    this.trend,
    this.support = const [],
    this.resistance = const [],
    this.highlights = const [],
    this.risks = const [],
    this.outlook,
    this.summary,
  });

  final int? sentimentScore;
  final String? trend;
  final List<double> support;
  final List<double> resistance;
  final List<String> highlights;
  final List<String> risks;
  final AiOutlook? outlook;
  final String? summary;

  static const trends = ['强势上涨', '震荡偏强', '震荡', '震荡偏弱', '弱势下跌'];

  static List<double> _nums(Object? v) =>
      v is List ? [for (final x in v) ?(x is num ? x.toDouble() : double.tryParse('$x'))] : const [];
  static List<String> _strs(Object? v) =>
      v is List ? [for (final x in v) if ('$x'.trim().isNotEmpty) '$x'.trim()] : const [];

  static String? _horizon(Object? v) {
    final s = '$v'.toLowerCase().replaceAll(' ', '');
    return switch (s) {
      'close' || 't+0' || 't0' || '今日' || '当日' => 'close',
      't1' || 't+1' || '次日' => 't1',
      't3' || 't+3' => 't3',
      't5' || 't+5' || '一周' => 't5',
      _ => null,
    };
  }

  static String? _direction(Object? v) => switch ('$v'.toLowerCase()) {
        'up' || 'bull' || '看多' || '上涨' => 'up',
        'down' || 'bear' || '看空' || '下跌' => 'down',
        'range' || 'flat' || 'sideways' || '震荡' => 'range',
        _ => null,
      };

  /// 解析模型输出；关键字段缺失时返回 null。
  static MarketAnalysis? fromJson(Map<String, dynamic> j) {
    final levels = j['key_levels'] is Map ? j['key_levels'] as Map : const {};
    AiOutlook? outlook;
    final o = j['outlook'];
    if (o is Map) {
      final h = _horizon(o['horizon']);
      final d = _direction(o['direction']);
      final c = o['confidence'];
      if (h != null && d != null) {
        outlook = AiOutlook(
          target: (o['target'] as String?)?.trim().toUpperCase() ?? PredictionRepository.defaultIndexCode,
          horizon: h,
          direction: d,
          confidence: c is num ? (c > 1 ? c / 100 : c).toDouble().clamp(0, 1) : null,
        );
      }
    }
    final score = j['sentiment_score'];
    final a = MarketAnalysis(
      sentimentScore: score is num ? score.round().clamp(0, 100) : null,
      trend: j['trend']?.toString(),
      support: _nums(levels['support']),
      resistance: _nums(levels['resistance']),
      highlights: _strs(j['highlights']),
      risks: _strs(j['risks']),
      outlook: outlook,
      summary: j['summary']?.toString(),
    );
    if (a.summary == null && a.trend == null) return null;
    return a;
  }

  static MarketAnalysis? of(AiAnalysis row) => row.output == null ? null : fromJson(row.output!);
}

class AnalysisNotConfigured implements Exception {
  const AnalysisNotConfigured();
  @override
  String toString() => '尚未配置 AI 模型的 API Key';
}

/// 定时分析时点（上海时间），每个时点 60 分钟内有效，过时不补。
const analysisSlots = [(9, 35), (11, 35), (15, 5)];

/// AI 大盘分析（spec 3.1.2 / 5.4）。
class MarketAnalysisService {
  MarketAnalysisService({
    required this.config,
    required this.repo,
    required this.predictions,
    required this.journal,
    required this.market,
    required this.calendar,
    required this.settings,
    required this.overview,
    LlmProvider Function(LlmConfig)? providerFactory,
    DateTime Function()? now,
  })  : _provider = providerFactory ?? LlmProvider.of,
        _now = now ?? DateTime.now;

  final AiConfigRepository config;
  final AiAnalysisRepository repo;
  final PredictionRepository predictions;
  final JournalRepository journal;
  final MarketService market;
  final TradingCalendar calendar;
  final SettingsStore settings;

  /// 取当前看板数据（优先复用看板已拉取的）
  final Future<MarketOverview> Function() overview;
  final LlmProvider Function(LlmConfig) _provider;
  final DateTime Function() _now;

  static const promptVersion = 'v1';
  static const _lastSlotKey = 'ai.last_slot';

  static const systemPrompt = '''
你是一名谨慎、客观的 A 股市场分析师。根据用户提供的实时盘面数据，分析当前大盘状态并给出短期展望。
要求：
- 只依据给出的数据推理，不编造数据中没有的新闻或数字；数据缺失时如实说明。
- 结论要可验证：outlook 必须给出明确方向，不要模棱两可。
- 只输出一个 JSON 对象，不要输出任何其他文字。格式：
{
  "sentiment_score": 0-100 的整数（市场情绪，50 为中性）,
  "trend": "强势上涨" | "震荡偏强" | "震荡" | "震荡偏弱" | "弱势下跌",
  "key_levels": {"support": [上证指数支撑位], "resistance": [上证指数压力位]},
  "highlights": ["要点，每条 30 字以内，2-4 条"],
  "risks": ["风险，每条 30 字以内，1-3 条"],
  "outlook": {"target": "000001.SH", "horizon": "close" | "t1" | "t3" | "t5", "direction": "up" | "down" | "range", "confidence": 0-1 的小数},
  "summary": "100 字以内的总结"
}
outlook.horizon：盘中分析一般用 "close"（判断今日收盘）或 "t1"；盘后 / 休市时用 "t1" 及以后。
direction 相对当前价：up 看涨、down 看跌、range 窄幅震荡。''';

  // ───────────── 输入 ─────────────

  static String _pct(double? v) => v == null ? '--' : '${v >= 0 ? '+' : ''}${v.toStringAsFixed(2)}%';
  static String _yi(double? v) => v == null ? '--' : '${(v / 1e8).toStringAsFixed(0)} 亿';
  static String _n(double v) => v.toStringAsFixed(2);

  /// 组装给模型的盘面描述。
  Future<String> buildInput(MarketOverview o, {bool includeJournal = true}) async {
    final now = _now();
    final m = MarketClock.toMarket(now);
    final loc = calendar.locate(now);
    String two(int n) => n.toString().padLeft(2, '0');
    final b = StringBuffer()
      ..writeln('时间：${m.year}-${two(m.month)}-${two(m.day)} ${two(m.hour)}:${two(m.minute)}（${loc.session.label}）');

    b.writeln('\n【指数】');
    for (final q in o.indices.where((q) => defaultBoardIndices.contains(q.code))) {
      b.writeln('${indexShortNames[q.code] ?? q.name}(${q.code}) ${_n(q.price)} ${_pct(q.changePct)}'
          '${q.open == null ? '' : ' 开${_n(q.open!)} 高${_n(q.high ?? q.price)} 低${_n(q.low ?? q.price)}'}'
          '${q.amount == null ? '' : ' 成交${_yi(q.amount)}'}');
    }

    b.writeln('\n【市场宽度】');
    final br = o.breadth;
    b.writeln(br == null ? '涨跌家数：暂无' : '上涨 ${br.up} 家，下跌 ${br.down} 家，平盘 ${br.flat} 家');
    final l = o.limits;
    if (l != null) {
      b.writeln('涨停 ${l.limitUp}，跌停 ${l.limitDown}，炸板 ${l.broken}'
          '${l.brokenRate == null ? '' : '（炸板率 ${l.brokenRate!.toStringAsFixed(1)}%）'}');
    }

    final t = o.turnover;
    if (t != null) {
      b.writeln('\n【成交额】今日 ${_yi(t.today)}，较昨日同时段 ${_pct(t.changePct)}，昨日全天 ${_yi(t.yesterdayTotal)}');
    }

    void rank(String title, List<RankItem> items) {
      if (items.isEmpty) return;
      b.writeln('$title：${items.take(6).map((e) => '${e.name}${_pct(e.changePct)}'
          '${e.leaderName == null ? '' : '(领涨${e.leaderName})'}').join('，')}');
    }

    b.writeln('\n【板块】');
    rank('行业涨幅前列', o.industryTop);
    rank('行业跌幅前列', o.industryBottom);
    rank('概念涨幅前列', o.conceptTop);
    rank('概念跌幅前列', o.conceptBottom);
    if (o.hotEtfs.isNotEmpty) {
      b.writeln('成交额居前 ETF：${o.hotEtfs.take(6).map((e) => '${e.name}${_pct(e.changePct)}').join('，')}');
    }

    // 近 20 个交易日上证日 K
    try {
      final from = TradeDate.format(MarketClock.marketDate(now).subtract(const Duration(days: 45)));
      final bars = await market.dailyKline(PredictionRepository.defaultIndexCode, from: from);
      final recent = bars.length > 20 ? bars.sublist(bars.length - 20) : bars;
      if (recent.isNotEmpty) {
        b.writeln('\n【上证指数近 ${recent.length} 日】日期 收盘 涨跌幅 成交额');
        double? prev;
        for (final k in recent) {
          final pct = prev == null ? null : (k.close - prev) / prev * 100;
          b.writeln('${k.date} ${_n(k.close)} ${_pct(pct)}${k.amount == null ? '' : ' ${_yi(k.amount)}'}');
          prev = k.close;
        }
      }
    } catch (_) {
      b.writeln('\n（近期日 K 暂不可用）');
    }

    if (includeJournal) {
      final since = TradeDate.format(calendar.previous(loc.tradeDate));
      final entries = (await journal.search(const JournalQuery(limit: 30)))
          .where((e) => e.tradeDate.compareTo(since) >= 0 && e.content.trim().isNotEmpty)
          .take(15)
          .toList()
          .reversed;
      if (entries.isNotEmpty) {
        b.writeln('\n【用户最近的日记观点（仅供参考，不要盲从）】');
        for (final e in entries) {
          final tm = MarketClock.toMarket(DateTime.fromMillisecondsSinceEpoch(e.ts, isUtc: true));
          final cat = byCode(EntryCategory.values, e.category)?.label ?? '';
          b.writeln('${tm.month}/${tm.day} ${two(tm.hour)}:${two(tm.minute)} [$cat] ${e.content.trim()}');
        }
      }
    }
    return b.toString();
  }

  // ───────────── 执行 ─────────────

  /// 执行一次分析，保存记录并（若 outlook 有效）生成 AI 判断。
  /// 模型调用失败时抛出 [LlmException]；输出无法解析时仍保存原文。
  Future<AiAnalysis> analyze({String trigger = 'manual', MarketOverview? data}) async {
    final s = await config.load();
    final cfg = await config.configFor(AiTask.analysis, settings: s);
    if (cfg == null) throw const AnalysisNotConfigured();
    final o = data ?? await overview();
    final input = await buildInput(o, includeJournal: s.includeJournal);
    final llm = _provider(cfg);

    final messages = [const LlmMessage.system(systemPrompt), LlmMessage.user(input)];
    var r = await llm.chat(messages, json: true);
    var tokensIn = r.tokensIn ?? 0, tokensOut = r.tokensOut ?? 0;
    var json = extractJsonObject(r.text);
    var parsed = json == null ? null : MarketAnalysis.fromJson(json);
    if (parsed == null) {
      // 解析失败重试 1 次（spec 5.4）
      r = await llm.chat([
        ...messages,
        LlmMessage.assistant(r.text),
        const LlmMessage.user('上面的输出不是符合要求的 JSON。请只输出一个符合格式的 JSON 对象。'),
      ], json: true);
      tokensIn += r.tokensIn ?? 0;
      tokensOut += r.tokensOut ?? 0;
      json = extractJsonObject(r.text);
      parsed = json == null ? null : MarketAnalysis.fromJson(json);
    }

    final row = await repo.insert(
      trigger: trigger,
      provider: cfg.presetId,
      model: r.model,
      promptVersion: promptVersion,
      input: input,
      output: parsed == null ? null : json,
      rawText: r.text,
      tokensIn: tokensIn,
      tokensOut: tokensOut,
    );

    final ol = parsed?.outlook;
    if (ol != null) {
      // 目标不在看板指数里时退回上证
      final target = o.indices.any((q) => q.code == ol.target) ? ol.target : PredictionRepository.defaultIndexCode;
      final quote = o.indices.where((q) => q.code == target).firstOrNull;
      await predictions.createAi(
        analysisId: row.id,
        targetCode: target,
        direction: ol.direction,
        horizon: ol.horizon,
        basePrice: quote?.approx == true ? null : quote?.price,
        confidence: ol.confidence == null ? 3 : (ol.confidence! * 5).round().clamp(1, 5),
      );
    }
    return row;
  }

  /// 当前应执行的定时时点（yyyyMMdd-HHmm），不在任何时点有效期内返回 null。
  String? dueSlot() {
    final now = _now();
    final date = MarketClock.marketDate(now);
    if (!calendar.isTradingDay(date)) return null;
    final m = MarketClock.toMarket(now);
    final minutes = m.hour * 60 + m.minute;
    for (final (h, mi) in analysisSlots.reversed) {
      final start = h * 60 + mi;
      if (minutes >= start && minutes < start + 60) {
        return '${TradeDate.format(date)}-${h.toString().padLeft(2, '0')}${mi.toString().padLeft(2, '0')}';
      }
    }
    return null;
  }

  /// 定时分析：开关打开、已配置 Key、当前时点未执行过时执行。返回是否执行。
  Future<bool> runScheduledIfDue() async {
    final slot = dueSlot();
    if (slot == null) return false;
    final s = await config.load();
    if (!s.scheduleEnabled) return false;
    if (await settings.raw(_lastSlotKey) == slot) return false;
    if (await config.configFor(AiTask.analysis, settings: s) == null) return false;
    // 先记录，避免失败后每分钟重试刷 token
    await settings.setRaw(_lastSlotKey, slot);
    await analyze(trigger: 'scheduled');
    return true;
  }
}
