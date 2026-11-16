import 'dart:convert';

import '../../core/calendar/trading_calendar.dart';
import '../../core/time/market_clock.dart';
import '../../domain/journal/vocab.dart';
import '../../domain/trade/portfolio.dart';
import '../../domain/verify/stats.dart';
import '../../domain/verify/verifier.dart';
import '../ai/llm.dart';
import '../ai/market_analysis_service.dart';
import '../db/app_database.dart';
import '../market/market_service.dart';
import '../market/models.dart';
import '../repo/agent_repository.dart';
import '../repo/ai_analysis_repository.dart';
import '../repo/instrument_repository.dart';
import '../repo/journal_repository.dart';
import '../repo/prediction_repository.dart';
import '../repo/trade_repository.dart';

/// Agent 可访问的数据类别（spec 3.5.5：可分别关闭）。
enum AgentPermission {
  journal('journal', '日记原文与修改历史'),
  predictions('predictions', '判断与验证结果'),
  trades('trades', '持仓与交易'),
  analyses('analyses', '历史 AI 分析');

  const AgentPermission(this.code, this.label);
  final String code;
  final String label;
}

/// 工具执行结果。
class AgentToolResult {
  const AgentToolResult(this.content, {required this.summary, this.card});

  /// 回传给模型的内容（JSON 文本）
  final String content;

  /// 对话中折叠显示的一句话（"查询了 42 条日记"）
  final String summary;

  /// 需要用户确认的写操作卡片：{type: journal|memory, data: {...}, status: pending}
  final Map<String, dynamic>? card;
}

class AgentTool {
  const AgentTool({required this.spec, required this.run, this.permission});
  final LlmTool spec;
  final AgentPermission? permission;
  final Future<AgentToolResult> Function(Map<String, dynamic> args) run;
}

/// 工具依赖的数据源。
class AgentToolDeps {
  AgentToolDeps({
    required this.journal,
    required this.predictions,
    required this.trades,
    required this.instruments,
    required this.analyses,
    required this.agent,
    required this.market,
    required this.calendar,
    required this.overview,
    required this.costMethod,
    DateTime Function()? now,
  }) : now = now ?? DateTime.now;

  final JournalRepository journal;
  final PredictionRepository predictions;
  final TradeRepository trades;
  final InstrumentRepository instruments;
  final AiAnalysisRepository analyses;
  final AgentRepository agent;
  final MarketService market;
  final TradingCalendar calendar;
  final Future<MarketOverview> Function() overview;
  final CostMethod Function() costMethod;
  final DateTime Function() now;
}

String _j(Object? v) => jsonEncode(v);
double? _r(double? v, [int d = 2]) => v == null ? null : double.parse(v.toStringAsFixed(d));
String _two(int n) => n.toString().padLeft(2, '0');

String _time(int ms) {
  final m = MarketClock.toMarket(DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true));
  return '${m.year}-${_two(m.month)}-${_two(m.day)} ${_two(m.hour)}:${_two(m.minute)}';
}

/// 接受 20261113 / 2026-11-13 / 2026/11/13，返回 yyyyMMdd。
String? _date(Object? v) {
  if (v == null) return null;
  final s = '$v'.replaceAll(RegExp(r'[-/.]'), '').trim();
  return RegExp(r'^\d{8}$').hasMatch(s) ? s : null;
}

int _limit(Object? v, int def, int max) {
  final n = v is num ? v.toInt() : int.tryParse('${v ?? ''}') ?? def;
  return n.clamp(1, max);
}

String _tradeDateOf(int ms) => TradeDate.format(MarketClock.marketDate(DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true)));

bool _inRange(String date, String? from, String? to) =>
    (from == null || date.compareTo(from) >= 0) && (to == null || date.compareTo(to) <= 0);

Map<String, dynamic> _bucket(StatBucket b) => {
      'decided': b.decided,
      'correct': b.correct,
      'partial': b.partial,
      'wrong': b.wrong,
      'accuracy': _r(b.accuracy * 100, 1),
      'directional_accuracy': _r(b.directional * 100, 1),
    };

