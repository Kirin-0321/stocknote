import 'package:stocknote/data/ai/llm.dart';

/// 按顺序返回预设回复的假模型，并记录收到的消息。回复用完后重复最后一条。
class FakeLlm implements LlmProvider {
  FakeLlm(this.replies);
  final List<String> replies;
  final calls = <List<LlmMessage>>[];

  @override
  Future<LlmResponse> chat(List<LlmMessage> messages,
      {bool json = false, int maxTokens = 4096, List<LlmTool> tools = const []}) async {
    calls.add(messages);
    final i = calls.length - 1;
    return LlmResponse(
        text: replies[i < replies.length ? i : replies.length - 1], tokensIn: 100, tokensOut: 50, model: 'fake');
  }
}

/// 可返回工具调用的脚本化假模型；同时记录每次收到的工具列表。
class ScriptedLlm implements LlmProvider {
  ScriptedLlm(this.script);
  final List<LlmResponse> script;
  final calls = <List<LlmMessage>>[];
  final toolLists = <List<String>>[];

  @override
  Future<LlmResponse> chat(List<LlmMessage> messages,
      {bool json = false, int maxTokens = 4096, List<LlmTool> tools = const []}) async {
    calls.add(List.of(messages));
    toolLists.add([for (final t in tools) t.name]);
    final i = calls.length - 1;
    return script[i < script.length ? i : script.length - 1];
  }
}

LlmResponse toolCall(String name, [Map<String, dynamic> args = const {}, String? id]) => LlmResponse(
      text: '',
      model: 'fake',
      toolCalls: [LlmToolCall(id: id ?? 'call_$name', name: name, arguments: args)],
      extra: const {'reasoning_content': '先查数据'},
    );

LlmResponse answer(String text) => LlmResponse(text: text, model: 'fake');

const validAnalysisJson = '''```json
{"sentiment_score": 62, "trend": "震荡偏强", "key_levels": {"support": [3280, 3250], "resistance": [3350]},
 "highlights": ["成交额放大"], "risks": ["高位股分歧"],
 "outlook": {"target": "000001.SH", "horizon": "T+1", "direction": "看多", "confidence": 60},
 "summary": "偏强震荡"}
```''';
