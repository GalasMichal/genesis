import 'package:flutter/material.dart';

import '../src/chords/beginner_chords.dart';
import '../src/fretboard/fretboard_widget.dart';
import '../src/tutorial/lesson_progress.dart';
import '../src/tutorial/lessons.dart';
import 'lesson_detail_screen.dart';

/// Tutorial-Pfad: Lektionsliste, Fortschrittsbalken, Griffbrett-Vorschau.
class LernenScreen extends StatefulWidget {
  const LernenScreen({
    super.key,
    this.progress,
    this.onOpenTuner,
  });

  final LessonProgressStore? progress;
  final VoidCallback? onOpenTuner;

  @override
  State<LernenScreen> createState() => _LernenScreenState();
}

class _LernenScreenState extends State<LernenScreen> {
  late final LessonProgressStore _progress;
  Set<String> _done = {};
  bool _loading = true;
  bool _leftHanded = false;
  int _previewIndex = 0;

  static final _previewChords = [
    BeginnerChords.em,
    BeginnerChords.am,
    BeginnerChords.c,
    BeginnerChords.g,
    BeginnerChords.d,
  ];

  @override
  void initState() {
    super.initState();
    _progress = widget.progress ?? LessonProgressStore();
    _reload();
  }

  Future<void> _reload() async {
    final ids = BeginnerLessons.all.map((l) => l.id);
    final done = await _progress.completedIds(ids);
    if (!mounted) return;
    setState(() {
      _done = done;
      _loading = false;
    });
  }

  Future<void> _openLesson(int index) async {
    final lesson = BeginnerLessons.all[index];
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => LessonDetailScreen(
          lesson: lesson,
          progress: _progress,
          initialCompleted: _done.contains(lesson.id),
          onOpenTuner: widget.onOpenTuner == null
              ? null
              : () {
                  Navigator.of(context).pop();
                  widget.onOpenTuner!();
                },
        ),
      ),
    );
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = BeginnerLessons.all.length;
    final completed = _done.length;
    final fraction = total == 0 ? 0.0 : completed / total;

    return Scaffold(
      appBar: AppBar(title: const Text('Lernen')),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                children: [
                  Text(
                    'Anfänger-Pfad',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Von Haltung und Stimmen bis zu den ersten Akkorden und '
                    'einem einfachen Schlagmuster — Schritt für Schritt.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.45,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '$completed von $total Lektionen',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '${(fraction * 100).round()} %',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: fraction,
                      minHeight: 10,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Griffbrett',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Fingerfarben und Links-/Rechtshänder — zum Ausprobieren.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FretboardWidget(
                    chord: _previewChords[_previewIndex],
                    leftHanded: _leftHanded,
                    onLeftHandedChanged: (v) => setState(() => _leftHanded = v),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (var i = 0; i < _previewChords.length; i++)
                        ChoiceChip(
                          label: Text(_previewChords[i].name),
                          selected: i == _previewIndex,
                          onSelected: (_) => setState(() => _previewIndex = i),
                        ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Lektionen',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (var i = 0; i < BeginnerLessons.all.length; i++) ...[
                    if (i > 0) const SizedBox(height: 8),
                    _LessonTile(
                      index: i + 1,
                      title: BeginnerLessons.all[i].title,
                      completed: _done.contains(BeginnerLessons.all[i].id),
                      onTap: () => _openLesson(i),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}

class _LessonTile extends StatelessWidget {
  const _LessonTile({
    required this.index,
    required this.title,
    required this.completed,
    required this.onTap,
  });

  final int index;
  final String title;
  final bool completed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 64),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: completed
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surfaceContainerHigh,
                  foregroundColor: completed
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface,
                  child: completed
                      ? const Icon(Icons.check, size: 20)
                      : Text(
                          '$index',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
