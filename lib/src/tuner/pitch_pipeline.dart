import 'dart:async';
import 'dart:typed_data';

import '../audio/audio_capture.dart';
import '../pitch/note_mapper.dart';
import '../pitch/pitch_result.dart';
import '../pitch/yin_detector.dart';
import 'guitar_tuning.dart';

/// Glattes Tuner-Update für die UI.
class TunerReading {
  const TunerReading({
    required this.pitch,
    required this.note,
    required this.nearestString,
    required this.centsToString,
  });

  final PitchResult pitch;
  final DetectedNote note;
  final GuitarString? nearestString;

  /// Cent zur nächsten offenen Saite (0 wenn keine).
  final double centsToString;

  static const empty = TunerReading(
    pitch: PitchResult(frequencyHz: 0, clarity: 0),
    note: DetectedNote(
      noteName: '—',
      octave: 0,
      cents: 0,
      midiNumber: 0,
      frequencyHz: 0,
      targetFrequencyHz: 0,
    ),
    nearestString: null,
    centsToString: 0,
  );
}

/// Verbindet Capture → YIN → Noten-Mapping → Saiten-Match.
class PitchPipeline {
  PitchPipeline({
    AudioCaptureSource? capture,
    NoteMapper? noteMapper,
    YinPitchDetector? detector,
    StandardGuitarTuning? tuning,
    this.clarityThreshold = 0.75,
    this.bufferSize = 2048,
    this.sampleRate = 44100,
  }) : capture = capture ?? _noopCapture,
       noteMapper = noteMapper ?? NoteMapper(),
       detector =
           detector ??
           YinPitchDetector(sampleRate: sampleRate.toDouble()),
       tuning = tuning ?? StandardGuitarTuning(mapper: noteMapper ?? NoteMapper());

  /// Placeholder wenn Capture von außen injiziert wird.
  static final AudioCaptureSource _noopCapture = _NullCapture();

  final AudioCaptureSource capture;
  final NoteMapper noteMapper;
  final YinPitchDetector detector;
  final StandardGuitarTuning tuning;
  final double clarityThreshold;
  final int bufferSize;
  final int sampleRate;

  StreamSubscription<PcmChunk>? _sub;
  final _controller = StreamController<TunerReading>.broadcast();
  double? _smoothedCents;
  String? _heldNote;

  Stream<TunerReading> get readings => _controller.stream;

  Future<void> start() async {
    await stop();
    final stream = capture.start(
      sampleRate: sampleRate,
      bufferSize: bufferSize,
    );
    _sub = stream.listen(_onChunk, onError: _controller.addError);
  }

  void _onChunk(PcmChunk chunk) {
    // Sample-Rate kann vom Gerät abweichen — Detector anpassen nicht nötig
    // wenn wir den angefragten Rate-Pfad nutzen; Bytes → Float lokal.
    final samples = _pcm16ToFloat(chunk.bytes);
    final pitch = detector.detect(samples);
    if (!pitch.isValid || pitch.clarity < clarityThreshold) {
      return;
    }

    final note = noteMapper.fromFrequency(pitch.frequencyHz);
    final nearest = tuning.nearestString(pitch.frequencyHz);
    var centsToString = note.cents;
    if (nearest != null) {
      final target = nearest.frequencyHz(noteMapper);
      centsToString = NoteMapper.centsBetween(target, pitch.frequencyHz);
    }

    // Leichte EMA-Glättung der Cent-Nadel
    _smoothedCents = _smoothedCents == null
        ? centsToString
        : (_smoothedCents! * 0.55 + centsToString * 0.45);

    // Note kurz halten gegen Flattern
    final displayNote = note;
    if (_heldNote == note.displayName) {
      // keep
    } else if ((_smoothedCents!.abs()) < 35) {
      _heldNote = note.displayName;
    } else {
      _heldNote = note.displayName;
    }

    _controller.add(
      TunerReading(
        pitch: pitch,
        note: DetectedNote(
          noteName: displayNote.noteName,
          octave: displayNote.octave,
          cents: _smoothedCents!,
          midiNumber: displayNote.midiNumber,
          frequencyHz: pitch.frequencyHz,
          targetFrequencyHz: nearest?.frequencyHz(noteMapper) ??
              displayNote.targetFrequencyHz,
        ),
        nearestString: nearest,
        centsToString: _smoothedCents!,
      ),
    );
  }

  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
    await capture.stop();
    _smoothedCents = null;
    _heldNote = null;
  }

  Future<void> dispose() async {
    await stop();
    await _controller.close();
    await capture.dispose();
  }

  /// Test-/Demo-Pfad: speist fertige Readings ein.
  void emitReading(TunerReading reading) {
    if (!_controller.isClosed) {
      _controller.add(reading);
    }
  }

  static Float64List _pcm16ToFloat(Uint8List bytes) {
    final n = bytes.length ~/ 2;
    final out = Float64List(n);
    final data = ByteData.sublistView(bytes);
    for (var i = 0; i < n; i++) {
      out[i] = data.getInt16(i * 2, Endian.little) / 32768.0;
    }
    return out;
  }
}

class _NullCapture implements AudioCaptureSource {
  @override
  bool get isSupported => false;

  @override
  String get unsupportedMessage => '';

  @override
  Future<bool> ensurePermission() async => false;

  @override
  Future<void> openSystemSettings() async {}

  @override
  Stream<PcmChunk> start({int sampleRate = 44100, int bufferSize = 2048}) =>
      const Stream.empty();

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {}
}
