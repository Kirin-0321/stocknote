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

/// 随消息发送的图片（视觉模型）。
class LlmImage {
  const LlmImage(this.mime, this.bytes);
  final String mime;
  final List<int> bytes;
  String get base64Data => base64Encode(bytes);
}

/// 可供模型调用的工具（function calling）。
class LlmTool {
  const LlmTool({required this.name, required this.description, required this.parameters});
  final String name;
  final String description;

  /// JSON Schema（type: object）
  final Map<String, dynamic> parameters;
}

/// 模型发起的一次工具调用。
class LlmToolCall {
  const LlmToolCall({required this.id, required this.name, required this.arguments});
  final String id;
  final String name;
  final Map<String, dynamic> arguments;

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'arguments': arguments};
  static LlmToolCall fromJson(Map<String, dynamic> j) => LlmToolCall(
        id: j['id'] as String,
        name: j['name'] as String,
        arguments: ((j['arguments'] as Map?) ?? const {}).cast<String, dynamic>(),
      );
}

class LlmMessage {
  const LlmMessage(this.role, this.content,
      {this.images = const [], this.toolCalls = const [], this.toolCallId, this.extra});
  const LlmMessage.system(this.content)
      : role = 'system',
        images = const [],
        toolCalls = const [],
        toolCallId = null,
        extra = null;
  const LlmMessage.user(this.content, {this.images = const []})
      : role = 'user',
        toolCalls = const [],
        toolCallId = null,
        extra = null;
  const LlmMessage.assistant(this.content, {this.toolCalls = const [], this.extra})
      : role = 'assistant',
        images = const [],
        toolCallId = null;

  /// 工具执行结果，回传给模型
  const LlmMessage.tool(String this.toolCallId, this.content)
      : role = 'tool',
        images = const [],
        toolCalls = const [],
        extra = null;

  /// system | user | assistant | tool
  final String role;
  final String content;
  final List<LlmImage> images;

  /// assistant：本轮发起的工具调用
  final List<LlmToolCall> toolCalls;

  /// tool：对应的调用 id
  final String? toolCallId;

  /// 需原样回传给同一模型的协议数据（DeepSeek 的 reasoning_content、Anthropic 的原始内容块）
  final Map<String, dynamic>? extra;
}

class LlmResponse {
  const LlmResponse({
    required this.text,
    this.tokensIn,
    this.tokensOut,
    required this.model,
    this.toolCalls = const [],
    this.extra,
  });
  final String text;
  final int? tokensIn;
  final int? tokensOut;
  final String model;
  final List<LlmToolCall> toolCalls;
  final Map<String, dynamic>? extra;

  /// 作为对话历史中的一条 assistant 消息
  LlmMessage toMessage() => LlmMessage.assistant(text, toolCalls: toolCalls, extra: extra);
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
  /// [json] 要求模型只输出一个 JSON 对象；[tools] 非空时模型可返回工具调用。
  Future<LlmResponse> chat(List<LlmMessage> messages,
      {bool json = false, int maxTokens = 4096, List<LlmTool> tools = const []});

  static LlmProvider of(LlmConfig c, {Dio? dio}) => switch (c.protocol) {
        LlmProtocol.openai => OpenAiCompatibleProvider(c, dio: dio),
        LlmProtocol.anthropic => AnthropicProvider(c, dio: dio),
      };
}

Dio _defaultDio() => Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      // 推理模型可能思考较久
      receiveTimeout: const Duration(minutes: 4),
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

/// 工具参数：OpenAI 兼容接口给 JSON 字符串，Anthropic 给对象；解析失败返回空。
Map<String, dynamic> _args(Object? raw) {
  if (raw is Map) return raw.cast<String, dynamic>();
  if (raw is String && raw.trim().isNotEmpty) {
    try {
      final v = jsonDecode(raw);
      if (v is Map) return v.cast<String, dynamic>();
    } catch (_) {}
  }
  return {};
}

/// OpenAI 兼容接口：DeepSeek / 通义 / Kimi / GLM / OpenAI / 自定义。
class OpenAiCompatibleProvider implements LlmProvider {
  OpenAiCompatibleProvider(this.config, {Dio? dio}) : _dio = dio ?? _defaultDio();
  final LlmConfig config;
  final Dio _dio;

  static Map<String, dynamic> _message(LlmMessage m) => switch (m.role) {
        'tool' => {'role': 'tool', 'tool_call_id': m.toolCallId, 'content': m.content},
        'assistant' => {
            'role': 'assistant',
            'content': m.content,
            if (m.toolCalls.isNotEmpty)
              'tool_calls': [
                for (final c in m.toolCalls)
                  {
                    'id': c.id,
                    'type': 'function',
                    'function': {'name': c.name, 'arguments': jsonEncode(c.arguments)},
                  },
              ],
            if (m.extra?['reasoning_content'] != null) 'reasoning_content': m.extra!['reasoning_content'],
          },
        _ => {
            'role': m.role,
            'content': m.images.isEmpty
                ? m.content
                : [
                    for (final img in m.images)
                      {
                        'type': 'image_url',
                        'image_url': {'url': 'data:${img.mime};base64,${img.base64Data}'},
                      },
                    {'type': 'text', 'text': m.content},
                  ],
          },
      };

