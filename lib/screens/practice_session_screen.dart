import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../src/audio/audio_capture.dart';
import '../src/audio/audio_capture_factory.dart';
import '../src/fretboard/fretboard_widget.dart';
import '../src/pitch/note_mapper.dart';
import '../src/practice/practice_checker.dart';
import '../src/practice/practice_progress.dart';
import '../src/practice/practice_set.dart';
import '../src/practice/practice_target.dart';
import '../src/tuner/pitch_pipeline.dart';

/// Aktive Übungs-Session mit Griffbrett + Mic-Check.
class PracticeSessionScreen extends StatefulWidget {
  const PracticeSessionScreen({
    super.key,
    required this.practiceSet,
    required this.progress,
    this.capture,
    this.readingStream,
    this.autoStart = false,
    this.advanceDelay = const Duration(milliseconds: 700),
  });

  final PracticeSet practiceSet;
  final PracticeProgressStore progress;

  /// Optional injizierte Capture-Quelle (Tests).
  final AudioCaptureSource? capture;

  /// Optional fertiger Reading-Stream (Widget-Tests ohne Mic).
  final Stream<TunerReading>? readingStream;

  final bool autoStart;

  /// Pause nach Treffer bevor das nächste Ziel kommt.
  final Duration advanceDelay;

  @override
  State<PracticeSessionScreen> createState() => _PracticeSessionScreenState();
}

