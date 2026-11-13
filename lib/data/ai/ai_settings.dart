import 'dart:convert';

import 'package:flutter/foundation.dart' show immutable;

import '../settings/settings_store.dart';
import 'llm.dart';

/// 使用 AI 的任务，各自可选模型（spec 3.1.2）。
enum AiTask {
  analysis('analysis', '大盘分析'),
  agent('agent', 'Agent 助手'),
  vision('vision', '图片识别', hint: '需支持图片输入的模型'),
  table('table', '表格字段映射');

  const AiTask(this.code, this.label, {this.hint});
  final String code;
  final String label;
  final String? hint;
}

@immutable
class TaskModel {
  const TaskModel(this.presetId, this.model, {this.effort = 'max'});
  final String presetId;
  final String model;

  /// 思考强度；'' 表示不指定（模型默认）
  final String effort;

  static const fallback = TaskModel('deepseek', 'deepseek-flash');
  static const efforts = ['', 'low', 'high', 'max'];
  static const effortLabels = {'': '默认', 'low': '低', 'high': '高', 'max': '最高 (max)'};

  TaskModel copyWith({String? presetId, String? model, String? effort}) =>
      TaskModel(presetId ?? this.presetId, model ?? this.model, effort: effort ?? this.effort);

  Map<String, dynamic> toJson() => {'preset': presetId, 'model': model, 'effort': effort};
  static TaskModel fromJson(Object? j) => j is Map
      ? TaskModel(j['preset']?.toString() ?? 'deepseek', j['model']?.toString() ?? 'deepseek-flash',
          effort: j['effort']?.toString() ?? 'max')
      : fallback;
}

/// AI 设置（非敏感部分）。API Key 存系统安全存储。
@immutable
class AiSettings {
  const AiSettings({
    this.tasks = const {},
    this.baseUrls = const {},
    this.scheduleEnabled = true,
    this.includeJournal = true,
  });

  final Map<AiTask, TaskModel> tasks;

  /// 预设 id → 自定义 base URL（为空用预设默认）
  final Map<String, String> baseUrls;

  /// 交易日 9:35 / 11:35 / 15:05 自动分析
  final bool scheduleEnabled;

  /// 分析时附带最近日记中的观点
  final bool includeJournal;

  TaskModel taskModel(AiTask t) => tasks[t] ?? TaskModel.fallback;

  String baseUrlOf(String presetId) {
    final custom = baseUrls[presetId];
    return custom == null || custom.isEmpty ? LlmPreset.byId(presetId).baseUrl : custom;
  }

  AiSettings copyWith({
    Map<AiTask, TaskModel>? tasks,
    Map<String, String>? baseUrls,
    bool? scheduleEnabled,
    bool? includeJournal,
  }) =>
      AiSettings(
        tasks: tasks ?? this.tasks,
        baseUrls: baseUrls ?? this.baseUrls,
        scheduleEnabled: scheduleEnabled ?? this.scheduleEnabled,
        includeJournal: includeJournal ?? this.includeJournal,
      );

  Map<String, dynamic> toJson() => {
        'tasks': {for (final e in tasks.entries) e.key.code: e.value.toJson()},
        'baseUrls': baseUrls,
        'schedule': scheduleEnabled,
        'includeJournal': includeJournal,
      };

  static AiSettings fromJson(Map<String, dynamic> j) => AiSettings(
        tasks: {
          for (final t in AiTask.values)
            if ((j['tasks'] as Map?)?[t.code] != null) t: TaskModel.fromJson((j['tasks'] as Map)[t.code]),
        },
        baseUrls: ((j['baseUrls'] as Map?) ?? const {}).map((k, v) => MapEntry('$k', '$v')),
        scheduleEnabled: j['schedule'] != false,
        includeJournal: j['includeJournal'] != false,
      );
}

/// 构建时从 .env 注入的 DeepSeek Key（`--dart-define-from-file=.env`），App 内未填写时使用。
const _envDeepseekKey = String.fromEnvironment('DEEPSEEK_API_KEY');

/// AI 配置读写：设置存 app_meta，Key 存安全存储（每个提供方一个）。
class AiConfigRepository {
  AiConfigRepository(this._settings, this._secrets, {String? envDeepseekKey})
      : _envKey = envDeepseekKey ?? _envDeepseekKey;

  final SettingsStore _settings;
  final SecretStore _secrets;
  final String _envKey;

  static const _key = 'ai.settings';
  static String secretKeyOf(String presetId) => 'llm_key_$presetId';

  Future<AiSettings> load() async {
    final raw = await _settings.raw(_key);
    if (raw == null) return const AiSettings();
    try {
      return AiSettings.fromJson((jsonDecode(raw) as Map).cast<String, dynamic>());
    } catch (_) {
      return const AiSettings();
    }
  }

  Future<void> save(AiSettings s) => _settings.setRaw(_key, jsonEncode(s.toJson()));

  Future<String?> apiKey(String presetId) async {
    final k = await _secrets.read(secretKeyOf(presetId));
    if (k != null && k.isNotEmpty) return k;
    if (presetId == 'deepseek' && _envKey.isNotEmpty) return _envKey;
    return null;
  }

  /// Key 是否来自构建时注入（设置页提示用）
  Future<bool> keyFromEnv(String presetId) async {
    final k = await _secrets.read(secretKeyOf(presetId));
    return (k == null || k.isEmpty) && presetId == 'deepseek' && _envKey.isNotEmpty;
  }

  Future<void> setApiKey(String presetId, String? key) =>
      _secrets.write(secretKeyOf(presetId), key?.trim());

  /// 某任务实际使用的模型配置；未配置 Key 时返回 null。
  Future<LlmConfig?> configFor(AiTask task, {AiSettings? settings}) async {
    final s = settings ?? await load();
    final tm = s.taskModel(task);
    final key = await apiKey(tm.presetId);
    final base = s.baseUrlOf(tm.presetId);
    if (key == null || base.isEmpty || tm.model.isEmpty) return null;
    return LlmConfig(
      presetId: tm.presetId,
      protocol: LlmPreset.byId(tm.presetId).protocol,
      baseUrl: base,
      model: tm.model,
      apiKey: key,
      effort: tm.effort.isEmpty ? null : tm.effort,
    );
  }
}
