import 'package:flutter/material.dart';

import '../src/tuner/guitar_tuning.dart';

/// Anzeige der sechs offenen Saiten mit Ziel-Frequenz.
class StringStrip extends StatelessWidget {
  const StringStrip({
    super.key,
    required this.entries,
    this.activeIndex,
    this.inTune = false,
  });

  final List<({GuitarString string, double frequencyHz})> entries;
  final int? activeIndex;
  final bool inTune;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        for (final entry in entries)
          Expanded(
            child: _StringCell(
              label: entry.string.noteName,
              detail: entry.string.label,
              hz: entry.frequencyHz,
              selected: activeIndex == entry.string.index,
              inTune: inTune && activeIndex == entry.string.index,
              theme: theme,
            ),
          ),
      ],
    );
  }
}

class _StringCell extends StatelessWidget {
  const _StringCell({
    required this.label,
    required this.detail,
    required this.hz,
    required this.selected,
    required this.inTune,
    required this.theme,
  });

  final String label;
  final String detail;
  final double hz;
  final bool selected;
  final bool inTune;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    if (inTune) {
      bg = const Color(0xFF3DDC97).withValues(alpha: 0.2);
      fg = const Color(0xFF3DDC97);
    } else if (selected) {
      bg = theme.colorScheme.secondaryContainer;
      fg = theme.colorScheme.onSecondaryContainer;
    } else {
      bg = theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.55);
      fg = theme.colorScheme.onSurfaceVariant;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? fg.withValues(alpha: 0.55)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: fg,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              detail,
              style: theme.textTheme.labelSmall?.copyWith(color: fg),
            ),
            const SizedBox(height: 4),
            Text(
              hz.toStringAsFixed(1),
              style: theme.textTheme.labelSmall?.copyWith(
                color: fg.withValues(alpha: 0.85),
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
