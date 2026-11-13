import 'package:stocknote/data/ai/llm.dart';

/// 按顺序返回预设回复的假模型，并记录收到的消息。回复用完后重复最后一条。
class FakeLlm implements LlmProvider {
  FakeLlm(this.replies);
  final List<String> replies;
  final calls = <List<LlmMessage>>[];

  @override
  Future<LlmResponse> chat(List<LlmMessage> messages, {bool json = false, int maxTokens = 4096}) async {
    calls.add(messages);
    final i = calls.length - 1;
    return LlmResponse(
        text: replies[i < replies.length ? i : replies.length - 1], tokensIn: 100, tokensOut: 50, model: 'fake');
  }
}

const validAnalysisJson = '''```json
{"sentiment_score": 62, "trend": "震荡偏强", "key_levels": {"support": [3280, 3250], "resistance": [3350]},
 "highlights": ["成交额放大"], "risks": ["高位股分歧"],
 "outlook": {"target": "000001.SH", "horizon": "T+1", "direction": "看多", "confidence": 60},
 "summary": "偏强震荡"}
```''';
