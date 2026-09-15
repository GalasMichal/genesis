import 'dart:async';

import 'package:flutter/material.dart';

import '../src/fretboard/fretboard_widget.dart';
import '../src/strumming/technique_display.dart';
import '../src/tutorial/lesson.dart';
import '../src/tutorial/lesson_progress.dart';

/// Detailansicht einer Lektion mit Schritten, optionalem Griffbrett und Abhaken.
class LessonDetailScreen extends StatefulWidget {
  const LessonDetailScreen({
    super.key,
    required this.lesson,
    required this.progress,
    this.onOpenTuner,
    this.initialCompleted = false,
  });

  final Lesson lesson;
  final LessonProgressStore progress;
  final VoidCallback? onOpenTuner;
  final bool initialCompleted;

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  late bool _completed;
  bool _leftHanded = false;
  bool _saving = false;
  bool _patternPlaying = false;
  double _patternBeat = 0;
  Timer? _patternTicker;
  static const _patternBpm = 72.0;

  @override
  void initState() {
    super.initState();
    _completed = widget.initialCompleted;
  }

  @override
  void dispose() {
    _patternTicker?.cancel();
    super.dispose();
  }

  Future<void> _toggleCompleted() async {
    if (_saving) return;
    setState(() => _saving = true);
    final next = !_completed;
    await widget.progress.setCompleted(widget.lesson.id, completed: next);
    if (!mounted) return;
    setState(() {
      _completed = next;
      _saving = false;
    });
  }

  void _togglePatternPlay() {
    if (_patternPlaying) {
      _patternTicker?.cancel();
      _patternTicker = null;
      setState(() => _patternPlaying = false);
      return;
    }
    setState(() => _patternPlaying = true);
    var last = DateTime.now();
    _patternTicker = Timer.periodic(const Duration(milliseconds: 32), (_) {
      final now = DateTime.now();
      final dt = now.difference(last).inMicroseconds / 1e6;
      last = now;
      if (!mounted) return;
      setState(() {
        _patternBeat += dt * (_patternBpm / 60.0);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lesson = widget.lesson;

    return Scaffold(
      appBar: AppBar(title: Text(lesson.title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          children: [
            Text(
              lesson.summary,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.5,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Schritte',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            for (var i = 0; i < lesson.steps.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              _StepRow(index: i + 1, text: lesson.steps[i]),
            ],
            if (lesson.chord != null) ...[
              const SizedBox(height: 28),
              Text(
                'Griffbild',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              FretboardWidget(
                chord: lesson.chord!,
                leftHanded: _leftHanded,
                onLeftHandedChanged: (v) => setState(() => _leftHanded = v),
              ),
            ],
            if (lesson.techniquePatternId != null) ...[
              const SizedBox(height: 28),
              Text(
                'Muster zum Mitüben',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              TechniqueDisplay(
                patternId: lesson.techniquePatternId!,
                beat: _patternBeat,
              ),
              const SizedBox(height: 12),
              FilledButton.tonalIcon(
                onPressed: _togglePatternPlay,
                icon: Icon(
                  _patternPlaying ? Icons.pause : Icons.play_arrow,
                ),
                label: Text(
                  _patternPlaying
                      ? 'Pause (${_patternBpm.round()} BPM)'
                      : 'Muster starten (${_patternBpm.round()} BPM)',
                ),
              ),
            ],
            if (lesson.practiceHint != null) ...[
              const SizedBox(height: 24),
              Text(
                'Übung',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                lesson.practiceHint!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.45,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (lesson.opensTuner && widget.onOpenTuner != null) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.tonalIcon(
                  onPressed: widget.onOpenTuner,
                  icon: const Icon(Icons.tune),
                  label: const Text('Zum Tuner'),
                ),
              ),
            ],
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: _saving ? null : _toggleCompleted,
                icon: Icon(
                  _completed ? Icons.check_circle : Icons.circle_outlined,
                ),
                label: Text(
                  _completed ? 'Erledigt — zurücknehmen' : 'Lektion abhaken',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.index, required this.text});

  final int index;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: theme.colorScheme.primaryContainer,
          foregroundColor: theme.colorScheme.onPrimaryContainer,
          child: Text(
            '$index',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.45),
          ),
        ),
      ],
    );
  }
}
