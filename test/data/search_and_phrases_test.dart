import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stocknote/core/calendar/trading_calendar.dart';
import 'package:stocknote/core/time/market_clock.dart';
import 'package:stocknote/data/db/app_database.dart';
import 'package:stocknote/data/repo/journal_repository.dart';
import 'package:stocknote/data/repo/quick_phrase_repository.dart';
import 'package:stocknote/domain/journal/entry_class.dart';
import 'package:stocknote/domain/journal/vocab.dart';

void main() {
  late AppDatabase db;
  late JournalRepository journal;
  final clock = MarketClock.fromMarket(2026, 11, 13, 10, 5);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    journal = JournalRepository(db, TradingCalendar(), now: () => clock);
  });
  tearDown(() => db.close());

  group('搜索', () {
    setUp(() async {
      await journal.create(
          content: '放量突破 #突破',
          tags: ['突破'],
          classification: const EntryClass(category: 'judge', stance: 'bull'));
      await journal.create(
          content: '\$600519 缩量回调',
          instrumentCodes: ['600519'],
          classification:
              const EntryClass(category: 'observe', subcategory: 'stock'));
      await journal.create(
          content: '追高了 #教训',
          tags: ['教训'],
          classification: const EntryClass(category: 'other', emotion: 'fomo'));
    });

    test('关键词匹配内容 / 标签 / 代码，多个词需全部命中', () async {
      expect((await journal.search(const JournalQuery(text: '突破'))).length, 1);
      expect((await journal.search(const JournalQuery(text: '600519'))).length, 1);
      expect((await journal.search(const JournalQuery(text: '追高 教训'))).length, 1);
      expect(await journal.search(const JournalQuery(text: '追高 突破')), isEmpty);
    });

    test('按一级 / 二级分类过滤', () async {
      expect((await journal.search(const JournalQuery(category: 'judge'))).length, 1);
      expect((await journal.search(const JournalQuery(category: 'observe', subcategory: 'stock')))
          .single
          .content, contains('缩量'));
      expect(await journal.search(const JournalQuery(category: 'review')), isEmpty);
    });

    test('按要素与标签过滤', () async {
      expect((await journal.search(const JournalQuery(emotion: 'fomo'))).single.content,
          contains('追高'));
      expect((await journal.search(const JournalQuery(stance: 'bull'))).length, 1);
      expect((await journal.search(const JournalQuery(tag: '教训'))).length, 1);
      expect((await journal.search(const JournalQuery(instrument: '600519'))).length, 1);
    });

    test('软删除不出现在结果中，撤销后恢复', () async {
      final e = (await journal.search(const JournalQuery(text: '突破'))).single;
      await journal.delete(e.id);
      expect(await journal.search(const JournalQuery(text: '突破')), isEmpty);
      await journal.restore(e.id);
      expect((await journal.search(const JournalQuery(text: '突破'))).length, 1);
    });

    test('LIKE 通配符被视为普通字符', () async {
      expect(await journal.search(const JournalQuery(text: '%')), hasLength(3));
    });
  });

  group('常用短语', () {
    late QuickPhraseRepository phrases;
    setUp(() => phrases = QuickPhraseRepository(db, now: () => clock));

    test('首次写入默认短语，只写一次', () async {
      await phrases.seedDefaultsIfNeeded();
      await phrases.seedDefaultsIfNeeded();
      final list = await phrases.watchAll().first;
      expect(list.map((p) => p.phrase), defaultQuickPhrases);
    });

    test('删光后不会重新补回默认短语', () async {
      await phrases.seedDefaultsIfNeeded();
      for (final p in await phrases.watchAll().first) {
        await phrases.delete(p.id);
      }
      await phrases.seedDefaultsIfNeeded();
      expect(await phrases.watchAll().first, isEmpty);
    });

    test('添加追加到末尾，重排生效，空白忽略', () async {
      await phrases.add('A');
      await phrases.add('B');
      await phrases.add('   ');
      var list = await phrases.watchAll().first;
      expect(list.map((p) => p.phrase), ['A', 'B']);
      await phrases.reorder([list[1].id, list[0].id]);
      list = await phrases.watchAll().first;
      expect(list.map((p) => p.phrase), ['B', 'A']);
    });
  });
}


