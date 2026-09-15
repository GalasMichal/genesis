import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../src/audio/audio_capture.dart';
import '../src/audio/audio_capture_factory.dart';
import '../src/pitch/note_mapper.dart';
import '../src/tuner/guitar_tuning.dart';
import '../src/tuner/pitch_pipeline.dart';
import '../widgets/cents_gauge.dart';
import '../widgets/string_strip.dart';

/// Live-Tuner: Pitch-Pipeline + große Noten-/Cent-Anzeige.
class StimmenScreen extends StatefulWidget {
  const StimmenScreen({
    super.key,
    this.capture,
    this.readingStream,
    this.autoStart = false,
  });

  /// Optional injizierte Capture-Quelle (Tests / Fake).
  final AudioCaptureSource? capture;

  /// Optional fertiger Reading-Stream (Widget-Tests ohne Mic).
  final Stream<TunerReading>? readingStream;

  /// Optionaler Auto-Start (nur wenn der Screen bewusst allein genutzt wird).
  /// In der App-Shell bewusst aus: IndexedStack baut alle Tabs sofort.
  final bool autoStart;

  @override
  State<StimmenScreen> createState() => _StimmenScreenState();
}

class _StimmenScreenState extends State<StimmenScreen>
    with WidgetsBindingObserver {
  late final AudioCaptureSource _capture;
  PitchPipeline? _pipeline;
  StreamSubscription<TunerReading>? _sub;

  TunerReading _reading = TunerReading.empty;
  bool _listening = false;
  bool _permissionDenied = false;
  bool _starting = false;
  String? _statusMessage;

  final _tuning = StandardGuitarTuning();
  late final List<({GuitarString string, double frequencyHz})> _stringEntries;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _stringEntries = _tuning.withFrequencies();
    _capture = widget.capture ?? createAudioCapture();

    if (widget.readingStream != null) {
      _sub = widget.readingStream!.listen(_onReading);
      _listening = true;
    } else if (widget.autoStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _startTuner());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sub?.cancel();
    _pipeline?.dispose();
    // Capture nur dispose wenn wir ihn selbst erzeugt haben und Pipeline
    // ihn nicht schon disposed — Pipeline dispose ruft capture.dispose.
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

  Future<void> _startTuner() async {
    if (_starting || widget.readingStream != null) return;
    setState(() {
      _starting = true;
      _statusMessage = null;
    });

    if (!_capture.isSupported || kIsWeb) {
      setState(() {
        _starting = false;
        _listening = false;
        _statusMessage = _capture.isSupported
            ? 'Live-Mikrofon ist im Web-Build eingeschränkt. '
                'Bitte die native App auf dem Handy nutzen.'
            : _capture.unsupportedMessage;
      });
      return;
    }

    final granted = await _capture.ensurePermission();
    if (!mounted) return;

    if (!granted) {
      final permanently = await Permission.microphone.isPermanentlyDenied;
      setState(() {
        _starting = false;
        _permissionDenied = true;
        _statusMessage = permanently
            ? 'Mikrofon-Zugriff wurde dauerhaft verweigert. '
                'Bitte in den Systemeinstellungen erlauben.'
            : 'Ohne Mikrofon kann der Tuner nicht hören. '
                'Bitte erlaube den Zugriff, wenn du gefragt wirst.';
      });
      return;
    }

    final pipeline = PitchPipeline(
      capture: _capture,
      noteMapper: NoteMapper(),
      tuning: _tuning,
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
    if (!mounted) return;
    setState(() => _reading = reading);
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasSignal = _reading.pitch.isValid && _reading.note.noteName != '—';
    final cents = hasSignal ? _reading.centsToString : 0.0;
    final inTune = hasSignal && cents.abs() <= 5;
    final noteLabel = hasSignal
        ? _reading.note.displayName
        : '—';

    return Scaffold(
      appBar: AppBar(title: const Text('Stimmen')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Standard-Stimmung · A4 = 440 Hz',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (!_listening &&
                  _statusMessage == null &&
                  !_starting &&
                  widget.readingStream == null) ...[
                const SizedBox(height: 10),
                Text(
                  'genesis braucht dein Mikrofon, um die Saiten zu hören. '
                  'Audio wird nur lokal verarbeitet und nicht gespeichert.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.4,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 160),
                                  style: theme.textTheme.displayLarge!.copyWith(
                                    fontSize: 96,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -2,
                                    height: 1,
                                    color: inTune
                                        ? const Color(0xFF3DDC97)
                                        : theme.colorScheme.onSurface,
                                  ),
                                  child: Text(noteLabel),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  hasSignal
                                      ? '${_reading.pitch.frequencyHz.toStringAsFixed(1)} Hz'
                                          '  ·  ${cents >= 0 ? '+' : ''}${cents.toStringAsFixed(0)} Cent'
                                      : 'Warte auf Ton…',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontFeatures: const [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 28),
                                SizedBox(
                                  width: constraints.maxWidth,
                                  child: CentsGauge(
                                    cents: cents,
                                    hasSignal: hasSignal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Saiten · E A D G H E',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              StringStrip(
                entries: _stringEntries,
                activeIndex: _reading.nearestString?.index,
                inTune: inTune,
              ),
              const SizedBox(height: 20),
              if (_statusMessage != null) ...[
                _StatusBanner(
                  message: _statusMessage!,
                  denied: _permissionDenied,
                  onOpenSettings: _permissionDenied ? _openSettings : null,
                  onRetry: _startTuner,
                ),
              ] else if (_starting)
                const Center(child: CircularProgressIndicator())
              else if (!_listening && widget.readingStream == null)
                FilledButton.icon(
                  onPressed: _startTuner,
                  icon: const Icon(Icons.mic),
                  label: const Text('Mikrofon starten'),
                )
              else
                Text(
                  'genesis hört mit — spiele eine offene Saite.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
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
