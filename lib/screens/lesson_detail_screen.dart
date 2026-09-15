import 'package:flutter/material.dart';

import '../src/fretboard/fretboard_widget.dart';
import '../src/tutorial/lesson.dart';
import '../src/tutorial/lesson_progress.dart';

/// Detailansicht einer Lektion mit Text, optionalem Griffbrett und Abhaken.
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

  @override
  void initState() {
    super.initState();
    _completed = widget.initialCompleted;
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
              lesson.body,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.5,
                color: theme.colorScheme.onSurface,
              ),
            ),
            if (lesson.chord != null) ...[
              const SizedBox(height: 24),
              FretboardWidget(
                chord: lesson.chord!,
                leftHanded: _leftHanded,
                onLeftHandedChanged: (v) => setState(() => _leftHanded = v),
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
                icon: Icon(_completed ? Icons.check_circle : Icons.circle_outlined),
                label: Text(_completed ? 'Erledigt — zurücknehmen' : 'Lektion abhaken'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
