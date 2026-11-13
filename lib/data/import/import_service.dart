import 'package:drift/drift.dart';

import '../../domain/trade/trade_rules.dart';
import '../ai/ai_settings.dart';
import '../ai/llm.dart';
import '../db/app_database.dart';
import '../market/market_service.dart';
import '../repo/instrument_repository.dart';
import '../repo/trade_repository.dart';
import 'table_import.dart';

/// 表格导入预览。
class TablePreview {
  TablePreview({required this.fileName, required this.rows, required this.layout, required this.parsed, this.mappingName});
  final String fileName;
  final List<List<String>> rows;
  TableLayout layout;

  /// 映射完整时的解析结果
  List<ImportRow> parsed;

  /// 复用的已保存映射名称
  final String? mappingName;
}

/// 截图识别预览。
class ImagePreview {
  ImagePreview({required this.kind, required this.rows, this.rawText});

  /// positions | trades
  final String kind;
  final List<ImportRow> rows;
  final String? rawText;
}

/// 交易导入：表格（自动识别 / 列映射 / AI 推荐映射）与截图（视觉模型）。
class TradeImportService {
  TradeImportService({
    required this.trades,
    required this.mappings,
    required this.instruments,
    required this.market,
    required this.aiConfig,
    required this.llmFactory,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final TradeRepository trades;
  final ColumnMappingRepository mappings;
  final InstrumentRepository instruments;
  final MarketService market;
  final AiConfigRepository aiConfig;
  final LlmProvider Function(LlmConfig) llmFactory;
  final DateTime Function() _now;

  // ───────────── 名称 → 代码 ─────────────

  static int _overlap(String a, String b) => a.split('').where(b.contains).length;

  /// 把券商显示的名称解析为代码。券商常把 ETF 显示为"主题ETF+基金公司"（如"农业ETF富国"），
  /// 而代码表是"基金公司+指数+ETF"，因此按基金公司 + 主题字重合度找候选，
  /// 有 [price] 时再用实时价格确认。
  Future<String?> resolveName(String name, {double? price}) async {
    final n = name.replaceAll(RegExp(r'\s'), '');
    if (n.isEmpty) return null;
    final db = instruments.db;
    final exact = await (db.select(db.instruments)..where((i) => i.name.equals(n))).get();
    if (exact.length == 1) return exact.first.code;

    List<Instrument> candidates;
    final etf = RegExp(r'^(.*?)(ETF|LOF)(.*)$', caseSensitive: false).firstMatch(n);
    if (etf != null) {
      final topic = etf[1]!;
      final manager = etf[3]!;
      var pool = <Instrument>[];
      if (manager.isNotEmpty) {
        pool = await (db.select(db.instruments)
              ..where((i) => i.type.equals('etf') & i.name.like('$manager%')))
            .get();
      }
      if (pool.isEmpty && topic.length >= 2) {
        pool = await (db.select(db.instruments)
              ..where((i) => i.type.equals('etf') & i.name.like('%${topic.substring(0, 2)}%')))
            .get();
      }
      pool.sort((a, b) => _overlap(topic, b.name).compareTo(_overlap(topic, a.name)));
      final best = pool.isEmpty ? 0 : _overlap(topic, pool.first.name);
      candidates = pool.where((i) => best > 0 && _overlap(topic, i.name) >= best - 1).take(8).toList();
    } else {
      candidates = await instruments.search(n, limit: 5);
      if (candidates.isNotEmpty && candidates.first.name == n) return candidates.first.code;
    }
    if (candidates.isEmpty) return null;
    if (price != null && price > 0 && candidates.length > 1) {
      try {
        final quotes = await market.quotes(candidates.map((c) => c.code).toList());
        quotes.sort((a, b) => (a.price - price).abs().compareTo((b.price - price).abs()));
        if (quotes.isNotEmpty && (quotes.first.price - price).abs() / price < 0.02) return quotes.first.code;
      } catch (_) {
        // 行情不可用时退回字面匹配
      }
    }
    return candidates.first.code;
  }

  // ───────────── 表格 ─────────────

  Future<TablePreview> previewTable(List<int> bytes, String fileName, Account account) async {
    final rows = readTable(bytes, fileName);
    if (rows.isEmpty) throw const UnsupportedFileException('文件中没有数据');
    var layout = detectLayout(rows);
    String? mappingName;
    final saved = await mappings.findBySignature(layout.signature);
    if (saved != null) {
      layout = layout.withMapping(TableLayout.mappingFromJson(saved.mapping, layout.headers));
      mappingName = saved.name;
    }
    final preview = TablePreview(fileName: fileName, rows: rows, layout: layout, parsed: const [], mappingName: mappingName);
    if (layout.complete) await reparse(preview, account);
    return preview;
  }

  /// 映射修改后重新解析。
  Future<void> reparse(TablePreview p, Account account) async {
    p.parsed = await parseRows(p.rows, p.layout,
        accountId: account.id, rates: account.rates, resolveName: (n) => resolveName(n));
    markDuplicates(p.parsed, await trades.existingKeys());
  }

  /// 让 AI 推荐列映射（spec 3.4.2）。
  Future<Map<ImportField, int>> suggestMapping(TablePreview p) async {
    final cfg = await aiConfig.configFor(AiTask.table);
    if (cfg == null) throw const LlmException('尚未配置"表格字段映射"所用模型的 API Key');
    final headers = p.layout.headers;
    final samples = p.rows.skip(p.layout.headerRow + 1).take(3).toList();
    final fields = ImportField.values.map((f) => '${f.key}（${f.label}）').join('、');
    final prompt = StringBuffer()
      ..writeln('下面是一份券商交割单 / 成交明细的表头与样例行。请把每个字段对应到列序号（从 0 开始），没有的字段不要输出。')
      ..writeln('字段：$fields')
      ..writeln('只输出 JSON 对象，例如 {"date": 0, "secCode": 2}。字段名用括号前的英文。')
      ..writeln()
      ..writeln('表头：${[for (final (i, h) in headers.indexed) '$i:$h'].join(' | ')}');
    for (final r in samples) {
      prompt.writeln('样例：${[for (final (i, c) in r.indexed) '$i:$c'].join(' | ')}');
    }
    final r = await llmFactory(cfg).chat([LlmMessage.user(prompt.toString())], json: true);
    final j = extractJsonObject(r.text) ?? const {};
    final out = <ImportField, int>{};
    for (final e in j.entries) {
      final f = ImportField.fromCode(e.key) ??
          ImportField.values.where((x) => x.name == e.key).firstOrNull;
      final v = e.value;
      if (f != null && v is num && v >= 0 && v < headers.length) out[f] = v.toInt();
    }
    return out;
  }

  Future<String> commitTable(TablePreview p, {bool saveMapping = true}) async {
    String? mappingId;
    if (saveMapping) {
      final m = await mappings.save(name: p.fileName, mapping: p.layout.toJson());
      mappingId = m.id;
    }
    return trades.importBatch(
      kind: 'table',
      fileName: p.fileName,
      mappingId: mappingId,
      drafts: [for (final r in p.parsed) if (r.selected && r.draft != null) r.draft!],
    );
  }

  // ───────────── 截图 ─────────────

  static const visionPrompt = '''
这是一张券商 App 截图。判断它是"持仓"还是"成交记录 / 交割单"，提取其中每一只证券，只输出一个 JSON 对象：
{"kind": "positions" 或 "trades",
 "items": [{"name": "证券名称（原样）", "code": "6 位代码，截图里没有就留空，不要猜",
            "qty": 持仓数量或成交数量（整数，持仓取"持仓"列而不是"可用"列）,
            "cost": 成本价（仅持仓）, "price": 现价（持仓）或成交价（成交）,
            "side": "buy" 或 "sell"（仅成交）, "date": "YYYY-MM-DD"（仅成交，截图里有才填）, "time": "HH:MM:SS"（仅成交）}]}
不要包含合计行、资金行；数字去掉千分位逗号。''';

  Future<ImagePreview> previewImage(List<int> bytes, String mime, Account account) async {
    final cfg = await aiConfig.configFor(AiTask.vision);
    if (cfg == null) throw const LlmException('尚未配置"图片识别"所用模型的 API Key');
    final r = await llmFactory(cfg).chat([
      LlmMessage.user(visionPrompt, images: [LlmImage(mime, bytes)]),
    ], json: true);
    final j = extractJsonObject(r.text);
    if (j == null) return ImagePreview(kind: 'trades', rows: const [], rawText: r.text);
    final kind = j['kind'] == 'positions' ? 'positions' : 'trades';
    final now = _now().millisecondsSinceEpoch;
    final rows = <ImportRow>[];
    for (final (i, it) in ((j['items'] as List?) ?? const []).indexed) {
      if (it is! Map) continue;
      final name = '${it['name'] ?? ''}'.trim();
      final raw = [name, '${it['code'] ?? ''}', '${it['qty'] ?? ''}', '${it['cost'] ?? ''}', '${it['price'] ?? ''}'];
      double? toD(Object? v) => v is num ? v.toDouble() : double.tryParse('${v ?? ''}'.replaceAll(',', ''));
      final qty = toD(it['qty'])?.abs().round() ?? 0;
      final price = toD(it['price']);
      final code = canonicalCode('${it['code'] ?? ''}') ?? await resolveName(name, price: price);
      if (code == null) {
        rows.add(ImportRow(index: i, raw: raw, error: '无法匹配证券：$name'));
        continue;
      }
      if (kind == 'positions') {
        final cost = toD(it['cost']);
        if (cost == null || qty == 0) {
          rows.add(ImportRow(index: i, raw: raw, error: '缺少数量或成本价'));
          continue;
        }
        rows.add(ImportRow(
          index: i,
          raw: raw,
          draft: TradeDraft(
            accountId: account.id,
            code: code,
            side: TradeSide.init,
            ts: now,
            price: cost,
            qty: qty,
            name: name,
            note: '截图导入持仓',
          ),
        ));
      } else {
        final side = it['side'] == 'sell' ? TradeSide.sell : TradeSide.buy;
        final ts = parseTimestamp(it['date']?.toString(), it['time']?.toString()) ?? now;
        if (price == null || qty == 0) {
          rows.add(ImportRow(index: i, raw: raw, error: '缺少数量或价格'));
          continue;
        }
        final amount = round2(price * qty);
        rows.add(ImportRow(
          index: i,
          raw: raw,
          draft: TradeDraft(
            accountId: account.id,
            code: code,
            side: side,
            ts: ts,
            price: price,
            qty: qty,
            amount: amount,
            fees: calcFees(account.rates, side, code, amount),
            name: name,
          ),
        ));
      }
    }
    markDuplicates(rows, await trades.existingKeys());
    return ImagePreview(kind: kind, rows: rows, rawText: r.text);
  }

  Future<String> commitImage(ImagePreview p) => trades.importBatch(
        kind: 'image',
        drafts: [for (final r in p.rows) if (r.selected && r.draft != null) r.draft!],
      );
}
