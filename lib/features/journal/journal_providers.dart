import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/db/app_database.dart';

/// 日记页当前查看的交易日。
class SelectedDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => today();

  DateTime today() {
    final now = ref.read(clockProvider)();
    return ref.read(tradingCalendarProvider).locate(now).tradeDate;
  }

  bool get isToday => state == today();

  void set(DateTime date) =>
      state = ref.read(tradingCalendarProvider).onOrAfter(date);
  void previous() => state = ref.read(tradingCalendarProvider).previous(state);
  void next() => state = ref.read(tradingCalendarProvider).next(state);
  void goToday() => state = today();
}

final selectedDateProvider =
    NotifierProvider<SelectedDateNotifier, DateTime>(SelectedDateNotifier.new);

final dayEntriesProvider =
    StreamProvider.autoDispose.family<List<JournalEntry>, DateTime>(
        (ref, date) => ref.watch(journalRepositoryProvider).watchDay(date));

final quickPhrasesProvider = StreamProvider.autoDispose<List<QuickPhrase>>(
    (ref) => ref.watch(quickPhraseRepositoryProvider).watchAll());
