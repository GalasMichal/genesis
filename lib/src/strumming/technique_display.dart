import 'package:flutter/material.dart';

import 'fingerpicking_pattern.dart';
import 'pattern_catalog.dart';
import 'picking_finger.dart';
import 'stroke_type.dart';
import 'strumming_pattern.dart';
import 'technique_pattern.dart';

/// Berechnet den aktuellen Achtel-Index aus der Beat-Position.
///
/// Beat 0.0 → Index 0, Beat 0.5 → Index 1, … modulo [eighthCount].
int eighthIndexAtBeat(double beat, int eighthCount) {
  if (eighthCount <= 0) return 0;
  final eighths = beat * 2;
  final idx = eighths.floor() % eighthCount;
  return idx < 0 ? 0 : idx;
}

/// Animierte Anzeige eines Schlag- oder Zupfmusters, synchron zur Beat-Timeline.
class TechniqueDisplay extends StatelessWidget {
  const TechniqueDisplay({
    super.key,
    required this.patternId,
    required this.beat,
    this.compact = false,
  });

  final String patternId;

  /// Absolute Beat-Position (wie PlayAlongController.beat).
  final double beat;

  /// Kompaktere Darstellung (z. B. in Übungen).
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final technique = PatternCatalog.byId(patternId);
    if (technique == null) {
      return Text(
        'Unbekanntes Muster: $patternId',
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }

    final idx = eighthIndexAtBeat(beat, technique.eighthCount);

    return switch (technique) {
      StrumTechnique(:final pattern) => StrummingTimeline(
          pattern: pattern,
          activeIndex: idx,
          compact: compact,
        ),
      PickTechnique(:final pattern) => FingerpickingTimeline(
          pattern: pattern,
          activeIndex: idx,
          compact: compact,
        ),
    };
  }
}

/// Horizontale Timeline der Schlagrichtungen (↓/↑/–/×).
class StrummingTimeline extends StatelessWidget {
  const StrummingTimeline({
    super.key,
    required this.pattern,
    required this.activeIndex,
    this.compact = false,
  });

  final StrummingPattern pattern;
  final int activeIndex;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final slotSize = compact ? 40.0 : 48.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          pattern.title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        if (!compact) ...[
          const SizedBox(height: 4),
          Text(
            pattern.summary,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.35,
            ),
          ),
        ],
        const SizedBox(height: 12),
        SizedBox(
          height: slotSize + 8,
          child: Row(
            children: [
              for (var i = 0; i < pattern.eighths.length; i++) ...[
                if (i > 0) SizedBox(width: compact ? 4 : 6),
                Expanded(
                  child: _StrokeSlot(
                    type: pattern.eighths[i],
                    active: i == activeIndex,
                    size: slotSize,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${pattern.beatsPerBar}/4 · Achtel ${activeIndex + 1}/${pattern.eighthCount}',
          style: theme.textTheme.labelSmall?.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _StrokeSlot extends StatelessWidget {
  const _StrokeSlot({
    required this.type,
    required this.active,
    required this.size,
  });

  final StrokeType type;
  final bool active;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isRest = type == StrokeType.rest;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: active
            ? cs.primaryContainer
            : cs.surfaceContainerHighest.withValues(alpha: 0.45),
        border: Border.all(
          color: active ? cs.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: Text(
        type.symbol,
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: isRest
              ? cs.onSurfaceVariant.withValues(alpha: active ? 0.9 : 0.45)
              : active
                  ? cs.onPrimaryContainer
                  : cs.onSurface,
          fontSize: size * 0.45,
        ),
      ),
    );
  }
}

/// Timeline: welcher Finger welche Saite zupft.
class FingerpickingTimeline extends StatelessWidget {
  const FingerpickingTimeline({
    super.key,
    required this.pattern,
    required this.activeIndex,
    this.compact = false,
  });

  final FingerpickingPattern pattern;
  final int activeIndex;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final current = (activeIndex >= 0 && activeIndex < pattern.steps.length)
        ? pattern.steps[activeIndex]
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          pattern.title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        if (!compact) ...[
          const SizedBox(height: 4),
          Text(
            pattern.summary,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.35,
            ),
          ),
        ],
        const SizedBox(height: 12),
        SizedBox(
          height: compact ? 52 : 60,
          child: Row(
            children: [
              for (var i = 0; i < pattern.steps.length; i++) ...[
                if (i > 0) const SizedBox(width: 4),
                Expanded(
                  child: _PickSlot(
                    step: pattern.steps[i],
                    active: i == activeIndex,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        _FingerStringHint(step: current),
      ],
    );
  }
}

class _PickSlot extends StatelessWidget {
  const _PickSlot({required this.step, required this.active});

  final PickingStep? step;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final label = step == null ? '–' : step!.finger.symbol;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: active
            ? cs.primaryContainer
            : cs.surfaceContainerHighest.withValues(alpha: 0.45),
        border: Border.all(
          color: active ? cs.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: active ? cs.onPrimaryContainer : cs.onSurface,
            ),
          ),
          if (step != null)
            Text(
              'S${step!.stringNumber}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: active
                    ? cs.onPrimaryContainer.withValues(alpha: 0.85)
                    : cs.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}

class _FingerStringHint extends StatelessWidget {
  const _FingerStringHint({required this.step});

  final PickingStep? step;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final text = step == null
        ? 'Pause — Hand entspannt lassen'
        : '${step!.finger.labelDe} zupft Saite ${step!.stringNumber} '
            '(${_stringName(step!.stringNumber)})';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: cs.surfaceContainerHighest.withValues(alpha: 0.55),
      ),
      child: Text(
        text,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static String _stringName(int n) => switch (n) {
        1 => 'hohe e',
        2 => 'h',
        3 => 'g',
        4 => 'd',
        5 => 'a',
        6 => 'tiefe E',
        _ => '?',
      };
}
