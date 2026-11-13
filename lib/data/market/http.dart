import 'dart:convert';

import 'package:dio/dio.dart';

/// 行情请求共用的 HTTP 客户端：浏览器 UA、短超时。
Dio createMarketDio() => Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 8),
      responseType: ResponseType.bytes,
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0 Mobile Safari/537.36',
      },
    ));

dynamic decodeJsonBytes(List<int> bytes) => jsonDecode(utf8.decode(bytes));

/// 宽松数字解析：接受 num / 数字字符串，"-"、空值返回 null。
double? toNum(Object? v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v.trim());
  return null;
}

int toInt(Object? v) => toNum(v)?.round() ?? 0;
