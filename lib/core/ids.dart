import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// 生成 UUID v7（按时间有序），用作所有可同步实体的主键。
String newId() => _uuid.v7();
