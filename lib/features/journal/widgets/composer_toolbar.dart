import 'package:material_ui/material_ui.dart';

import '../../../domain/journal/entry_class.dart';
import '../../../domain/journal/vocab.dart';
import 'attribute_chips.dart';

/// 输入栏上方弹出的列表类型。
enum ComposerPanel { none, category, sub, tags, phrases }

/// 二级 = 一级分类展开的第一组；标签 = 其余组 + 情绪。
TagGroup? subGroupOf(EntryCategory? c) => groupsFor(c).firstOrNull;
List<TagGroup> tagGroupsOf(EntryCategory? c) => [...groupsFor(c).skip(1), emotionGroup];

/// 一排四个按钮：一级 / 二级 / 标签 / 快捷。按钮文字显示当前选择。
class ComposerToolbar extends StatelessWidget {
  const ComposerToolbar({
    super.key,
    required this.value,
    required this.open,
    required this.onToggle,
  });

  final EntryClass value;
  final ComposerPanel open;
  final ValueChanged<ComposerPanel> onToggle;

  @override
  Widget build(BuildContext context) {
    final cat = value.categoryEnum;
    final color = categoryColor(context, cat);
    final sub = subGroupOf(cat);
    final subLabel = sub == null ? null : labelFor(cat, sub.field, value.get(sub.field));
    final tagLabels = [
      for (final g in tagGroupsOf(cat)) ?labelFor(cat, g.field, value.get(g.field)),
    ];

    Widget button(ComposerPanel p, String text, {bool active = false, bool enabled = true, Color? tint}) {
      final isOpen = open == p;
      final theme = Theme.of(context);
      final c = tint ?? theme.colorScheme.primary;
      return Padding(
        padding: const EdgeInsets.only(right: 6),
        child: Material(
          color: active ? c.withValues(alpha: 0.14) : Colors.transparent,
          shape: StadiumBorder(
            side: BorderSide(
              color: isOpen ? c : (active ? c.withValues(alpha: 0.6) : theme.colorScheme.outlineVariant),
              width: isOpen ? 1.5 : 1,
            ),
          ),
          child: InkWell(
            key: Key('tb-${p.name}'),
            customBorder: const StadiumBorder(),
            onTap: enabled ? () => onToggle(isOpen ? ComposerPanel.none : p) : null,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 5, 6, 5),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(
                  text,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: !enabled ? theme.disabledColor : (active ? c : null),
                  ),
                ),
                Icon(isOpen ? Icons.arrow_drop_down : Icons.arrow_drop_up,
                    size: 18, color: enabled ? null : theme.disabledColor),
              ]),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
        children: [
          button(ComposerPanel.category, cat?.label ?? '一级', active: cat != null, tint: color),
          button(ComposerPanel.sub, subLabel ?? sub?.label ?? '二级',
              active: subLabel != null, enabled: sub != null, tint: color),
          button(ComposerPanel.tags, tagLabels.isEmpty ? '标签' : tagLabels.join('·'),
              active: tagLabels.isNotEmpty, tint: color),
          button(ComposerPanel.phrases, '快捷'),
        ],
      ),
    );
  }
}

/// 弹出列表中的一项。
class PanelItem {
  const PanelItem({
    required this.key,
    required this.label,
    required this.onTap,
    this.selected = false,
    this.badge,
    this.badgeColor,
    this.dotColor,
    this.trailing,
  });

  final String key;
  final String label;
  final VoidCallback onTap;
  final bool selected;
  final String? badge;
  final Color? badgeColor;

  /// 用彩色圆点代替徽标（一级分类列表）
  final Color? dotColor;
  final String? trailing;
}

/// 与 `$` 联想一致样式的弹出匹配列表，可分组。
class ChoicePanel extends StatelessWidget {
  const ChoicePanel({super.key, required this.sections, this.maxHeight = 232, this.empty});

