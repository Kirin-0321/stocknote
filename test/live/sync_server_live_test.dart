@Tags(['live'])
library;

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stocknote/data/sync/cloud_sync.dart';

/// 线上同步服务器：证书指纹固定校验（不创建账户）。
void main() {
  final url = Platform.environment['SYNC_SERVER_URL'];
  final pin = Platform.environment['SYNC_CERT_SHA256'];
  final skip = url == null || pin == null ? '需要 SYNC_SERVER_URL 与 SYNC_CERT_SHA256' : null;

  test('指纹匹配时可连接', () async {
    final r = await createSyncDio(url!, certSha256: pin).get<Map<String, dynamic>>('/api/health');
    expect(r.data!['ok'], isTrue);
  }, skip: skip);

  test('指纹不匹配或未固定时拒绝自签证书', () async {
    await expectLater(
      createSyncDio(url!, certSha256: 'ab' * 32).get('/api/health'),
      throwsA(isA<DioException>()),
    );
    await expectLater(createSyncDio(url).get('/api/health'), throwsA(isA<DioException>()));
  }, skip: skip);
}
