import 'package:flutter/foundation.dart' show immutable;

import 'vocab.dart';

/// 一条日记的分类要素（一级分类 + 二级展开 + 情绪），均为存库 code。
@immutable
class EntryClass {
  const EntryClass({
    this.category,
    this.subcategory,
    this.stance,
    this.action,
    this.horizon,
    this.emotion,
  });

  final String? category;
  final String? subcategory;
  final String? stance;
  final String? action;
  final String? horizon;
  final String? emotion;

  static const empty = EntryClass();

  EntryCategory? get categoryEnum => byCode(EntryCategory.values, category);

  String? get(TagField f) => switch (f) {
        TagField.subcategory => subcategory,
        TagField.stance => stance,
        TagField.action => action,
        TagField.horizon => horizon,
        TagField.emotion => emotion,
      };

  /// 设置某个二级字段（null 表示取消）。
  EntryClass withField(TagField f, String? v) => EntryClass(
        category: category,
        subcategory: f == TagField.subcategory ? v : subcategory,
        stance: f == TagField.stance ? v : stance,
        action: f == TagField.action ? v : action,
        horizon: f == TagField.horizon ? v : horizon,
        emotion: f == TagField.emotion ? v : emotion,
      );

  /// 切换一级分类：清空与分类相关的二级字段，保留情绪。
  EntryClass withCategory(EntryCategory? c) =>
      EntryClass(category: c?.code, emotion: emotion);

  /// 保存前的规范化：未选一级分类视为"其他"；去掉不属于当前分类的字段。
  EntryClass normalized() {
    final c = categoryEnum ?? EntryCategory.other;
    final allowed = {for (final g in groupsFor(c)) g.field};
    String? keep(TagField f) => allowed.contains(f) ? get(f) : null;
    return EntryClass(
      category: c.code,
      subcategory: keep(TagField.subcategory),
      stance: keep(TagField.stance),
      action: keep(TagField.action),
      horizon: keep(TagField.horizon),
      emotion: emotion,
    );
  }

  /// 卡片展示用的标签文字，如 `判断·个股`、`看多`、`T+1`。
  List<String> labels() {
    final c = categoryEnum;
    final out = <String>[];
    final sub = labelFor(c, TagField.subcategory, subcategory);
    if (c != null && c != EntryCategory.other) {
      out.add(sub == null ? c.label : '${c.label}·$sub');
    } else if (sub != null) {
      out.add(sub);
    }
    for (final f in [TagField.stance, TagField.action, TagField.horizon]) {
      final l = labelFor(c, f, get(f));
      if (l != null) out.add(l);
    }
    return out;
  }

  @override
  bool operator ==(Object other) =>
      other is EntryClass &&
      other.category == category &&
      other.subcategory == subcategory &&
      other.stance == stance &&
      other.action == action &&
      other.horizon == horizon &&
      other.emotion == emotion;

  @override
  int get hashCode => Object.hash(category, subcategory, stance, action, horizon, emotion);
}

