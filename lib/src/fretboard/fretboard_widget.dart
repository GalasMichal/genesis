import 'package:flutter/material.dart';

import 'chord_shape.dart';
import 'finger_colors.dart';
import 'fretboard_painter.dart';

/// Interaktives Griffbrett: CustomPainter, Links-/Rechtshänder, Griffwechsel-Animation.
class FretboardWidget extends StatefulWidget {
  const FretboardWidget({
    super.key,
    required this.chord,
    this.leftHanded = false,
    this.onLeftHandedChanged,
    this.showHandednessToggle = true,
    this.height = 200,
    this.animationDuration = const Duration(milliseconds: 280),
  });

  final ChordShape chord;
  final bool leftHanded;
  final ValueChanged<bool>? onLeftHandedChanged;
  final bool showHandednessToggle;
  final double height;
  final Duration animationDuration;

  @override
  State<FretboardWidget> createState() => FretboardWidgetState();
}

/// State öffentlich für Tests (aktueller Griff / Händigkeit).
class FretboardWidgetState extends State<FretboardWidget>
    with SingleTickerProviderStateMixin {
  late ChordShape _displayedChord;
  late bool _leftHanded;
  late final AnimationController _fade;
  late final Animation<double> _opacity;

  ChordShape get displayedChord => _displayedChord;
  bool get leftHanded => _leftHanded;

  @override
  void initState() {
    super.initState();
    _displayedChord = widget.chord;
    _leftHanded = widget.leftHanded;
    _fade = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
      value: 1,
    );
    _opacity = CurvedAnimation(parent: _fade, curve: Curves.easeInOut);
  }

  @override
  void didUpdateWidget(covariant FretboardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.leftHanded != widget.leftHanded) {
      _leftHanded = widget.leftHanded;
    }
    if (oldWidget.chord != widget.chord) {
      _animateTo(widget.chord);
    }
    if (oldWidget.animationDuration != widget.animationDuration) {
      _fade.duration = widget.animationDuration;
    }
  }

  Future<void> _animateTo(ChordShape next) async {
    await _fade.reverse();
    if (!mounted) return;
    setState(() => _displayedChord = next);
    await _fade.forward();
  }

  void _setLeftHanded(bool value) {
    if (_leftHanded == value) return;
    setState(() => _leftHanded = value);
    widget.onLeftHandedChanged?.call(value);
  }

  @override
  void dispose() {
    _fade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.showHandednessToggle) ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  _displayedChord.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment<bool>(
                    value: false,
                    label: Text('Rechts'),
                    icon: Icon(Icons.back_hand_outlined, size: 18),
                  ),
                  ButtonSegment<bool>(
                    value: true,
                    label: Text('Links'),
                    icon: Icon(Icons.front_hand_outlined, size: 18),
                  ),
                ],
                selected: {_leftHanded},
                onSelectionChanged: (set) => _setLeftHanded(set.first),
                style: ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.padded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        SizedBox(
          height: widget.height,
          width: double.infinity,
          child: AnimatedBuilder(
            animation: _opacity,
            builder: (context, _) {
              return CustomPaint(
                painter: FretboardPainter(
                  chord: _displayedChord,
                  leftHanded: _leftHanded,
                  dotOpacity: _opacity.value,
                ),
                child: const SizedBox.expand(),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        _FingerLegend(theme: theme),
      ],
    );
  }
}

class _FingerLegend extends StatelessWidget {
  const _FingerLegend({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 6,
      children: [
        for (var f = 1; f <= 4; f++)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 18,
                height: 18,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: FingerColors.forFinger(f),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$f',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                FingerColors.labelForFinger(f),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