  final List<(String?, List<PanelItem>)> sections;
  final double maxHeight;
  final String? empty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rows = <Widget>[];
    for (final (header, items) in sections) {
      if (header != null) {
        rows.add(Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 2),
          child: Text(header,
              style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline)),
        ));
      }
      for (final it in items) {
        final bc = it.badgeColor ?? theme.colorScheme.secondary;
        rows.add(InkWell(
          key: Key(it.key),
          onTap: it.onTap,
          child: Container(
            color: it.selected ? theme.colorScheme.primary.withValues(alpha: 0.08) : null,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            child: Row(children: [
              if (it.dotColor != null) ...[
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(color: it.dotColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 10),
              ],
              if (it.badge != null) ...[
                Container(
                  width: 40,
                  padding: const EdgeInsets.symmetric(vertical: 1),
                  decoration: BoxDecoration(
                    color: bc.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(it.badge!,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelSmall?.copyWith(color: bc)),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(it.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: it.selected
                        ? TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w600)
                        : null),
              ),
              if (it.trailing != null)
                Text(it.trailing!,
                    style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline)),
              if (it.selected)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(Icons.check, size: 18, color: theme.colorScheme.primary),
                ),
            ]),
          ),
        ));
      }
    }
    if (rows.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        child: Text(empty ?? '没有可选项',
            style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.outline)),
      );
    }
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: ListView(shrinkWrap: true, padding: EdgeInsets.zero, children: rows),
    );
  }
}

/// 一级 / 二级 / 标签 三种列表的内容。选择后通过 [onChanged] 返回新值，
/// [onAdvance] 用于自动切换到下一级列表。
List<(String?, List<PanelItem>)> classificationSections(
  BuildContext context, {
  required ComposerPanel panel,
  required EntryClass value,
  required ValueChanged<EntryClass> onChanged,
  required ValueChanged<ComposerPanel> onAdvance,
}) {
  final cat = value.categoryEnum;
  switch (panel) {
    case ComposerPanel.category:
      return [
        (
          null,
          [
            for (final c in EntryCategory.values)
              PanelItem(
                key: 'opt-category-${c.code}',
                label: c.label,
                dotColor: categoryColor(context, c),
                trailing: _categoryDesc[c],
                selected: c == cat,
                onTap: () {
                  final next = value.withCategory(c == cat ? null : c);
                  onChanged(next);
                  final hasSub = c != cat && subGroupOf(c) != null;
                  onAdvance(hasSub ? ComposerPanel.sub : ComposerPanel.none);
                },
              ),
          ]
        ),
      ];
    case ComposerPanel.sub:
      final g = subGroupOf(cat);
      if (g == null) return const [];
      return [
        (
          g.label,
          [
            for (final o in g.options)
              PanelItem(
                key: 'opt-${g.field.name}-${o.code}',
                label: o.label,
                badge: cat?.label,
                badgeColor: categoryColor(context, cat),
                selected: value.get(g.field) == o.code,
                onTap: () {
                  final selected = value.get(g.field) == o.code;
                  onChanged(value.withField(g.field, selected ? null : o.code));
                  // 有更多二级标签（方向 / 周期 / 时间）时自动展开标签列表
                  final more = groupsFor(cat).length > 1;
                  onAdvance(!selected && more ? ComposerPanel.tags : ComposerPanel.none);
                },
              ),
          ]
        ),
      ];
    case ComposerPanel.tags:
      return [
        for (final g in tagGroupsOf(cat))
          (
            g.label,
            [
              for (final o in g.options)
                PanelItem(
                  key: 'opt-${g.field.name}-${o.code}',
                  label: o.label,
                  badge: g.label,
                  badgeColor: g.field == TagField.emotion
                      ? Theme.of(context).colorScheme.tertiary
                      : categoryColor(context, cat),
                  selected: value.get(g.field) == o.code,
                  onTap: () => onChanged(
                      value.withField(g.field, value.get(g.field) == o.code ? null : o.code)),
                ),
            ]
          ),
      ];
    case ComposerPanel.phrases:
    case ComposerPanel.none:
      return const [];
  }
}

const _categoryDesc = {
  EntryCategory.observe: '现象、消息、资金',
  EntryCategory.judge: '对谁看多 / 看空',
  EntryCategory.plan: '准备买卖什么',
  EntryCategory.review: '事后总结',
  EntryCategory.other: '任意内容',
};