class _PracticeSessionScreenState extends State<PracticeSessionScreen>
    with WidgetsBindingObserver {
  late final AudioCaptureSource _capture;
  PitchPipeline? _pipeline;
  StreamSubscription<TunerReading>? _sub;
  late final PracticeChecker _checker;

  int _index = 0;
  PracticeCheckResult _result = PracticeCheckResult.listening;
  bool _listening = false;
  bool _permissionDenied = false;
  bool _starting = false;
  bool _advancing = false;
  bool _finished = false;
  String? _statusMessage;
  bool _leftHanded = false;

  PracticeTarget get _current => widget.practiceSet.targets[_index];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _capture = widget.capture ?? createAudioCapture();
    _checker = PracticeChecker(mapper: NoteMapper());
    _checker.setTarget(_current);

    if (widget.readingStream != null) {
      _sub = widget.readingStream!.listen(_onReading);
      _listening = true;
    } else if (widget.autoStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _startMic());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sub?.cancel();
    _pipeline?.dispose();
    if (widget.capture != null && _pipeline == null) {
      widget.capture!.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _stopCaptureOnly();
    }
  }

  Future<void> _startMic() async {
    if (_starting || widget.readingStream != null || _finished) return;
    setState(() {
      _starting = true;
      _statusMessage = null;
    });

    if (!_capture.isSupported) {
      setState(() {
        _starting = false;
        _listening = false;
        _statusMessage = _capture.unsupportedMessage;
      });
      return;
    }

    final granted = await _capture.ensurePermission();
    if (!mounted) return;

    if (!granted) {
      final permanently =
          !kIsWeb && await Permission.microphone.isPermanentlyDenied;
      setState(() {
        _starting = false;
        _permissionDenied = true;
        _statusMessage = permanently
            ? 'Mikrofon-Zugriff wurde dauerhaft verweigert. '
                'Bitte in den Systemeinstellungen erlauben.'
            : kIsWeb
                ? 'Mikrofon-Zugriff wurde blockiert. Bitte in den '
                    'Browser-Einstellungen für diese Seite erlauben und '
                    'erneut versuchen.'
                : 'Ohne Mikrofon kann genesis deine Töne nicht prüfen. '
                    'Bitte erlaube den Zugriff, wenn du gefragt wirst.';
      });
      return;
    }

    final pipeline = PitchPipeline(
      capture: _capture,
      noteMapper: NoteMapper(),
    );
    _pipeline = pipeline;
    await _sub?.cancel();
    _sub = pipeline.readings.listen(_onReading);
    await pipeline.start();

    if (!mounted) return;
    setState(() {
      _starting = false;
      _listening = true;
      _permissionDenied = false;
      _statusMessage = null;
    });
  }

  void _onReading(TunerReading reading) {
    if (!mounted || _finished || _advancing) return;
    final result = _checker.process(reading);
    setState(() => _result = result);
    if (result.isHit) {
      _onHit();
    }
  }

  Future<void> _onHit() async {
    if (_advancing || _finished) return;
    _advancing = true;
    final completedSteps = _index + 1;
    await widget.progress.recordStep(widget.practiceSet.id, completedSteps);

    await Future<void>.delayed(widget.advanceDelay);
    if (!mounted) return;

    if (_index + 1 >= widget.practiceSet.targets.length) {
      await widget.progress.markSetFinished(
        widget.practiceSet.id,
        widget.practiceSet.stepCount,
      );
      if (!mounted) return;
      setState(() {
        _finished = true;
        _advancing = false;
        _result = PracticeCheckResult.listening;
      });
      await _stopCaptureOnly();
      return;
    }

    setState(() {
      _index++;
      _advancing = false;
      _result = PracticeCheckResult.listening;
      _checker.setTarget(_current);
    });
  }

  Future<void> _stopCaptureOnly() async {
    await _pipeline?.stop();
    if (mounted && widget.readingStream == null) {
      setState(() => _listening = false);
    }
  }

  Future<void> _openSettings() async {
    await _capture.openSystemSettings();
  }

  Color _feedbackColor(ThemeData theme) {
    switch (_result.status) {
      case PracticeHitStatus.hit:
        return const Color(0xFF3DDC97);
      case PracticeHitStatus.mismatch:
        return theme.colorScheme.error;
      case PracticeHitStatus.listening:
        return theme.colorScheme.onSurfaceVariant;
    }
  }

  String _feedbackTitle() {
    if (_finished) return 'Satz geschafft!';
    if (_advancing || _result.isHit) return 'Richtig!';
    switch (_result.status) {
      case PracticeHitStatus.listening:
        return 'Warte auf Ton…';
      case PracticeHitStatus.mismatch:
        return _result.heardDisplayName != null
            ? 'Erkannt: ${_result.heardDisplayName}'
            : 'Noch nicht';
      case PracticeHitStatus.hit:
        return 'Richtig!';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final set = widget.practiceSet;
    final progressValue = _finished
        ? 1.0
        : (_index + (_result.isHit || _advancing ? 1 : 0)) / set.stepCount;

    return Scaffold(
      appBar: AppBar(title: Text(set.title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _finished
                          ? '${set.stepCount} / ${set.stepCount}'
                          : '${_index + 1} / ${set.stepCount}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    _current.label,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progressValue.clamp(0.0, 1.0),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 12),
              if (!_finished) ...[
                Text(
                  _current.instruction,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.4,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(
                    child: FretboardWidget(
                      chord: _current.displayChord,
                      leftHanded: _leftHanded,
                      onLeftHandedChanged: (v) =>
                          setState(() => _leftHanded = v),
                      showViewToggle: false,
                      height: 200,
                    ),
                  ),
                ),
              ] else ...[
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 64,
                          color: const Color(0xFF3DDC97),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Alle Ziele getroffen',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Fortschritt ist lokal gespeichert. '
                          'Morgen nochmal — Klarheit vor Tempo.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Zurück zur Übersicht'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (!_finished) ...[
                const SizedBox(height: 8),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _feedbackColor(theme).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _feedbackColor(theme).withValues(alpha: 0.45),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _feedbackTitle(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: _feedbackColor(theme),
                        ),
                      ),
                      if (_result.hint != null &&
                          !_result.isHit &&
                          !_advancing) ...[
                        const SizedBox(height: 6),
                        Text(
                          _result.hint!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.35,
                          ),
                        ),
                      ],
                      if (_current.kind == PracticeTargetKind.chord &&
                          _result.matchedCount > 0 &&
                          !_result.isHit) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Noten im Fenster: '
                          '${_result.matchedCount}/${_result.requiredCount}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (_statusMessage != null)
                  _StatusBanner(
                    message: _statusMessage!,
                    denied: _permissionDenied,
                    onOpenSettings: _permissionDenied ? _openSettings : null,
                    onRetry: _startMic,
                  )
                else if (_starting)
                  const Center(child: CircularProgressIndicator())
                else if (!_listening && widget.readingStream == null)
                  FilledButton.icon(
                    onPressed: _startMic,
                    icon: const Icon(Icons.mic),
                    label: const Text('Mikrofon starten'),
                  )
                else
                  Text(
                    'genesis hört mit — spiele das Ziel klar an.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.message,
    required this.denied,
    this.onOpenSettings,
    this.onRetry,
  });

  final String message;
  final bool denied;
  final VoidCallback? onOpenSettings;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            denied ? 'Mikrofon-Berechtigung' : 'Hinweis',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (onRetry != null)
                OutlinedButton(
                  onPressed: onRetry,
                  child: const Text('Erneut versuchen'),
                ),
              if (onOpenSettings != null)
                FilledButton(
                  onPressed: onOpenSettings,
                  child: const Text('Einstellungen öffnen'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
