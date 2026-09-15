import 'dart:async';

import 'package:flutter/material.dart';

import '../src/strumming/pattern_catalog.dart';
import '../src/strumming/technique_display.dart';
import '../src/strumming/technique_pattern.dart';

/// Visuell geführte Schlag-/Zupfmuster-Übung ohne Mikrofon-Wertung.
class StrummingPracticeScreen extends StatefulWidget {
  const StrummingPracticeScreen({
    super.key,
    this.initialPatternId,
    this.initialBpm = 80,
  });

  final String? initialPatternId;
  final double initialBpm;

  @override
  State<StrummingPracticeScreen> createState() =>
      _StrummingPracticeScreenState();
}

class _StrummingPracticeScreenState extends State<StrummingPracticeScreen> {
  late String _patternId;
  late double _bpm;
  double _tempoPercent = 100;
  bool _playing = false;
  double _beat = 0;
  Timer? _ticker;
  DateTime? _lastTick;

  @override
  void initState() {
    super.initState();
    _patternId = widget.initialPatternId ?? PatternCatalog.grundschlag44.id;
    _bpm = widget.initialBpm;
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  double get _effectiveBpm => _bpm * (_tempoPercent / 100.0);

  void _togglePlay() {
    if (_playing) {
      _ticker?.cancel();
      _ticker = null;
      _lastTick = null;
      setState(() => _playing = false);
      return;
    }
    setState(() => _playing = true);
    _lastTick = null;
    _ticker = Timer.periodic(const Duration(milliseconds: 32), (_) {
      final now = DateTime.now();
      if (_lastTick == null) {
        _lastTick = now;
        return;
      }
      final dt = now.difference(_lastTick!).inMicroseconds / 1e6;
      _lastTick = now;
      if (!mounted || !_playing) return;
      setState(() {
        _beat += dt * (_effectiveBpm / 60.0);
      });
    });
  }

  void _stop() {
    _ticker?.cancel();
    _ticker = null;
    _lastTick = null;
    setState(() {
      _playing = false;
      _beat = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final patterns = PatternCatalog.all;

    return Scaffold(
      appBar: AppBar(title: const Text('Schlagmuster üben')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          children: [
            Text(
              'Spiele das Muster im Tempo mit — die Anzeige führt dich '
              'visuell. Keine Mic-Wertung, nur Rhythmus-Training.',
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.45,
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Muster',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final p in patterns)
                  ChoiceChip(
                    label: Text(p.title),
                    selected: _patternId == p.id,
                    onSelected: (_) {
                      setState(() {
                        _patternId = p.id;
                        _beat = 0;
                      });
                    },
                  ),
              ],
            ),
            const SizedBox(height: 24),
            TechniqueDisplay(
              patternId: _patternId,
              beat: _beat,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                FilledButton.tonalIcon(
                  onPressed: _togglePlay,
                  icon: Icon(_playing ? Icons.pause : Icons.play_arrow),
                  label: Text(_playing ? 'Pause' : 'Play'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: _stop,
                  child: const Text('Stop'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Tempo ${_tempoPercent.round()} % '
              '(${_effectiveBpm.round()} BPM)',
              style: theme.textTheme.titleSmall,
            ),
            Slider(
              value: _tempoPercent,
              min: 50,
              max: 100,
              divisions: 10,
              label: '${_tempoPercent.round()} %',
              onChanged: (v) => setState(() => _tempoPercent = v),
            ),
            const SizedBox(height: 8),
            Text(
              'Basis-Tempo ${_bpm.round()} BPM',
              style: theme.textTheme.titleSmall,
            ),
            Slider(
              value: _bpm,
              min: 60,
              max: 120,
              divisions: 12,
              label: '${_bpm.round()}',
              onChanged: (v) => setState(() => _bpm = v),
            ),
            const SizedBox(height: 12),
            Text(
              _kindHint(PatternCatalog.byId(_patternId)),
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _kindHint(TechniquePattern? t) {
    if (t is StrumTechnique) {
      return 'Schlagmuster — folge den Pfeilen ↓/↑ im Takt.';
    }
    if (t is PickTechnique) {
      return 'Zupfmuster — welcher Finger welche Saite zupft, siehst du unten.';
    }
    return '';
  }
}
