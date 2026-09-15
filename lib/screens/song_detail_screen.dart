import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../src/audio/audio_capture.dart';
import '../src/audio/audio_capture_factory.dart';
import '../src/chords/beginner_chords.dart';
import '../src/fretboard/chord_shape.dart';
import '../src/fretboard/fretboard_painter.dart';
import '../src/fretboard/fretboard_view_mode.dart';
import '../src/fretboard/fretboard_widget.dart';
import '../src/pitch/note_mapper.dart';
import '../src/practice/practice_checker.dart';
import '../src/practice/practice_target.dart';
import '../src/songs/play_along_controller.dart';
import '../src/songs/song.dart';
import '../src/songs/song_category.dart';
import '../src/songs/song_library.dart';
import '../src/songs/song_progress.dart';
import '../src/tuner/pitch_pipeline.dart';
import 'songs_screen.dart';

/// Song-Detail mit Griffbrett und Play-Along (Tempo, Loop, optional Mic).
class SongDetailScreen extends StatefulWidget {
  const SongDetailScreen({
    super.key,
    required this.song,
    this.capture,
    this.readingStream,
    this.songProgress,
  });

  final Song song;

  /// Optional injizierte Capture-Quelle (Tests / Mic-Play-Along).
  final AudioCaptureSource? capture;

  /// Optional fertiger Reading-Stream (Widget-Tests ohne Mic).
  final Stream<TunerReading>? readingStream;

  /// Optional injizierter Song-Fortschritt (Tests).
  final SongProgressStore? songProgress;

  @override
  State<SongDetailScreen> createState() => _SongDetailScreenState();
}

class _SongDetailScreenState extends State<SongDetailScreen> {
  late final PlayAlongController _controller;
  late final SongProgressStore _songProgress;
  final ScrollController _chordScroll = ScrollController();
  Timer? _ticker;

  // Optional Mic-Play-Along
  bool _micEnabled = false;
  bool _micStarting = false;
  bool _listening = false;
  String? _micMessage;
  PracticeCheckResult _micResult = PracticeCheckResult.listening;
  late final PracticeChecker _checker;
  AudioCaptureSource? _ownedCapture;
  PitchPipeline? _pipeline;
  StreamSubscription<TunerReading>? _micSub;
  String? _lastCheckedChordId;

  Song get song => widget.song;

  @override
  void initState() {
    super.initState();
    _controller = PlayAlongController(song);
    _controller.addListener(_onController);
    _songProgress = widget.songProgress ?? SongProgressStore();
    _checker = PracticeChecker(mapper: NoteMapper());
    _syncCheckerTarget();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _controller.removeListener(_onController);
    _controller.dispose();
    _chordScroll.dispose();
    _stopMic();
    super.dispose();
  }

  void _onController() {
    if (!mounted) return;
    setState(() {});
    _scrollToCurrentChord();
    _syncCheckerTarget();
  }

  void _syncCheckerTarget() {
    final id = _controller.currentChordId;
    if (id == null || id == _lastCheckedChordId) return;
    _lastCheckedChordId = id;
    final shape = BeginnerChords.byId(id);
    if (shape == null) return;
    _checker.setTarget(PracticeTargets.forChord(shape));
    _micResult = PracticeCheckResult.listening;
  }

