import 'dart:convert';

import 'package:dio/dio.dart';

/// LLM 接口协议。
enum LlmProtocol { openai, anthropic }

/// 内置模型提供方预设（spec 3.1.2）。模型名可自由填写，[models] 只是候选。
class LlmPreset {
  const LlmPreset({
    required this.id,
    required this.name,
    required this.protocol,
    required this.baseUrl,
    required this.models,
    this.keyHint = '',
  });

  final String id;
  final String name;
  final LlmProtocol protocol;
  final String baseUrl;
  final List<String> models;
  final String keyHint;

  String get defaultModel => models.first;

  static const deepseek = LlmPreset(
    id: 'deepseek',
    name: 'DeepSeek',
    protocol: LlmProtocol.openai,
    baseUrl: 'https://api.deepseek.com',
    models: ['deepseek-flash', 'deepseek-v4-pro'],
    keyHint: 'platform.deepseek.com 获取',
  );

  static const all = [
    deepseek,
    LlmPreset(
      id: 'qwen',
      name: '通义千问',
      protocol: LlmProtocol.openai,
      baseUrl: 'https://dashscope.aliyuncs.com/compatible-mode/v1',
      models: ['qwen-plus', 'qwen-max', 'qwen-turbo', 'qwen-vl-max'],
    ),
    LlmPreset(
      id: 'kimi',
      name: 'Kimi',
      protocol: LlmProtocol.openai,
      baseUrl: 'https://api.moonshot.cn/v1',
      models: ['kimi-latest', 'moonshot-v1-32k'],
    ),
    LlmPreset(
      id: 'zhipu',
      name: '智谱 GLM',
      protocol: LlmProtocol.openai,
      baseUrl: 'https://open.bigmodel.cn/api/paas/v4',
      models: ['glm-4-plus', 'glm-4-flash', 'glm-4v-plus'],
    ),
    LlmPreset(
      id: 'anthropic',
      name: 'Anthropic Claude',
      protocol: LlmProtocol.anthropic,
      baseUrl: 'https://api.anthropic.com',
      models: ['claude-opus-5-5', 'claude-sonnet-5-5', 'claude-haiku-5-5'],
    ),
    LlmPreset(
      id: 'openai',
      name: 'OpenAI',
      protocol: LlmProtocol.openai,
      baseUrl: 'https://api.openai.com/v1',
      models: ['gpt-4o', 'gpt-4o-mini'],
    ),
    LlmPreset(
      id: 'custom',
      name: '自定义（OpenAI 兼容）',
      protocol: LlmProtocol.openai,
      baseUrl: '',
      models: [''],
    ),
  ];

  static LlmPreset byId(String? id) => all.firstWhere((p) => p.id == id, orElse: () => deepseek);
}

/// 一次调用实际使用的模型配置。
class LlmConfig {
  const LlmConfig({
    required this.presetId,
    required this.protocol,
    required this.baseUrl,
    required this.model,
    required this.apiKey,
    this.effort,
  });

  final String presetId;
  final LlmProtocol protocol;
  final String baseUrl;
  final String model;
  final String apiKey;

  /// 思考强度（low / high / max 等），null 用模型默认
  final String? effort;
}

class LlmMessage {
  const LlmMessage(this.role, this.content);
  const LlmMessage.system(this.content) : role = 'system';
  const LlmMessage.user(this.content) : role = 'user';
  const LlmMessage.assistant(this.content) : role = 'assistant';

  /// system | user | assistant
  final String role;
  final String content;
}

class LlmResponse {
  const LlmResponse({required this.text, this.tokensIn, this.tokensOut, required this.model});
  final String text;
  final int? tokensIn;
  final int? tokensOut;
  final String model;
}

class LlmException implements Exception {
  const LlmException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;

  /// Key 无效 / 无权限
  bool get isAuth => statusCode == 401 || statusCode == 403;

  @override
  String toString() => message;
}

abstract class LlmProvider {
  /// [json] 要求模型只输出一个 JSON 对象。
  Future<LlmResponse> chat(List<LlmMessage> messages, {bool json = false, int maxTokens = 4096});

  static LlmProvider of(LlmConfig c, {Dio? dio}) => switch (c.protocol) {
        LlmProtocol.openai => OpenAiCompatibleProvider(c, dio: dio),
        LlmProtocol.anthropic => AnthropicProvider(c, dio: dio),
      };
}

Dio _defaultDio() => Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      // 推理模型可能思考较久
      receiveTimeout: const Duration(minutes: 3),
      contentType: 'application/json',
      responseType: ResponseType.json,
    ));

String _join(String base, String path) =>
    '${base.endsWith('/') ? base.substring(0, base.length - 1) : base}$path';

