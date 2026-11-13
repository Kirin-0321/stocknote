import 'package:material_ui/material_ui.dart';

import '../../../domain/journal/entry_class.dart';
import '../../../domain/journal/vocab.dart';

/// 一级分类的标识色。
Color categoryColor(BuildContext context, EntryCategory? c) => switch (c) {
      EntryCategory.observe => const Color(0xFF1E88E5),
      EntryCategory.judge => const Color(0xFFF4511E),
      EntryCategory.plan => const Color(0xFF8E24AA),
      EntryCategory.review => const Color(0xFF00897B),
      EntryCategory.other || null => Theme.of(context).colorScheme.outline,
    };

/// 单选组：再次点击已选项可取消。
class ChoiceGroup extends StatelessWidget {
  const ChoiceGroup({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.color,
  });

  final List<Coded> options;
  final String? selected;
  final ValueChanged<String?> onChanged;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        for (final o in options)
          ChoiceChip(
            label: Text(o.label),
            selected: o.code == selected,
            selectedColor: color?.withValues(alpha: 0.22),
            showCheckmark: false,
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onSelected: (on) => onChanged(on ? o.code : null),
          ),
      ],
    );
  }
}

/// 快捷输入栏用的紧凑分类选择器：第一行一级分类，第二行展开二级与情绪（横向滚动）。
class CategoryPicker extends StatelessWidget {
  const CategoryPicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.showEmotion = true,
  });

  final EntryClass value;
  final ValueChanged<EntryClass> onChanged;
  final bool showEmotion;

  @override
  Widget build(BuildContext context) {
    final cat = value.categoryEnum;
    final groups = groupsFor(cat);
    final color = categoryColor(context, cat);
    Widget divider() => Container(
          width: 1,
          height: 20,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          color: Theme.of(context).dividerColor,
        );

    return Column(mainAxisSize: MainAxisSize.min, children: [
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(children: [
          for (final c in EntryCategory.values)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: ChoiceChip(
                key: Key('cat-${c.code}'),
                label: Text(c.label),
                selected: c == cat,
                showCheckmark: false,
                selectedColor: categoryColor(context, c).withValues(alpha: 0.25),
                side: BorderSide(color: categoryColor(context, c).withValues(alpha: 0.6)),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onSelected: (on) => onChanged(value.withCategory(on ? c : null)),
              ),
            ),
        ]),
      ),
      if (groups.isNotEmpty || showEmotion) ...[
        const SizedBox(height: 4),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(children: [
            for (final (i, g) in groups.indexed) ...[
              if (i > 0) divider(),
              ChoiceGroup(
                options: g.options,
                selected: value.get(g.field),
                color: color,
                onChanged: (v) => onChanged(value.withField(g.field, v)),
              ),
            ],
            if (showEmotion) ...[
              if (groups.isNotEmpty) divider(),
              ChoiceGroup(
                options: emotionGroup.options,
                selected: value.emotion,
                onChanged: (v) => onChanged(value.withField(TagField.emotion, v)),
              ),
            ],
          ]),
        ),
      ],
    ]);
  }
}

/// 编辑页用的分类表单：每组一行，带标签。
class CategoryForm extends StatelessWidget {
  const CategoryForm({super.key, required this.value, required this.onChanged});

  final EntryClass value;
  final ValueChanged<EntryClass> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cat = value.categoryEnum;
    final color = categoryColor(context, cat);
    Widget label(String text) => Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 4),
          child: Text(text, style: theme.textTheme.labelLarge),
        );
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      label('分类'),
      ChoiceGroup(
        options: EntryCategory.values,
        selected: value.category,
        onChanged: (v) => onChanged(value.withCategory(byCode(EntryCategory.values, v))),
      ),
      for (final g in groupsFor(cat)) ...[
        label(g.label),
        ChoiceGroup(
          options: g.options,
          selected: value.get(g.field),
          color: color,
          onChanged: (v) => onChanged(value.withField(g.field, v)),
        ),
      ],
      label(emotionGroup.label),
      ChoiceGroup(
        options: emotionGroup.options,
        selected: value.emotion,
        onChanged: (v) => onChanged(value.withField(TagField.emotion, v)),
      ),
    ]);
  }
}

/// 卡片上展示分类标签：分类徽标 + 方向 / 动作 / 周期 + 情绪。
class ClassTags extends StatelessWidget {
  const ClassTags({super.key, required this.value});

  final EntryClass value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cat = value.categoryEnum;
    final labels = value.labels();
    final emotion = labelFor(cat, TagField.emotion, value.emotion);
    if (labels.isEmpty && emotion == null) return const SizedBox.shrink();

    Color tone(int i) {
      if (i == 0) return categoryColor(context, cat);
      final stance = value.stance;
      final l = labels[i];
      if (l == labelFor(cat, TagField.stance, stance)) {
        return switch (stance) {
          'bull' => const Color(0xFFE53935),
          'bear' => const Color(0xFF2E7D32),
          _ => theme.colorScheme.outline,
        };
      }
      return theme.colorScheme.primary;
    }

    Widget chip(String text, Color color) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(text, style: theme.textTheme.labelSmall?.copyWith(color: color)),
        );

    return Wrap(spacing: 4, runSpacing: 2, children: [
      for (final (i, l) in labels.indexed) chip(l, tone(i)),
      if (emotion != null) chip(emotion, theme.colorScheme.tertiary),
    ]);
  }
}
