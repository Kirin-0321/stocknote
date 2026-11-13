import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/providers.dart';
import '../../data/db/app_database.dart';
import '../../domain/trade/trade_rules.dart';
import 'portfolio_providers.dart';

/// 账户与费率（spec 3.4.1）。
class AccountsPage extends ConsumerWidget {
  const AccountsPage({super.key});

  static String _wan(double rate) {
    final s = (rate * 10000).toStringAsFixed(3);
    return s.replaceFirst(RegExp(r'\.?0+$'), '');
  }

  Future<void> _edit(BuildContext context, WidgetRef ref, Account? a) async {
    final name = TextEditingController(text: a?.name ?? '');
    final broker = TextEditingController(text: a?.broker ?? '');
    final rates = a?.toRates() ?? const FeeRates();
    final comm = TextEditingController(text: _wan(rates.commission));
    final min = TextEditingController(text: rates.minCommission.toStringAsFixed(0));
    final stamp = TextEditingController(text: _wan(rates.stampTax));
    final transfer = TextEditingController(text: _wan(rates.transferFee));
    Widget field(TextEditingController c, String label, {String? suffix}) => TextField(
          controller: c,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: label, suffixText: suffix),
        );
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(a == null ? '添加账户' : '编辑账户'),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: '名称')),
            TextField(controller: broker, decoration: const InputDecoration(labelText: '券商（可选）')),
            field(comm, '佣金费率', suffix: '‱'),
            field(min, '最低佣金', suffix: '元'),
            field(stamp, '印花税（卖出）', suffix: '‱'),
            field(transfer, '过户费', suffix: '‱'),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('取消')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('保存')),
        ],
      ),
    );
    if (ok != true || name.text.trim().isEmpty) return;
    double w(TextEditingController c, double fallback) => (double.tryParse(c.text) ?? fallback * 10000) / 10000;
    final r = FeeRates(
      commission: w(comm, rates.commission),
      minCommission: double.tryParse(min.text) ?? rates.minCommission,
      stampTax: w(stamp, rates.stampTax),
      transferFee: w(transfer, rates.transferFee),
    );
    final repo = ref.read(accountRepositoryProvider);
    if (a == null) {
      await repo.create(name: name.text.trim(), broker: broker.text.trim().isEmpty ? null : broker.text.trim(), rates: r);
    } else {
      await repo.update(a.copyWith(
        name: name.text.trim(),
        broker: Value(broker.text.trim().isEmpty ? null : broker.text.trim()),
        commissionRate: r.commission,
        minCommission: r.minCommission,
        stampTaxRate: r.stampTax,
        transferFeeRate: r.transferFee,
      ));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(accountsProvider).value ?? const [];
    return Scaffold(
      appBar: AppBar(title: const Text('账户与费率')),
      floatingActionButton: FloatingActionButton(
        tooltip: '添加账户',
        onPressed: () => _edit(context, ref, null),
        child: const Icon(Icons.add),
      ),
      body: ListView(children: [
        for (final a in accounts)
          ListTile(
            title: Text(a.name + (a.broker == null ? '' : ' · ${a.broker}')),
            subtitle: Text('佣金 ${_wan(a.commissionRate)}‱（最低 ${a.minCommission.toStringAsFixed(0)} 元）'
                ' · 印花税 ${_wan(a.stampTaxRate)}‱ · 过户费 ${_wan(a.transferFeeRate)}‱'),
            onTap: () => _edit(context, ref, a),
            trailing: accounts.length > 1
                ? IconButton(
                    tooltip: '删除账户',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (c) => AlertDialog(
                          content: Text('删除账户"${a.name}"？该账户的交易记录保留但不再显示在账户列表中。'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('取消')),
                            FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('删除')),
                          ],
                        ),
                      );
                      if (ok == true) await ref.read(accountRepositoryProvider).delete(a.id);
                    },
                  )
                : null,
          ),
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text('ETF / LOF 免印花税与过户费；新录入的交易按账户费率自动计算费用，可在录入时手动修改。'),
        ),
      ]),
    );
  }
}

extension on Account {
  FeeRates toRates() => FeeRates(
        commission: commissionRate,
        minCommission: minCommission,
        stampTax: stampTaxRate,
        transferFee: transferFeeRate,
      );
}
