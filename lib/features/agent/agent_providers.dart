import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/time/market_clock.dart';
import '../../data/agent/agent_service.dart';
import '../../data/agent/agent_tools.dart';
import '../../data/db/app_database.dart';
import '../../data/repo/agent_repository.dart';
import '../portfolio/portfolio_providers.dart';

final agentRepositoryProvider =
    Provider((ref) => AgentRepository(ref.watch(databaseProvider), now: ref.watch(clockProvider)));

final agentServiceProvider = Provider((ref) {
  final analysis = ref.watch(marketAnalysisServiceProvider);
  return AgentService(
    repo: ref.watch(agentRepositoryProvider),
    toolDeps: AgentToolDeps(
      journal: ref.watch(journalRepositoryProvider),
      predictions: ref.watch(predictionRepositoryProvider),
      trades: ref.watch(tradeRepositoryProvider),
      instruments: ref.watch(instrumentRepositoryProvider),
      analyses: ref.watch(aiAnalysisRepositoryProvider),
      agent: ref.watch(agentRepositoryProvider),
      market: ref.watch(marketServiceProvider),
      calendar: ref.watch(tradingCalendarProvider),
      overview: analysis.overview,
      costMethod: () => ref.read(costMethodProvider),
      now: ref.watch(clockProvider),
    ),
    aiConfig: ref.watch(aiConfigRepositoryProvider),
    settings: ref.watch(settingsStoreProvider),
    journalService: ref.watch(journalServiceProvider),
    calendar: ref.watch(tradingCalendarProvider),
    providerFactory: ref.watch(llmFactoryProvider),
    now: ref.watch(clockProvider),
  );
});

final agentThreadsProvider =
    StreamProvider<List<AgentThread>>((ref) => ref.watch(agentRepositoryProvider).watchThreads());

final agentMessagesProvider = StreamProvider.family<List<AgentMessage>, String>(
    (ref, threadId) => ref.watch(agentRepositoryProvider).watchMessages(threadId));

final agentMemoriesProvider =
    StreamProvider<List<AgentMemory>>((ref) => ref.watch(agentRepositoryProvider).watchMemories());

final agentSettingsProvider = FutureProvider<AgentSettings>((ref) => ref.watch(agentServiceProvider).loadSettings());

/// 某天日记作为上下文（在日记页打开助手时附带）。
Future<AgentPageContext?> journalDayContext(WidgetRef ref, DateTime date) async {
  final entries = await ref.read(journalRepositoryProvider).watchDay(date).first;
  final label = '${date.month}月${date.day}日的日记';
  if (entries.isEmpty) return AgentPageContext(label: label, text: '用户正在看${date.month}月${date.day}日的日记页，当天还没有记录。');
  final b = StringBuffer()..writeln('用户正在看${date.month}月${date.day}日的日记页，当天共 ${entries.length} 条：');
  for (final e in entries) {
    final m = MarketClock.toMarket(DateTime.fromMillisecondsSinceEpoch(e.ts, isUtc: true));
    b.writeln('- ${m.hour.toString().padLeft(2, '0')}:${m.minute.toString().padLeft(2, '0')} '
        '[${e.category ?? '未分类'}${e.stance == null ? '' : '/${e.stance}'}] ${e.content} (id: ${e.id})');
  }
  return AgentPageContext(label: label, text: b.toString());
}
