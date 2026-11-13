import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/providers.dart';
import '../../core/format.dart';
import '../../core/time/market_clock.dart';
import '../../data/db/app_database.dart';
import '../../data/repo/trade_repository.dart';
import '../../domain/trade/trade_rules.dart';
import '../market/instrument_search_page.dart';
import 'portfolio_providers.dart';

/// 手动记一笔 / 修改交易（spec 3.4.2）：标的联想、默认现价、数量快捷按钮、费用按账户费率自动计算。
class TradeFormPage extends ConsumerStatefulWidget {
  const TradeFormPage({super.key, this.trade, this.code, this.name, this.side});

  /// 修改已有交易
  final Trade? trade;

  /// 新建时预填的标的与方向
  final String? code;
  final String? name;
  final TradeSide? side;

  @override
  ConsumerState<TradeFormPage> createState() => _TradeFormPageState();
}

class _TradeFormPageState extends ConsumerState<TradeFormPage> {
  final _price = TextEditingController();
  final _qty = TextEditingController();
  final _amount = TextEditingController();
  final _commission = TextEditingController();
  final _stamp = TextEditingController();
  final _transfer = TextEditingController();
  final _note = TextEditingController();

  String? _accountId;
  String? _code;
  String? _name;
  TradeSide _side = TradeSide.buy;
  late DateTime _time; // 上海时间（墙钟）
  bool _feesEdited = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final t = widget.trade;
    final now = MarketClock.toMarket(ref.read(clockProvider)());
    if (t != null) {
      _accountId = t.accountId;
      _code = t.instrumentCode;
      _side = TradeSide.fromCode(t.side) ?? TradeSide.buy;
      _time = MarketClock.toMarket(DateTime.fromMillisecondsSinceEpoch(t.ts, isUtc: true));
      _price.text = _trim(t.price);
      _qty.text = '${t.qty}';
      _amount.text = _trim(t.amount);
      _commission.text = _trim(t.commission);
      _stamp.text = _trim(t.stampTax);
      _transfer.text = _trim(t.transferFee);
      _note.text = t.note ?? '';
      _feesEdited = true;
      ref.read(instrumentRepositoryProvider).get(t.instrumentCode).then((i) {
        if (mounted && i != null) setState(() => _name = i.name);
      });
    } else {
      _time = now;
      _code = widget.code;
      _name = widget.name;
      _side = widget.side ?? TradeSide.buy;
      _accountId = ref.read(selectedAccountProvider);
      if (_code != null) _fillPrice();
    }
    ref.read(accountRepositoryProvider).ensureDefault().then((a) {
      if (mounted && _accountId == null) setState(() => _accountId = a.id);
    });
  }

  static String _trim(double v) {
    final s = v.toStringAsFixed(3);
    return s.contains('.') ? s.replaceFirst(RegExp(r'\.?0+$'), '') : s;
  }

  double? _d(TextEditingController c) => double.tryParse(c.text.trim());

  Account? get _account =>
      (ref.read(accountsProvider).value ?? const []).where((a) => a.id == _accountId).firstOrNull;

  Future<void> _fillPrice() async {
    try {
      final q = (await ref.read(marketServiceProvider).quotes([_code!])).firstOrNull;
      if (q != null && mounted && _price.text.isEmpty) {
        _price.text = _trim(q.price);
        _recalc();
      }
    } catch (_) {}
  }

  Future<void> _pickInstrument() async {
    final r = await Navigator.of(context).push<Instrument>(
        MaterialPageRoute(builder: (_) => const InstrumentSearchPage(pick: true)));
    if (r == null) return;
    setState(() {
      _code = r.code;
      _name = r.name;
      _price.clear();
    });
    _fillPrice();
  }

  /// 金额 = 价格 × 数量；费用按账户费率（手动改过费用后不再自动覆盖）。
  void _recalc({bool amountOnly = false}) {
    final p = _d(_price), q = int.tryParse(_qty.text.trim());
    if (p != null && q != null && _side != TradeSide.dividend) {
      _amount.text = _trim(round2(p * q));
    }
    final a = _d(_amount), acc = _account;
    if (!_feesEdited && a != null && acc != null && _code != null) {
      final f = calcFees(acc.rates, _side, _code!, a);
      _commission.text = _trim(f.commission);
      _stamp.text = _trim(f.stampTax);
      _transfer.text = _trim(f.transferFee);
    }
    setState(() {});
  }

  int get _heldQty {
    if (_code == null) return 0;
    return ref.read(portfolioProvider).holdings[_code!]?.qty ?? 0;
  }

  Future<void> _pickTime() async {
    final d = await showDatePicker(
        context: context, initialDate: _time, firstDate: DateTime(2000), lastDate: DateTime(2100));
    if (d == null || !mounted) return;
    final t = await showTimePicker(context: context, initialTime: TimeOfDay(hour: _time.hour, minute: _time.minute));
    setState(() => _time = DateTime(d.year, d.month, d.day, t?.hour ?? _time.hour, t?.minute ?? _time.minute));
  }

  Future<void> _save() async {
    final price = _d(_price) ?? 0;
    final qty = int.tryParse(_qty.text.trim()) ?? 0;
    final amount = _d(_amount) ?? 0;
    String? err;
    if (_code == null) {
      err = '请选择标的';
    } else if (_accountId == null) {
      err = '请选择账户';
    } else if (_side == TradeSide.dividend ? amount <= 0 : qty <= 0) {
      err = _side == TradeSide.dividend ? '请填写分红金额' : '请填写数量';
    } else if ((_side == TradeSide.buy || _side == TradeSide.sell || _side == TradeSide.init) && price <= 0) {
      err = '请填写价格';
    }
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    setState(() => _saving = true);
    final draft = TradeDraft(
      accountId: _accountId!,
      code: _code!,
      side: _side,
      ts: MarketClock.fromMarket(_time.year, _time.month, _time.day, _time.hour, _time.minute).millisecondsSinceEpoch,
      price: price,
      qty: qty,
      amount: amount,
      fees: Fees(commission: _d(_commission) ?? 0, stampTax: _d(_stamp) ?? 0, transferFee: _d(_transfer) ?? 0),
      note: _note.text.trim().isEmpty ? null : _note.text.trim(),
      entryId: widget.trade?.entryId,
    );
    final repo = ref.read(tradeRepositoryProvider);
    widget.trade == null ? await repo.add(draft) : await repo.update(widget.trade!.id, draft);
    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _delete() async {
    final t = widget.trade!;
    await ref.read(tradeRepositoryProvider).delete(t.id);
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context, true);
    messenger.showSnackBar(SnackBar(
      content: const Text('已删除交易'),
      action: SnackBarAction(label: '撤销', onPressed: () => ref.read(tradeRepositoryProvider).restore(t.id)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(accountsProvider).value ?? const [];
    final theme = Theme.of(context);
    final num = [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))];
    final quickQty = [100, 500, 1000];
    final held = _heldQty;
    final total = (_d(_amount) ?? 0) + ((_side == TradeSide.sell || _side == TradeSide.dividend) ? -1 : 1) *
        ((_d(_commission) ?? 0) + (_d(_stamp) ?? 0) + (_d(_transfer) ?? 0));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.trade == null ? '记一笔' : '修改交易'),
        actions: [
          if (widget.trade != null)
            IconButton(tooltip: '删除', icon: const Icon(Icons.delete_outline), onPressed: _delete),
          TextButton(key: const Key('trade-save'), onPressed: _saving ? null : _save, child: const Text('保存')),
        ],
      ),
      body: ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 32), children: [
        SegmentedButton<TradeSide>(
          segments: [
            for (final s in [TradeSide.buy, TradeSide.sell, TradeSide.dividend, TradeSide.bonus, TradeSide.init])
              ButtonSegment(value: s, label: Text(s.label)),
          ],
          selected: {_side},
          showSelectedIcon: false,
          onSelectionChanged: (v) {
            _side = v.first;
            _recalc();
          },
        ),
        const SizedBox(height: 12),
        ListTile(
          key: const Key('trade-instrument'),
          contentPadding: EdgeInsets.zero,
          title: Text(_name ?? _code ?? '选择标的'),
          subtitle: _code == null ? const Text('代码 / 名称 / 拼音首字母') : Text(_code!),
          trailing: const Icon(Icons.search),
          onTap: _pickInstrument,
        ),
        if (accounts.length > 1)
          DropdownButtonFormField<String>(
            initialValue: _accountId,
            decoration: const InputDecoration(labelText: '账户'),
            items: [for (final a in accounts) DropdownMenuItem(value: a.id, child: Text(a.name))],
            onChanged: (v) {
              _accountId = v;
              _recalc();
            },
          ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('成交时间'),
          trailing: Text('${_time.year}-${_two(_time.month)}-${_two(_time.day)} ${_two(_time.hour)}:${_two(_time.minute)}'),
          onTap: _pickTime,
        ),
        if (_side != TradeSide.dividend && _side != TradeSide.bonus)
          TextField(
            key: const Key('trade-price'),
            controller: _price,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: num,
            decoration: InputDecoration(labelText: _side == TradeSide.init ? '成本价' : '成交价'),
            onChanged: (_) => _recalc(),
          ),
        if (_side != TradeSide.dividend) ...[
          TextField(
            key: const Key('trade-qty'),
            controller: _qty,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: _side == TradeSide.bonus ? '送转股数' : '数量',
              helperText: held > 0 ? '当前持仓 $held' : null,
            ),
            onChanged: (_) => _recalc(),
          ),
          Wrap(spacing: 8, children: [
            for (final q in quickQty)
              ActionChip(
                label: Text('$q'),
                onPressed: () {
                  _qty.text = '$q';
                  _recalc();
                },
              ),
            if (_side == TradeSide.sell && held > 0)
              ActionChip(
                label: const Text('全部'),
                onPressed: () {
                  _qty.text = '$held';
                  _recalc();
                },
              ),
          ]),
        ],
        if (_side != TradeSide.bonus)
          TextField(
            controller: _amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: num,
            decoration: InputDecoration(labelText: _side == TradeSide.dividend ? '分红金额（税前）' : '成交金额'),
            onChanged: (_) => _recalc(amountOnly: true),
          ),
        if (_side == TradeSide.buy || _side == TradeSide.sell || _side == TradeSide.dividend) ...[
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: TextField(
                controller: _commission,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: num,
                decoration: InputDecoration(labelText: _side == TradeSide.dividend ? '红利税' : '佣金'),
                onChanged: (_) => setState(() => _feesEdited = true),
              ),
            ),
            const SizedBox(width: 8),
            if (_side != TradeSide.dividend) ...[
              Expanded(
                child: TextField(
                  controller: _stamp,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: num,
                  decoration: const InputDecoration(labelText: '印花税'),
                  onChanged: (_) => setState(() => _feesEdited = true),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _transfer,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: num,
                  decoration: const InputDecoration(labelText: '过户费'),
                  onChanged: (_) => setState(() => _feesEdited = true),
                ),
              ),
            ],
          ]),
          if (_feesEdited && widget.trade == null)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () {
                  _feesEdited = false;
                  _recalc();
                },
                child: const Text('按账户费率重新计算'),
              ),
            ),
        ],
        TextField(controller: _note, decoration: const InputDecoration(labelText: '备注（为什么买 / 卖）')),
        const SizedBox(height: 16),
        if (_side == TradeSide.buy || _side == TradeSide.sell)
          Text('${_side == TradeSide.buy ? '实付' : '实收'} ${formatMoney(total)}', style: theme.textTheme.titleMedium),
        if (_side == TradeSide.init)
          Text('期初持仓用于初始化：按成本价视为一笔买入，不计费用。', style: theme.textTheme.bodySmall),
      ]),
    );
  }

  static String _two(int n) => n.toString().padLeft(2, '0');
}