  @override
  Future<LlmResponse> chat(List<LlmMessage> messages,
      {bool json = false, int maxTokens = 4096, List<LlmTool> tools = const []}) async {
    Future<Response<dynamic>> send(bool withFormat) => _dio.post(
          _join(config.baseUrl, '/chat/completions'),
          options: Options(headers: {'Authorization': 'Bearer ${config.apiKey}'}),
          data: {
            'model': config.model,
            'messages': [for (final m in messages) _message(m)],
            if (tools.isNotEmpty)
              'tools': [
                for (final t in tools)
                  {
                    'type': 'function',
                    'function': {'name': t.name, 'description': t.description, 'parameters': t.parameters},
                  },
              ],
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
    final msg = choices == null || choices.isEmpty
        ? const <String, dynamic>{}
        : ((choices.first as Map)['message'] as Map?) ?? const <String, dynamic>{};
    final usage = data['usage'] as Map?;
    final reasoning = msg['reasoning_content'];
    return LlmResponse(
      text: msg['content']?.toString() ?? '',
      tokensIn: (usage?['prompt_tokens'] as num?)?.toInt(),
      tokensOut: (usage?['completion_tokens'] as num?)?.toInt(),
      model: data['model']?.toString() ?? config.model,
      toolCalls: [
        for (final c in (msg['tool_calls'] as List? ?? const []))
          if (c is Map && c['function'] is Map)
            LlmToolCall(
              id: c['id']?.toString() ?? 'call_${c.hashCode}',
              name: (c['function'] as Map)['name'].toString(),
              arguments: _args((c['function'] as Map)['arguments']),
            ),
      ],
      extra: reasoning == null ? null : {'reasoning_content': reasoning},
    );
  }
}

/// Anthropic Messages API（raw HTTP）。
class AnthropicProvider implements LlmProvider {
  AnthropicProvider(this.config, {Dio? dio}) : _dio = dio ?? _defaultDio();
  final LlmConfig config;
  final Dio _dio;

  /// 转为 Messages API 格式：连续的工具结果合并为一条 user 消息；assistant 有原始内容块时原样回传。
  static List<Map<String, dynamic>> _messages(List<LlmMessage> messages) {
    final out = <Map<String, dynamic>>[];
    for (final m in messages) {
      if (m.role == 'system') continue;
      if (m.role == 'tool') {
        final block = {'type': 'tool_result', 'tool_use_id': m.toolCallId, 'content': m.content};
        final last = out.isEmpty ? null : out.last;
        if (last != null &&
            last['role'] == 'user' &&
            last['content'] is List &&
            (last['content'] as List).every((b) => b is Map && b['type'] == 'tool_result')) {
          (last['content'] as List).add(block);
        } else {
          out.add({
            'role': 'user',
            'content': [block],
          });
        }
        continue;
      }
      if (m.role == 'assistant') {
        final raw = m.extra?['content'];
        out.add({
          'role': 'assistant',
          'content': raw is List
              ? raw
              : [
                  if (m.content.isNotEmpty) {'type': 'text', 'text': m.content},
                  for (final c in m.toolCalls) {'type': 'tool_use', 'id': c.id, 'name': c.name, 'input': c.arguments},
                ],
        });
        continue;
      }
      out.add({
        'role': 'user',
        'content': m.images.isEmpty
            ? m.content
            : [
                for (final img in m.images)
                  {
                    'type': 'image',
                    'source': {'type': 'base64', 'media_type': img.mime, 'data': img.base64Data},
                  },
                {'type': 'text', 'text': m.content},
              ],
      });
    }
    return out;
  }

  @override
  Future<LlmResponse> chat(List<LlmMessage> messages,
      {bool json = false, int maxTokens = 4096, List<LlmTool> tools = const []}) async {
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
          if (tools.isNotEmpty)
            'tools': [
              for (final t in tools) {'name': t.name, 'description': t.description, 'input_schema': t.parameters},
            ],
          'messages': _messages(messages),
        },
      );
    } on DioException catch (e) {
      throw _wrap(e);
    }
    final data = r.data as Map;
    if (data['stop_reason'] == 'refusal') {
      throw const LlmException('模型拒绝了这次请求');
    }
    final blocks = (data['content'] as List? ?? const []);
    final text = [
      for (final b in blocks)
        if (b is Map && b['type'] == 'text') b['text'] as String,
    ].join();
    final usage = data['usage'] as Map?;
    final calls = [
      for (final b in blocks)
        if (b is Map && b['type'] == 'tool_use')
          LlmToolCall(id: b['id'] as String, name: b['name'] as String, arguments: _args(b['input'])),
    ];
    return LlmResponse(
      text: text,
      tokensIn: (usage?['input_tokens'] as num?)?.toInt(),
      tokensOut: (usage?['output_tokens'] as num?)?.toInt(),
      model: data['model']?.toString() ?? config.model,
      toolCalls: calls,
      // 有工具调用时，思考块等需在下一轮原样回传
      extra: calls.isEmpty ? null : {'content': blocks},
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
