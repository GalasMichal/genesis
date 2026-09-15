import 'package:flutter/material.dart';

import 'chord_shape.dart';
import 'finger_colors.dart';
import 'fretboard_painter.dart';
import 'fretboard_view_mode.dart';

/// Interaktives Griffbrett: CustomPainter, zwei Ansichten, Links-/Rechtshänder,
/// animierte Griffwechsel.
class FretboardWidget extends StatefulWidget {
  const FretboardWidget({
    super.key,
    required this.chord,
    this.leftHanded = false,
    this.onLeftHandedChanged,
    this.viewMode = FretboardViewMode.chordDiagram,
    this.onViewModeChanged,
    this.showHandednessToggle = true,
    this.showViewToggle = true,
    this.height = 220,
    this.animationDuration = const Duration(milliseconds: 280),
  });

  final ChordShape chord;
  final bool leftHanded;
  final ValueChanged<bool>? onLeftHandedChanged;
  final FretboardViewMode viewMode;
  final ValueChanged<FretboardViewMode>? onViewModeChanged;
  final bool showHandednessToggle;
  final bool showViewToggle;
  final double height;
  final Duration animationDuration;

  @override
  State<FretboardWidget> createState() => FretboardWidgetState();
}

/// State öffentlich für Tests (aktueller Griff / Händigkeit / Ansicht).
class FretboardWidgetState extends State<FretboardWidget> {
  late ChordShape _displayedChord;
  late bool _leftHanded;
  late FretboardViewMode _viewMode;
  double _dotOpacity = 1;

  ChordShape get displayedChord => _displayedChord;
  bool get leftHanded => _leftHanded;
  FretboardViewMode get viewMode => _viewMode;

  @override
  void initState() {
    super.initState();
    _displayedChord = widget.chord;
    _leftHanded = widget.leftHanded;
    _viewMode = widget.viewMode;
  }

  @override
  void didUpdateWidget(covariant FretboardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.leftHanded != widget.leftHanded) {
      _leftHanded = widget.leftHanded;
    }
    if (oldWidget.viewMode != widget.viewMode) {
      _viewMode = widget.viewMode;
    }
    if (oldWidget.chord != widget.chord) {
      _animateTo(widget.chord);
    }
  }

  Future<void> _animateTo(ChordShape next) async {
    setState(() => _dotOpacity = 0);
    await Future<void>.delayed(widget.animationDuration);
    if (!mounted) return;
    setState(() {
      _displayedChord = next;
      _dotOpacity = 1;
    });
  }

  void _setLeftHanded(bool value) {
    if (_leftHanded == value) return;
    setState(() => _leftHanded = value);
    widget.onLeftHandedChanged?.call(value);
  }

  void _setViewMode(FretboardViewMode mode) {
    if (_viewMode == mode) return;
    setState(() => _viewMode = mode);
    widget.onViewModeChanged?.call(mode);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: AnimatedSwitcher(
                duration: widget.animationDuration,
                child: Text(
                  _displayedChord.name,
                  key: ValueKey(_displayedChord.id),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            if (widget.showHandednessToggle) ...[
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
                style: const ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.padded,
                ),
              ),
            ],
          ],
        ),
        if (widget.showViewToggle) ...[
          const SizedBox(height: 10),
          SegmentedButton<FretboardViewMode>(
            segments: const [
              ButtonSegment<FretboardViewMode>(
                value: FretboardViewMode.chordDiagram,
                label: Text('Diagramm'),
                icon: Icon(Icons.view_agenda_outlined, size: 18),
              ),
              ButtonSegment<FretboardViewMode>(
                value: FretboardViewMode.horizontal,
                label: Text('Griffbrett'),
                icon: Icon(Icons.horizontal_rule, size: 18),
              ),
            ],
            selected: {_viewMode},
            onSelectionChanged: (set) => _setViewMode(set.first),
            style: const ButtonStyle(
              visualDensity: VisualDensity.compact,
              tapTargetSize: MaterialTapTargetSize.padded,
            ),
          ),
        ],
        const SizedBox(height: 8),
        SizedBox(
          height: widget.height,
          width: double.infinity,
          child: AnimatedOpacity(
            opacity: _dotOpacity,
            duration: widget.animationDuration,
            curve: Curves.easeInOut,
            child: CustomPaint(
              painter: FretboardPainter(
                chord: _displayedChord,
                leftHanded: _leftHanded,
                viewMode: _viewMode,
                dotOpacity: 1,
              ),
              child: const SizedBox.expand(),
            ),
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
