import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/providers.dart';
import '../../data/db/app_database.dart';
import '../../data/market/models.dart';
import 'instrument_detail_page.dart';

/// 标的搜索：代码 / 名称 / 拼音首字母。需要先同步代码表。
class InstrumentSearchPage extends ConsumerStatefulWidget {
  const InstrumentSearchPage({super.key});

  @override
  ConsumerState<InstrumentSearchPage> createState() => _InstrumentSearchPageState();
}

class _InstrumentSearchPageState extends ConsumerState<InstrumentSearchPage> {
  List<Instrument> _results = const [];
  int? _total;

  @override
  void initState() {
    super.initState();
    ref.read(instrumentRepositoryProvider).count().then((n) {
      if (mounted) setState(() => _total = n);
    });
  }

  Future<void> _search(String q) async {
    final r = await ref.read(instrumentRepositoryProvider).search(q, limit: 50);
    if (mounted) setState(() => _results = r);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '代码 / 名称 / 拼音首字母，如 GZMT',
            border: InputBorder.none,
          ),
          onChanged: _search,
        ),
      ),
      body: _total == 0
          ? const Center(
              child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('代码表为空。\n请在 设置 → 数据源 中配置 Tushare token 并同步基础数据。',
                  textAlign: TextAlign.center),
            ))
          : ListView.builder(
              itemCount: _results.length,
              itemBuilder: (context, i) {
                final r = _results[i];
                return ListTile(
                  dense: true,
                  title: Text(r.name),
                  subtitle: Text(r.code),
                  trailing: Text(InstrumentType.fromCode(r.type).label,
                      style: theme.textTheme.labelSmall),
                  onTap: () => Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (_) => InstrumentDetailPage(code: r.code, name: r.name))),
                );
              },
            ),
    );
  }
}