LlmException _wrap(DioException e) {
  final code = e.response?.statusCode;
  final data = e.response?.data;
  String? detail;
  if (data is Map) {
    final err = data['error'];
    detail = err is Map ? '${err['message'] ?? err}' : (err?.toString() ?? data['message']?.toString());
  } else if (data is String && data.isNotEmpty) {
    detail = data.length > 200 ? data.substring(0, 200) : data;
  }
  final msg = switch (code) {
    401 || 403 => 'API Key 无效或无权限',
    402 => '账户余额不足',
    429 => '请求过于频繁或额度已用完',
    null => '网络错误：${e.message ?? e.type.name}',
    _ => 'HTTP $code',
  };
  return LlmException(detail == null ? msg : '$msg（$detail）', statusCode: code);
}

/// OpenAI 兼容接口：DeepSeek / 通义 / Kimi / GLM / OpenAI / 自定义。
class OpenAiCompatibleProvider implements LlmProvider {
  OpenAiCompatibleProvider(this.config, {Dio? dio}) : _dio = dio ?? _defaultDio();
  final LlmConfig config;
  final Dio _dio;

  @override
  Future<LlmResponse> chat(List<LlmMessage> messages, {bool json = false, int maxTokens = 4096}) async {
    Future<Response<dynamic>> send(bool withFormat) => _dio.post(
          _join(config.baseUrl, '/chat/completions'),
          options: Options(headers: {'Authorization': 'Bearer ${config.apiKey}'}),
          data: {
            'model': config.model,
            'messages': [for (final m in messages) {'role': m.role, 'content': m.content}],
            // 思考内容也计入输出 token，开思考时放宽上限
            'max_tokens': config.effort == null ? maxTokens : (maxTokens < 32000 ? 32000 : maxTokens),
            'stream': false,
            if (config.effort != null) 'reasoning_effort': config.effort,
            if (withFormat) 'response_format': {'type': 'json_object'},
          },
        );
    Response<dynamic> r;
    try {
      r = await send(json);
    } on DioException catch (e) {
      // 部分模型不支持 response_format，去掉后重试（提示词里已要求 JSON）
      if (json && e.response?.statusCode == 400) {
        try {
          r = await send(false);
        } on DioException catch (e2) {
          throw _wrap(e2);
        }
      } else {
        throw _wrap(e);
      }
    }
    final data = r.data is String ? jsonDecode(r.data as String) : r.data;
    final choices = (data as Map)['choices'] as List?;
    final text = choices == null || choices.isEmpty
        ? ''
        : ((choices.first as Map)['message'] as Map?)?['content']?.toString() ?? '';
    final usage = data['usage'] as Map?;
    return LlmResponse(
      text: text,
      tokensIn: (usage?['prompt_tokens'] as num?)?.toInt(),
      tokensOut: (usage?['completion_tokens'] as num?)?.toInt(),
      model: data['model']?.toString() ?? config.model,
    );
  }
}

/// Anthropic Messages API（raw HTTP）。
class AnthropicProvider implements LlmProvider {
  AnthropicProvider(this.config, {Dio? dio}) : _dio = dio ?? _defaultDio();
  final LlmConfig config;
  final Dio _dio;

  @override
  Future<LlmResponse> chat(List<LlmMessage> messages, {bool json = false, int maxTokens = 4096}) async {
    final system = messages.where((m) => m.role == 'system').map((m) => m.content).join('\n\n');
    Response<dynamic> r;
    try {
      r = await _dio.post(
        _join(config.baseUrl, '/v1/messages'),
        options: Options(headers: {
          'x-api-key': config.apiKey,
          'anthropic-version': '2026-10-21',
        }),
        data: {
          'model': config.model,
          // 新模型默认自适应思考，留足输出空间
          'max_tokens': maxTokens < 16000 ? 16000 : maxTokens,
          if (system.isNotEmpty) 'system': system,
          if (config.effort != null) 'output_config': {'effort': config.effort},
          'messages': [
            for (final m in messages)
              if (m.role != 'system') {'role': m.role, 'content': m.content},
          ],
        },
      );
    } on DioException catch (e) {
      throw _wrap(e);
    }
    final data = r.data as Map;
    if (data['stop_reason'] == 'refusal') {
      throw const LlmException('模型拒绝了这次请求');
    }
    final text = [
      for (final b in (data['content'] as List? ?? const []))
        if (b is Map && b['type'] == 'text') b['text'] as String,
    ].join();
    final usage = data['usage'] as Map?;
    return LlmResponse(
      text: text,
      tokensIn: (usage?['input_tokens'] as num?)?.toInt(),
      tokensOut: (usage?['output_tokens'] as num?)?.toInt(),
      model: data['model']?.toString() ?? config.model,
    );
  }
}

/// 从模型输出中取出 JSON 对象：容忍 ```json 代码块与前后说明文字。
Map<String, dynamic>? extractJsonObject(String text) {
  final start = text.indexOf('{');
  final end = text.lastIndexOf('}');
  if (start < 0 || end <= start) return null;
  try {
    final v = jsonDecode(text.substring(start, end + 1));
    return v is Map<String, dynamic> ? v : null;
  } catch (_) {
    return null;
  }
}
