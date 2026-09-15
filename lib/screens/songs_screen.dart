import 'package:flutter/material.dart';

import '../src/songs/song.dart';
import '../src/songs/song_category.dart';
import '../src/songs/song_library.dart';
import 'song_detail_screen.dart';

/// Songbibliothek mit Kategorie-Filter und Schwierigkeitsanzeige.
class SongsScreen extends StatefulWidget {
  const SongsScreen({super.key});

  @override
  State<SongsScreen> createState() => _SongsScreenState();
}

class _SongsScreenState extends State<SongsScreen> {
  SongCategory? _filter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final songs = SongLibrary.byCategory(_filter);

    return Scaffold(
      appBar: AppBar(title: const Text('Songs')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          children: [
            Text(
              'Bibliothek',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Eigene Übungen & Pop/Rock-Originale plus geprüfte Traditionals '
              '(englisch, polnisch, Klassik) — keine geschützten Songs oder Songtexte.',
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.45,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            _CategoryChips(
              selected: _filter,
              onSelected: (c) => setState(() => _filter = c),
            ),
            const SizedBox(height: 16),
            Text(
              '${songs.length} ${songs.length == 1 ? 'Song' : 'Songs'}',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            if (songs.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  _filter == null
                      ? 'Die Songbibliothek ist noch leer. Bald kommen '
                          'Übungsstücke und Traditionals dazu.'
                      : 'In „${_filter!.shortLabel}“ sind gerade keine Songs. '
                          'Wähle eine andere Kategorie oder „Alle“.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.45,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            else
              for (final song in songs) ...[
                _SongTile(
                  song: song,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => SongDetailScreen(song: song),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
              ],
          ],
        ),
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({
    required this.selected,
    required this.onSelected,
  });

  final SongCategory? selected;
  final ValueChanged<SongCategory?> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chips = <(SongCategory?, String)>[
      (null, 'Alle'),
      for (final c in SongCategory.values) (c, c.shortLabel),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final (cat, label) in chips) ...[
            FilterChip(
              label: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(label),
              ),
              selected: selected == cat,
              onSelected: (_) => onSelected(cat),
              showCheckmark: false,
              selectedColor: theme.colorScheme.secondaryContainer,
              side: BorderSide(
                color: selected == cat
                    ? theme.colorScheme.secondary
                    : theme.colorScheme.outlineVariant,
              ),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _SongTile extends StatelessWidget {
  const _SongTile({required this.song, required this.onTap});

  final Song song;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Material(
      color: cs.surfaceContainerHighest.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 72),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${song.category.shortLabel} · ${song.bpm} BPM · '
                        '${song.source.label}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DifficultyMeter(difficulty: song.difficulty),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Sterne/Balken 1–5 für Schwierigkeit.
class DifficultyMeter extends StatelessWidget {
  const DifficultyMeter({
    super.key,
    required this.difficulty,
    this.max = 5,
  });

  final int difficulty;
  final int max;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= max; i++) ...[
          Container(
            width: 18,
            height: 6,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              color: i <= difficulty
                  ? cs.tertiary
                  : cs.outlineVariant.withValues(alpha: 0.4),
            ),
          ),
          if (i < max) const SizedBox(width: 3),
        ],
        const SizedBox(width: 8),
        Text(
          '$difficulty/$max',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}