Map<String, dynamic> _stats(TradeStats s) => {
      'count': s.count,
      'wins': s.wins,
      'win_rate': _r(s.winRate * 100, 1),
      'total_pnl': _r(s.total),
      'avg_win': _r(s.avgWin),
      'avg_loss': _r(s.avgLoss),
      'payoff_ratio': _r(s.payoff),
    };

const _dateProps = {
  'date_from': {'type': 'string', 'description': '起始日期 YYYY-MM-DD（含）'},
  'date_to': {'type': 'string', 'description': '结束日期 YYYY-MM-DD（含）'},
};

/// 构建全部工具（spec 3.5.2）。数据只读；写操作只生成待确认卡片。
List<AgentTool> buildAgentTools(AgentToolDeps d) {
  Future<Map<String, String>> names(Iterable<String> codes) async {
    final rows = await d.instruments.getMany(codes.toSet());
    return {for (final c in codes) c: indexShortNames[c] ?? rows[c]?.name ?? c};
  }

  return [
    AgentTool(
      spec: const LlmTool(
        name: 'get_market_overview',
        description: '获取当前大盘：主要指数、涨跌家数、涨跌停、两市成交额、行业 / 概念涨跌榜、热门 ETF。',
        parameters: {'type': 'object', 'properties': {}},
      ),
      run: (_) async {
        final o = await d.overview();
        return AgentToolResult(
          _j({
            'time': _time(o.fetchedAt.millisecondsSinceEpoch),
            'indices': [
              for (final q in o.indices.where((q) => defaultBoardIndices.contains(q.code)))
                {'code': q.code, 'name': indexShortNames[q.code] ?? q.name, 'price': _r(q.price), 'pct': _r(q.changePct)},
            ],
            if (o.breadth != null) 'breadth': o.breadth!.toJson(),
            if (o.limits != null) 'limits': {...o.limits!.toJson(), 'broken_rate': _r(o.limits!.brokenRate, 1)},
            if (o.turnover != null)
              'turnover_yi': {
                'today': _r(o.turnover!.today / 1e8, 0),
                'vs_yesterday_same_time_pct': _r(o.turnover!.changePct, 1),
                'yesterday_total': _r((o.turnover!.yesterdayTotal ?? 0) / 1e8, 0),
              },
            'industry_top': [for (final e in o.industryTop.take(6)) {'name': e.name, 'pct': _r(e.changePct)}],
            'industry_bottom': [for (final e in o.industryBottom.take(6)) {'name': e.name, 'pct': _r(e.changePct)}],
            'concept_top': [for (final e in o.conceptTop.take(6)) {'name': e.name, 'pct': _r(e.changePct)}],
            'hot_etfs': [for (final e in o.hotEtfs.take(6)) {'name': e.name, 'code': e.code, 'pct': _r(e.changePct)}],
          }),
          summary: '查看了当前大盘',
        );
      },
    ),
    AgentTool(
      spec: const LlmTool(
        name: 'resolve_instrument',
        description: '按名称 / 代码 / 拼音首字母查找标的代码（个股、ETF、指数、板块）。',
        parameters: {
          'type': 'object',
          'properties': {'query': {'type': 'string'}},
          'required': ['query'],
        },
      ),
      run: (a) async {
        final rows = await d.instruments.search('${a['query'] ?? ''}', limit: 8);
        return AgentToolResult(
          _j([for (final r in rows) {'code': r.code, 'name': r.name, 'type': r.type}]),
          summary: '查找标的"${a['query']}"',
        );
      },
    ),
    AgentTool(
      spec: const LlmTool(
        name: 'get_quotes',
        description: '查询标的实时报价。代码格式如 600519.SH、510300.SH、000001.SH（指数）。',
        parameters: {
          'type': 'object',
          'properties': {
            'codes': {'type': 'array', 'items': {'type': 'string'}},
          },
          'required': ['codes'],
        },
      ),
      run: (a) async {
        final codes = [for (final c in (a['codes'] as List? ?? const [])) '$c'].take(20).toList();
        final qs = await d.market.quotes(codes);
        return AgentToolResult(
          _j([
            for (final q in qs)
              {
                'code': q.code,
                'name': q.name,
                'price': _r(q.price, 3),
                'pct': _r(q.changePct),
                'open': _r(q.open, 3),
                'high': _r(q.high, 3),
                'low': _r(q.low, 3),
                'pre_close': _r(q.preClose, 3),
                if (q.amount != null) 'amount_yi': _r(q.amount! / 1e8),
                if (q.approx) 'approx': true,
              },
          ]),
          summary: '查询了 ${codes.length} 个标的的报价',
        );
      },
    ),
    AgentTool(
      spec: const LlmTool(
        name: 'get_kline',
        description: '查询标的最近 N 个交易日的日 K 线（收盘价、涨跌幅、成交额）。',
        parameters: {
          'type': 'object',
          'properties': {
            'code': {'type': 'string'},
            'days': {'type': 'integer', 'description': '默认 30，最多 120'},
          },
          'required': ['code'],
        },
      ),
      run: (a) async {
        final days = _limit(a['days'], 30, 120);
        final from = TradeDate.format(MarketClock.marketDate(d.now()).subtract(Duration(days: days * 2 + 10)));
        final bars = await d.market.dailyKline('${a['code']}', from: from);
        final recent = bars.length > days ? bars.sublist(bars.length - days) : bars;
        double? prev;
        final out = <Map<String, dynamic>>[];
        for (final b in recent) {
          out.add({
            'date': b.date,
            'open': _r(b.open, 3),
            'high': _r(b.high, 3),
            'low': _r(b.low, 3),
            'close': _r(b.close, 3),
            'pct': prev == null ? null : _r((b.close - prev) / prev * 100),
            if (b.amount != null) 'amount_yi': _r(b.amount! / 1e8),
          });
          prev = b.close;
        }
        return AgentToolResult(_j(out), summary: '查看了 ${a['code']} 近 ${out.length} 日 K 线');
      },
    ),
    AgentTool(
      permission: AgentPermission.journal,
      spec: const LlmTool(
        name: 'search_journal',
        description: '检索用户日记：按日期范围、关键词、一级分类（observe 观察 / judge 判断 / plan 计划 / review 复盘 / other 其他）、关联标的代码。返回 id 可用于引用。',
        parameters: {
          'type': 'object',
          'properties': {
            ..._dateProps,
            'keyword': {'type': 'string'},
            'category': {'type': 'string', 'enum': ['observe', 'judge', 'plan', 'review', 'other']},
            'instrument': {'type': 'string', 'description': '标的代码，如 600519.SH'},
            'limit': {'type': 'integer', 'description': '默认 30，最多 100'},
          },
        },
      ),
      run: (a) async {
        final from = _date(a['date_from']), to = _date(a['date_to']);
        final limit = _limit(a['limit'], 30, 100);
        final all = await d.journal.search(JournalQuery(
          text: '${a['keyword'] ?? ''}',
          category: a['category'] as String?,
          instrument: a['instrument'] as String?,
          limit: 1000,
        ));
        final list = all.where((e) => _inRange(e.tradeDate, from, to)).toList();
        final nm = await names(list.take(limit).expand((e) => e.instrumentCodes.where((c) => c.contains('.'))));
        return AgentToolResult(
          _j({
            'total': list.length,
            'items': [
              for (final e in list.take(limit))
                {
                  'id': e.id,
                  'time': _time(e.ts),
                  'category': byCode(EntryCategory.values, e.category)?.label,
                  if (e.subcategory != null) 'subcategory': e.subcategory,
                  if (e.stance != null) 'stance': e.stance,
                  if (e.horizon != null) 'horizon': horizonLabels[e.horizon] ?? e.horizon,
                  if (e.emotion != null) 'emotion': e.emotion,
                  'content': e.content,
                  if (e.tags.isNotEmpty) 'tags': e.tags,
                  if (e.instrumentCodes.isNotEmpty)
                    'instruments': [for (final c in e.instrumentCodes) nm[c] == null ? c : '${nm[c]}($c)'],
                  if (e.revisionCount > 0) 'revisions': e.revisionCount,
                },
            ],
          }),
          summary: '查询了 ${list.length} 条日记',
        );
      },
    ),
    AgentTool(
      permission: AgentPermission.predictions,
      spec: const LlmTool(
        name: 'get_predictions',
        description: '查询判断明细及各验证时点结果（当日收盘 / 次日开盘 / 次日收盘 / T+3 / T+5）。source: user 用户 / ai AI / all。status: correct / partial / wrong / pending。',
        parameters: {
          'type': 'object',
          'properties': {
            ..._dateProps,
            'source': {'type': 'string', 'enum': ['user', 'ai', 'all']},
            'status': {'type': 'string', 'enum': ['correct', 'partial', 'wrong', 'pending']},
            'limit': {'type': 'integer', 'description': '默认 30，最多 100'},
          },
        },
      ),
      run: (a) async {
        final from = _date(a['date_from']), to = _date(a['date_to']);
        final source = (a['source'] as String?) ?? 'user';
        final status = a['status'] as String?;
        final limit = _limit(a['limit'], 30, 100);
        var list = (await d.predictions.all()).where((v) {
          final p = v.prediction;
          if (source != 'all' && p.source != source) return false;
          final date = v.entry?.tradeDate ?? _tradeDateOf(p.createdAt);
          if (!_inRange(date, from, to)) return false;
          if (status == 'pending') return v.status == null;
          if (status != null) return v.status?.code == status;
          return true;
        }).toList()
          ..sort((x, y) => y.prediction.createdAt.compareTo(x.prediction.createdAt));
        final nm = await names(list.map((v) => v.prediction.targetCode));
        return AgentToolResult(
          _j({
            'total': list.length,
            'items': [
              for (final v in list.take(limit))
                {
                  'id': v.prediction.id,
                  'source': v.prediction.source,
                  'created': _time(v.entry?.ts ?? v.prediction.createdAt),
                  'target': '${nm[v.prediction.targetCode]}(${v.prediction.targetCode})',
                  'direction': directionLabels[v.prediction.direction],
                  'horizon': horizonLabels[v.prediction.horizonType] ?? v.prediction.horizonType,
                  'base_price': v.prediction.basePrice,
                  'primary_checkpoint': v.primary.label,
                  'result': v.status?.label ?? '待验证',
                  'checkpoints': {
                    for (final e in v.results.entries)
                      e.key.label: {'status': VerifyStatus.fromCode(e.value.status)?.label, 'price': e.value.actualClose, 'pct': _r(e.value.changePct)},
                  },
                  if (v.entry != null) 'journal_id': v.entry!.id,
                  if (v.entry != null) 'journal': v.entry!.content,
                  if (v.review != null) 'review': v.review!.content,
                  if (v.prediction.modifiedBeforeDue) 'modified_before_due': true,
                },
            ],
          }),
          summary: '查询了 ${list.length} 条判断',
        );
      },
    ),
    AgentTool(
      permission: AgentPermission.predictions,
      spec: const LlmTool(
        name: 'get_prediction_stats',
        description: '判断准确率统计：总体、按方向、按对象（大盘 / 指数 / 板块 / 个股）、按周期、按验证时点。accuracy 为完全正确率，directional_accuracy 含部分正确。',
        parameters: {
          'type': 'object',
          'properties': {
            ..._dateProps,
            'source': {'type': 'string', 'enum': ['user', 'ai']},
          },
        },
      ),
      run: (a) async {
        final from = _date(a['date_from']), to = _date(a['date_to']);
        final source = (a['source'] as String?) ?? 'user';
        final views = (await d.predictions.all()).where((v) {
          final date = v.entry?.tradeDate ?? _tradeDateOf(v.prediction.createdAt);
          return v.prediction.source == source && _inRange(date, from, to);
        }).toList();
        final s = PredictionStats.compute(views);
        return AgentToolResult(
          _j({
            'source': source,
            'total': views.length,
            'pending': s.pending,
            'modified_before_due': s.modified,
            'overall': _bucket(s.overall),
            'by_direction': {for (final e in s.byDirection.entries) directionLabels[e.key] ?? e.key: _bucket(e.value)},
            'by_target': {for (final e in s.byTarget.entries) e.key: _bucket(e.value)},
            'by_horizon': {for (final e in s.byHorizon.entries) horizonLabels[e.key] ?? e.key: _bucket(e.value)},
            'by_checkpoint': {for (final e in s.byCheckpoint.entries) e.key.label: _bucket(e.value)},
            'by_confidence': {for (final e in s.byConfidence.entries) '${e.key}': _bucket(e.value)},
          }),
          summary: '统计了 ${views.length} 条判断的准确率',
        );
      },
    ),
    AgentTool(
      permission: AgentPermission.trades,
      spec: const LlmTool(
        name: 'get_positions',
        description: '当前持仓：数量、成本、现价、市值、浮动盈亏、当日盈亏、仓位占比、持有天数，以及汇总。',
        parameters: {'type': 'object', 'properties': {}},
      ),
      run: (_) async {
        final p = Portfolio.compute(await d.trades.all(), todayStart: _todayStart(d.now()));
        final m = d.costMethod();
        final open = p.open.toList();
        final quotes = {for (final q in await d.market.quotes([for (final h in open) h.code])) q.code: q};
        final nm = await names(open.map((h) => h.code));
        var mv = 0.0, floating = 0.0, day = 0.0;
        final items = <Map<String, dynamic>>[];
        for (final h in open) {
          final q = quotes[h.code];
          if (q != null) {
            mv += h.marketValue(q.price);
            floating += h.floating(q.price, m);
            day += h.dayPnl(q.price, q.preClose);
          }
          items.add({
            'code': h.code,
            'name': nm[h.code],
            'qty': h.qty,
            'cost': _r(h.cost(m), 3),
            'price': _r(q?.price, 3),
            'today_pct': _r(q?.changePct),
            'market_value': q == null ? null : _r(h.marketValue(q.price)),
            'floating_pnl': q == null ? null : _r(h.floating(q.price, m)),
            'floating_pct': q == null || h.costTotal(m) == 0 ? null : _r(h.floating(q.price, m) / h.costTotal(m) * 100),
            'day_pnl': q == null ? null : _r(h.dayPnl(q.price, q.preClose)),
            'holding_days': h.holdingDays(d.now()),
          });
        }
        for (final it in items) {
          final v = it['market_value'] as double?;
          if (v != null && mv > 0) it['weight_pct'] = _r(v / mv * 100, 1);
        }
        return AgentToolResult(
          _j({
            'cost_method': m.label,
            'total_market_value': _r(mv),
            'total_floating_pnl': _r(floating),
            'total_day_pnl': _r(day),
            'realized_pnl': _r(p.realized(m)),
            'positions': items,
          }),
          summary: '查看了 ${items.length} 只持仓',
        );
      },
    ),
    AgentTool(
      permission: AgentPermission.trades,
      spec: const LlmTool(
        name: 'get_trades',
        description: '交易流水：按日期范围、标的筛选。side: buy 买入 / sell 卖出 / dividend 分红 / bonus 送转 / init 期初持仓。',
        parameters: {
          'type': 'object',
          'properties': {
            ..._dateProps,
            'code': {'type': 'string'},
            'limit': {'type': 'integer', 'description': '默认 50，最多 200'},
          },
        },
      ),
      run: (a) async {
        final from = _date(a['date_from']), to = _date(a['date_to']);
        final code = a['code'] as String?;
        final limit = _limit(a['limit'], 50, 200);
        final list = (await d.trades.all())
            .where((t) => (code == null || t.instrumentCode == code) && _inRange(_tradeDateOf(t.ts), from, to))
            .toList();
        final nm = await names(list.take(limit).map((t) => t.instrumentCode));
        return AgentToolResult(
          _j({
            'total': list.length,
            'items': [
              for (final t in list.take(limit))
                {
                  'id': t.id,
                  'time': _time(t.ts),
                  'code': t.instrumentCode,
                  'name': nm[t.instrumentCode],
                  'side': t.side,
                  'price': t.price,
                  'qty': t.qty,
                  'amount': t.amount,
                  'fees': _r(t.commission + t.stampTax + t.transferFee),
                  if (t.note != null) 'note': t.note,
                },
            ],
          }),
          summary: '查询了 ${list.length} 笔交易',
        );
      },
    ),
    AgentTool(
      permission: AgentPermission.trades,
      spec: const LlmTool(
        name: 'get_pnl_stats',
        description: '已清仓交易（开仓到清仓为一笔）统计：胜率、盈亏比、总盈亏，按标的与月份拆分，并列出最近的完整交易。日期按清仓日筛选。',
        parameters: {'type': 'object', 'properties': _dateProps},
      ),
      run: (a) async {
        final from = _date(a['date_from']), to = _date(a['date_to']);
        final trips = Portfolio.compute(await d.trades.all())
            .roundTrips
            .where((t) => _inRange(_tradeDateOf(t.closedAt), from, to))
            .toList();
        final nm = await names(trips.map((t) => t.code));
        return AgentToolResult(
          _j({
            'overall': _stats(TradeStats(trips)),
            'by_code': {
              for (final e in TradeStats.groupBy(trips, (t) => t.code).entries) '${nm[e.key]}(${e.key})': _stats(e.value),
            },
            'by_month': {
              for (final e in TradeStats.groupBy(trips, (t) => _tradeDateOf(t.closedAt).substring(0, 6)).entries)
                e.key: _stats(e.value),
            },
            'recent': [
              for (final t in trips.reversed.take(20))
                {
                  'name': nm[t.code],
                  'code': t.code,
                  'opened': _time(t.openedAt),
                  'closed': _time(t.closedAt),
                  'pnl': _r(t.pnl),
                  'return_pct': _r(t.returnPct),
                },
            ],
          }),
          summary: '统计了 ${trips.length} 笔已清仓交易',
        );
      },
    ),
    AgentTool(
      permission: AgentPermission.analyses,
      spec: const LlmTool(
        name: 'get_ai_analyses',
        description: '历史 AI 大盘分析及其展望的验证结果。',
        parameters: {
          'type': 'object',
          'properties': {'limit': {'type': 'integer', 'description': '默认 5，最多 30'}},
        },
      ),
      run: (a) async {
        final rows = await d.analyses.recent(limit: _limit(a['limit'], 5, 30));
        final views = {for (final v in await d.predictions.all()) if (v.prediction.analysisId != null) v.prediction.analysisId!: v};
        return AgentToolResult(
          _j([
            for (final r in rows)
              {
                'id': r.id,
                'time': _time(r.ts),
                'model': r.model,
                ...?(() {
                  final x = MarketAnalysis.of(r);
                  if (x == null) return null;
                  return {
                    'trend': x.trend,
                    'sentiment': x.sentimentScore,
                    'summary': x.summary,
                    if (x.outlook != null)
                      'outlook': '${horizonLabels[x.outlook!.horizon]} ${directionLabels[x.outlook!.direction]}',
                  };
                })(),
                if (views[r.id] != null) 'outlook_result': views[r.id]!.status?.label ?? '待验证',
              },
          ]),
          summary: '查看了 ${rows.length} 条 AI 分析',
        );
      },
    ),
    AgentTool(
      permission: AgentPermission.journal,
      spec: const LlmTool(
        name: 'get_revisions',
        description: '某条记录的修改历史（修改前内容与改动字段）。entity_type: journal_entry / prediction / trade。',
        parameters: {
          'type': 'object',
          'properties': {
            'entity_type': {'type': 'string', 'enum': ['journal_entry', 'prediction', 'trade']},
            'id': {'type': 'string'},
          },
          'required': ['entity_type', 'id'],
        },
      ),
      run: (a) async {
        final id = '${a['id']}';
        final List<Revision> list = switch (a['entity_type']) {
          'prediction' => await d.predictions.history(id),
          'trade' => await d.trades.history(id),
          _ => await d.journal.history(id),
        };
        return AgentToolResult(
          _j([
            for (final r in list)
              {
                'revision': r.revisionNo,
                'time': _time(r.ts),
                'changed_fields': r.changedFields,
                'before': {for (final f in r.changedFields) f: r.before[f]},
              },
          ]),
          summary: '查看了 ${list.length} 次修改记录',
        );
      },
    ),
    AgentTool(
      spec: const LlmTool(
        name: 'memory_search',
        description: '检索关于用户的长期记忆（交易风格、个人规则、偏好、经验教训、关注标的）。kind: style / rule / preference / lesson / watch / fact。',
        parameters: {
          'type': 'object',
          'properties': {
            'query': {'type': 'string'},
            'kind': {'type': 'string', 'enum': ['style', 'rule', 'preference', 'lesson', 'watch', 'fact']},
          },
        },
      ),
      run: (a) async {
        final list = await d.agent.searchMemories('${a['query'] ?? ''}', kind: a['kind'] as String?, limit: 15);
        return AgentToolResult(
          _j([for (final m in list) {'kind': MemoryKind.fromCode(m.kind).label, 'content': m.content, 'importance': m.importance}]),
          summary: '检索到 ${list.length} 条记忆',
        );
      },
    ),
    AgentTool(
      spec: const LlmTool(
        name: 'memory_save',
        description: '提议保存一条关于用户的长期记忆（稳定的风格、规则、偏好、教训、关注标的）。只生成确认卡片，用户确认后才保存。',
        parameters: {
          'type': 'object',
          'properties': {
            'kind': {'type': 'string', 'enum': ['style', 'rule', 'preference', 'lesson', 'watch', 'fact']},
            'content': {'type': 'string', 'description': '一句话，第三人称描述用户，如"不追涨停板"'},
            'importance': {'type': 'integer', 'description': '1-5'},
          },
          'required': ['kind', 'content'],
        },
      ),
      run: (a) async {
        final kind = MemoryKind.fromCode(a['kind'] as String?);
        final content = '${a['content'] ?? ''}'.trim();
        if (content.isEmpty) return const AgentToolResult('{"error":"content 为空"}', summary: '记忆内容为空');
        return AgentToolResult(
          _j({'status': 'pending_user_confirmation', 'note': '已向用户展示确认卡片，用户点"保存"后才会写入'}),
          summary: '提议记住：$content',
          card: {
            'type': 'memory',
            'status': 'pending',
            'data': {'kind': kind.code, 'content': content, 'importance': _limit(a['importance'], 3, 5)},
          },
        );
      },
    ),
    AgentTool(
      permission: AgentPermission.journal,
      spec: const LlmTool(
        name: 'draft_journal_entry',
        description: '起草一条日记（含判断：category=judge 并给出 stance 与 horizon，会自动生成可验证的判断）。只生成确认卡片，用户确认后才保存。',
        parameters: {
          'type': 'object',
          'properties': {
            'content': {'type': 'string'},
            'category': {'type': 'string', 'enum': ['observe', 'judge', 'plan', 'review', 'other']},
            'subcategory': {'type': 'string', 'description': 'judge: market / index / sector / stock；observe: market / sector / stock / news'},
            'stance': {'type': 'string', 'enum': ['bull', 'bear', 'range'], 'description': '判断方向（judge）'},
            'horizon': {'type': 'string', 'enum': ['close', 't1', 't3', 't5', 'mid'], 'description': '判断周期（judge）'},
            'instrument_codes': {'type': 'array', 'items': {'type': 'string'}},
          },
          'required': ['content', 'category'],
        },
      ),
      run: (a) async {
        final content = '${a['content'] ?? ''}'.trim();
        if (content.isEmpty) return const AgentToolResult('{"error":"content 为空"}', summary: '日记内容为空');
        final category = byCode(EntryCategory.values, a['category'] as String?)?.code ?? 'other';
        return AgentToolResult(
          _j({'status': 'pending_user_confirmation', 'note': '已向用户展示确认卡片，用户点"保存"后才会写入'}),
          summary: '起草了一条日记',
          card: {
            'type': 'journal',
            'status': 'pending',
            'data': {
              'content': content,
              'category': category,
              if (a['subcategory'] != null) 'subcategory': a['subcategory'],
              if (category == 'judge' && a['stance'] != null) 'stance': a['stance'],
              if (category == 'judge' && a['horizon'] != null) 'horizon': a['horizon'],
              'instrument_codes': [for (final c in (a['instrument_codes'] as List? ?? const [])) '$c'],
            },
          },
        );
      },
    ),
  ];
}

int _todayStart(DateTime now) {
  final d = MarketClock.marketDate(now);
  return MarketClock.fromMarket(d.year, d.month, d.day).millisecondsSinceEpoch;
}

