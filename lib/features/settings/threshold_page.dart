import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/providers.dart';
import '../../data/market/models.dart';
import '../../domain/verify/threshold.dart';
import '../../domain/verify/verifier.dart';

/// 判定阈值设置（spec 3.3.2）：全局、按标的类型、按类型 + 周期。
class ThresholdPage extends ConsumerStatefulWidget {
  const ThresholdPage({super.key});

  @override
  ConsumerState<ThresholdPage> createState() => _ThresholdPageState();
}

class _ThresholdPageState extends ConsumerState<ThresholdPage> {
  ThresholdConfig? _cfg;
  var _dirty = false;

  static const _types = [
    InstrumentType.marketIndex,
    InstrumentType.sector,
    InstrumentType.etf,
    InstrumentType.stock,
  ];
  static const _horizons = ['close', 't1', 't5', 'mid'];
  static const _steps = [0.1, 0.2, 0.3, 0.5, 0.8, 1.0, 1.5, 2.0, 3.0, 5.0];

  @override
  void initState() {
    super.initState();
    ref.read(thresholdRepositoryProvider).load().then((c) {
      if (mounted) setState(() => _cfg = c);
    });
  }

  Future<void> _save() async {
    await ref.read(thresholdRepositoryProvider).save(_cfg!);
    ref.invalidate(thresholdConfigProvider);
    if (!mounted) return;
    setState(() => _dirty = false);
    final reverify = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('阈值已保存'),
        content: const Text('新阈值会用于之后的判定。是否按新阈值重新判定历史判断？（手动判定的结果保留）'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('仅影响新判断')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('重新判定历史')),
        ],
      ),
    );
    if (reverify == true) {
      await ref.read(predictionRepositoryProvider).clearAutoResults();
      final r = await ref.read(verificationServiceProvider).runDue();
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('已重新判定 ${r.verified} 条')));
      }
    }
  }

  Widget _picker(double value, ValueChanged<double> onChanged, {bool allowInherit = false, bool inherited = false}) {
    return DropdownButton<double>(
      value: inherited ? -1 : value,
      underline: const SizedBox(),
      items: [
        if (allowInherit) const DropdownMenuItem(value: -1, child: Text('跟随类型')),
        for (final s in {..._steps, if (!inherited) value}.toList()..sort())
          DropdownMenuItem(value: s, child: Text('±${s.toStringAsFixed(1)}%')),
      ],
      onChanged: (v) => onChanged(v!),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cfg = _cfg;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('判定阈值'),
        actions: [
          TextButton(onPressed: _dirty ? _save : null, child: const Text('保存')),
        ],
      ),
      body: cfg == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Text(
                  '涨跌幅在 ±阈值以内算"震荡"。看多需涨幅 ≥ 阈值才算正确，0~阈值为部分正确；看空对称。\n'
                  '优先级：单条判断设置 > 类型 + 周期 > 类型 > 全局。',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                ),
              ),
              ListTile(
                title: const Text('全局默认'),
                trailing: _picker(cfg.global, (v) => setState(() {
                      _cfg = cfg.copyWith(global: v);
                      _dirty = true;
                    })),
              ),
              const Divider(),
              for (final t in _types)
                ExpansionTile(
                  title: Text(t.label),
                  subtitle: Text('±${cfg.resolve(t, 't1').toStringAsFixed(1)}%'
                      '${cfg.byTypeHorizon.keys.any((k) => k.$1 == t) ? '（部分周期单独设置）' : ''}'),
                  trailing: _picker(cfg.byType[t] ?? cfg.global, (v) => setState(() {
                        _cfg = cfg.copyWith(byType: {...cfg.byType, t: v});
                        _dirty = true;
                      })),
                  children: [
                    for (final h in _horizons)
                      ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.only(left: 32, right: 16),
                        title: Text('周期：${horizonLabels[h]}'),
                        trailing: _picker(
                          cfg.byTypeHorizon[(t, h)] ?? cfg.resolve(t, h),
                          allowInherit: true,
                          inherited: !cfg.byTypeHorizon.containsKey((t, h)),
                          (v) => setState(() {
                            final m = {...cfg.byTypeHorizon};
                            v < 0 ? m.remove((t, h)) : m[(t, h)] = v;
                            _cfg = cfg.copyWith(byTypeHorizon: m);
                            _dirty = true;
                          }),
                        ),
                      ),
                  ],
                ),
              const SizedBox(height: 24),
              Center(
                child: TextButton(
                  onPressed: () => setState(() {
                    _cfg = const ThresholdConfig();
                    _dirty = true;
                  }),
                  child: const Text('恢复默认（指数 0.3 / 板块 0.5 / ETF 0.5 / 个股 1.0）'),
                ),
              ),
            ]),
    );
  }
}