  void _scrollToCurrentChord() {
    final idx = _controller.currentEventIndex;
    if (idx < 0 || !_chordScroll.hasClients) return;
    const itemWidth = 72.0;
    final target = (idx * itemWidth) - 40;
    _chordScroll.animateTo(
      target.clamp(0.0, _chordScroll.position.maxScrollExtent),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  void _ensureTicker() {
    _ticker ??= Timer.periodic(const Duration(milliseconds: 32), (_) {
      if (_controller.isPlaying) {
        _controller.tickNow();
      }
    });
  }

  void _togglePlay() {
    if (_controller.isPlaying) {
      _controller.pause();
    } else {
      _ensureTicker();
      _controller.play();
      unawaited(_songProgress.markPlayed(song.id));
    }
  }

  Future<void> _toggleMic(bool enabled) async {
    if (!enabled) {
      await _stopMic();
      setState(() {
        _micEnabled = false;
        _micMessage = null;
        _micResult = PracticeCheckResult.listening;
      });
      return;
    }

    setState(() {
      _micEnabled = true;
      _micStarting = true;
      _micMessage = null;
    });

    if (widget.readingStream != null) {
      await _micSub?.cancel();
      _micSub = widget.readingStream!.listen(_onReading);
      setState(() {
        _micStarting = false;
        _listening = true;
      });
      return;
    }

    final capture = widget.capture ?? createAudioCapture();
    if (widget.capture == null) _ownedCapture = capture;

    if (!capture.isSupported) {
      setState(() {
        _micStarting = false;
        _listening = false;
        _micMessage = capture.unsupportedMessage;
      });
      return;
    }

    final granted = await capture.ensurePermission();
    if (!mounted) return;
    if (!granted) {
      final permanently =
          !kIsWeb && await Permission.microphone.isPermanentlyDenied;
      setState(() {
        _micStarting = false;
        _listening = false;
        _micMessage = permanently
            ? 'Mikrofon dauerhaft verweigert — bitte in den Einstellungen erlauben.'
            : kIsWeb
                ? 'Mikrofon-Zugriff wurde blockiert. Bitte in den '
                    'Browser-Einstellungen für diese Seite erlauben und '
                    'erneut versuchen.'
                : 'Ohne Mikrofon keine Live-Prüfung. Bitte Zugriff erlauben.';
      });
      return;
    }

    final pipeline = PitchPipeline(
      capture: capture,
      noteMapper: NoteMapper(),
    );
    _pipeline = pipeline;
    await _micSub?.cancel();
    _micSub = pipeline.readings.listen(_onReading);
    await pipeline.start();

    if (!mounted) return;
    setState(() {
      _micStarting = false;
      _listening = true;
      _micMessage = null;
    });
  }

  void _onReading(TunerReading reading) {
    if (!_micEnabled) return;
    final result = _checker.process(reading);
    if (!mounted) return;
    setState(() => _micResult = result);
  }

  Future<void> _stopMic() async {
    await _micSub?.cancel();
    _micSub = null;
    _pipeline?.dispose();
    _pipeline = null;
    _ownedCapture?.dispose();
    _ownedCapture = null;
    _listening = false;
  }

  ChordShape get _currentChord {
    final id = _controller.currentChordId ?? song.events.first.chordId;
    return BeginnerChords.byId(id) ?? BeginnerChords.em;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final idx = _controller.currentEventIndex.clamp(0, song.events.length - 1);

    return Scaffold(
      appBar: AppBar(
        title: Text(song.title),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Text(
              '${song.category.label} · ${song.bpm} BPM',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            DifficultyMeter(difficulty: song.difficulty),
            const SizedBox(height: 10),
            Text(
              song.summary,
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.4),
            ),
            const SizedBox(height: 8),
            Text(
              'Quelle: ${song.source.label} — ${song.source.note}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Akkorde im Song',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 148,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (final chordId in SongLibrary.uniqueChordIds(song)) ...[
                    _ChordDiagramCard(
                      shape: BeginnerChords.byId(chordId) ?? BeginnerChords.em,
                      highlighted: chordId == _currentChord.id,
                    ),
                    const SizedBox(width: 10),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Aktueller Akkord',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _currentChord.name,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.primary,
              ),
            ),
            const SizedBox(height: 8),
            FretboardWidget(
              chord: _currentChord,
              height: 200,
              showViewToggle: true,
            ),
            const SizedBox(height: 20),
            Text(
              'Akkordfolge',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 56,
              child: ListView.builder(
                controller: _chordScroll,
                scrollDirection: Axis.horizontal,
                itemCount: song.events.length,
                itemBuilder: (context, i) {
                  final e = song.events[i];
                  final shape = BeginnerChords.byId(e.chordId);
                  final active = i == idx;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 64,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: active
                            ? cs.primaryContainer
                            : cs.surfaceContainerHighest.withValues(alpha: 0.5),
                        border: Border.all(
                          color: active ? cs.primary : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        shape?.name ?? e.chordId,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight:
                              active ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _controller.progressInLoop,
                minHeight: 4,
                backgroundColor: cs.surfaceContainerHighest,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Play-Along',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                FilledButton.tonalIcon(
                  onPressed: _togglePlay,
                  icon: Icon(
                    _controller.isPlaying ? Icons.pause : Icons.play_arrow,
                  ),
                  label: Text(_controller.isPlaying ? 'Pause' : 'Play'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => _controller.stop(),
                  child: const Text('Stop'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Tempo ${_controller.tempoPercent.round()} % '
              '(${_controller.effectiveBpm.round()} BPM)',
              style: theme.textTheme.titleSmall,
            ),
            Slider(
              value: _controller.tempoPercent,
              min: 50,
              max: 100,
              divisions: 10,
              label: '${_controller.tempoPercent.round()} %',
              onChanged: (v) => _controller.setTempoPercent(v),
            ),
            const SizedBox(height: 8),
            Text(
              'Loop-Abschnitt',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Ganzes Lied'),
                  selected: _controller.loopSection == null,
                  onSelected: (_) => _controller.setLoopSection(null),
                ),
                for (final section in song.sections)
                  ChoiceChip(
                    label: Text(section.label),
                    selected: _controller.loopSection?.id == section.id,
                    onSelected: (_) => _controller.setLoopSection(section),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Mic-Play-Along'),
              subtitle: Text(
                _micMessage ??
                    (_listening
                        ? _micStatusText()
                        : 'Prüft den aktuellen Akkord live (wie im Übungs-Modus).'),
              ),
              value: _micEnabled,
              onChanged: _micStarting ? null : _toggleMic,
            ),
            ],
          ),
        ),
      ),
    );
  }

  String _micStatusText() {
    switch (_micResult.status) {
      case PracticeHitStatus.listening:
        return 'Hört zu… spiele ${_currentChord.name}.';
      case PracticeHitStatus.mismatch:
        return _micResult.hint ??
            'Noch nicht getroffen (${_micResult.matchedCount}/'
                '${_micResult.requiredCount}).';
      case PracticeHitStatus.hit:
        return 'Treffer — ${_currentChord.name} erkannt!';
    }
  }
}

class _ChordDiagramCard extends StatelessWidget {
  const _ChordDiagramCard({
    required this.shape,
    required this.highlighted,
  });

  final ChordShape shape;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 100,
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: highlighted
            ? cs.primaryContainer.withValues(alpha: 0.55)
            : cs.surfaceContainerHighest.withValues(alpha: 0.4),
        border: Border.all(
          color: highlighted ? cs.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            shape.name,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: CustomPaint(
              painter: FretboardPainter(
                chord: shape,
                leftHanded: false,
                viewMode: FretboardViewMode.chordDiagram,
                dotOpacity: 1,
              ),
              child: const SizedBox.expand(),
            ),
          ),
        ],
      ),
    );
  }
}
