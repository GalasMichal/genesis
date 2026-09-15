import 'package:flutter/material.dart';

import '../src/practice/practice_progress.dart';
import '../src/practice/practice_set.dart';
import '../src/practice/practice_sets.dart';
import 'practice_session_screen.dart';

/// Übersicht der Übungs-Sets mit lokalem Fortschritt.
class UebenScreen extends StatefulWidget {
  const UebenScreen({
    super.key,
    this.progress,
  });

  /// Optional injizierter Store (Tests).
  final PracticeProgressStore? progress;

  @override
  State<UebenScreen> createState() => _UebenScreenState();
}

class _UebenScreenState extends State<UebenScreen> {
  late final PracticeProgressStore _progress;
  Set<String> _completed = {};
  Map<String, int> _best = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _progress = widget.progress ?? PracticeProgressStore();
    _reload();
  }

  Future<void> _reload() async {
    final ids = BeginnerPracticeSets.all.map((s) => s.id).toList();
    final done = await _progress.completedIds(ids);
    final best = <String, int>{};
    for (final id in ids) {
      best[id] = await _progress.bestStep(id);
    }
    if (!mounted) return;
    setState(() {
      _completed = done;
      _best = best;
      _loading = false;
    });
  }

  Future<void> _openSet(PracticeSet set) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PracticeSessionScreen(
          practiceSet: set,
          progress: _progress,
        ),
      ),
    );
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sets = BeginnerPracticeSets.all;
    final fraction = sets.isEmpty ? 0.0 : _completed.length / sets.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Üben')),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                children: [
                  Text(
                    'Mic-Check',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ziel auf dem Griffbrett, Mikrofon prüft mit. '
                    'Grün nur bei ehrlichem Treffer — kein Durchwinken.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.45,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Fortschritt · ${_completed.length} / ${sets.length} Sets',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: fraction,
                      minHeight: 10,
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (sets.isEmpty)
                    Text(
                      'Noch keine Übungs-Sets verfügbar. Schau später wieder vorbei.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.4,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    )
                  else
                    for (var i = 0; i < sets.length; i++) ...[
                      if (i > 0) const SizedBox(height: 10),
                      _PracticeSetTile(
                        set: sets[i],
                        completed: _completed.contains(sets[i].id),
                        bestStep: _best[sets[i].id] ?? 0,
                        onTap: () => _openSet(sets[i]),
                      ),
                    ],
                ],
              ),
      ),
    );
  }
}

class _PracticeSetTile extends StatelessWidget {
  const _PracticeSetTile({
    required this.set,
    required this.completed,
    required this.bestStep,
    required this.onTap,
  });

  final PracticeSet set;
  final bool completed;
  final int bestStep;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stepLabel = completed
        ? 'Geschafft'
        : bestStep > 0
            ? 'Bestes: $bestStep / ${set.stepCount}'
            : '${set.stepCount} Schritte';

    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 72),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(
                    completed ? Icons.check_circle : Icons.play_circle_outline,
                    size: 28,
                    color: completed
                        ? const Color(0xFF3DDC97)
                        : theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        set.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        set.summary,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.35,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        stepLabel,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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
