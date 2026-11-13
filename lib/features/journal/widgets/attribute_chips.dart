import 'package:material_ui/material_ui.dart';

import '../../../domain/journal/vocab.dart';

/// 单选要素组：再次点击已选项可取消。
class ChoiceGroup<T extends Coded> extends StatelessWidget {
  const ChoiceGroup({
    super.key,
    required this.values,
    required this.selected,
    required this.onChanged,
  });

  final List<T> values;
  final T? selected;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      children: [
        for (final v in values)
          ChoiceChip(
            label: Text(v.label),
            selected: v == selected,
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onSelected: (on) => onChanged(on ? v : null),
          ),
      ],
    );
  }
}

/// 观点 / 动作 / 情绪三组要素的选择状态。
@immutable
class EntryAttributes {
  const EntryAttributes({this.stance, this.action, this.emotion});

  final Stance? stance;
  final TradeAction? action;
  final Emotion? emotion;

  static const empty = EntryAttributes();

  bool get isEmpty => stance == null && action == null && emotion == null;

  EntryAttributes withStance(Stance? v) =>
      EntryAttributes(stance: v, action: action, emotion: emotion);
  EntryAttributes withAction(TradeAction? v) =>
      EntryAttributes(stance: stance, action: v, emotion: emotion);
  EntryAttributes withEmotion(Emotion? v) =>
      EntryAttributes(stance: stance, action: action, emotion: v);
}

/// 一行横向滚动的三组要素（快捷输入栏用）。
class AttributeBar extends StatelessWidget {
  const AttributeBar({super.key, required this.value, required this.onChanged});

  final EntryAttributes value;
  final ValueChanged<EntryAttributes> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget divider() => Container(
          width: 1,
          height: 20,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          color: Theme.of(context).dividerColor,
        );
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(children: [
        ChoiceGroup(
            values: Stance.values,
            selected: value.stance,
            onChanged: (v) => onChanged(value.withStance(v))),
        divider(),
        ChoiceGroup(
            values: TradeAction.values,
            selected: value.action,
            onChanged: (v) => onChanged(value.withAction(v))),
        divider(),
        ChoiceGroup(
            values: Emotion.values,
            selected: value.emotion,
            onChanged: (v) => onChanged(value.withEmotion(v))),
      ]),
    );
  }
}

/// 卡片上展示已选要素的小标签。
class AttributeTags extends StatelessWidget {
  const AttributeTags({super.key, this.stance, this.action, this.emotion});

  final String? stance;
  final String? action;
  final String? emotion;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final items = <(String, Color)>[
      if (byCode(Stance.values, stance) case final s?)
        (s.label, switch (s) {
          Stance.bull => const Color(0xFFE53935),
          Stance.bear => const Color(0xFF2E7D32),
          Stance.wait => scheme.outline,
        }),
      if (byCode(TradeAction.values, action) case final a?) (a.label, scheme.primary),
      if (byCode(Emotion.values, emotion) case final e?) (e.label, scheme.tertiary),
    ];
    if (items.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 4,
      children: [
        for (final (label, color) in items)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color)),
          ),
      ],
    );
  }
}
