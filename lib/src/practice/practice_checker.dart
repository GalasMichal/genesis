import '../pitch/note_mapper.dart';
import '../pitch/pitch_result.dart';
import '../tuner/pitch_pipeline.dart';
import 'practice_target.dart';

/// Ergebnis eines Mic-Checks gegen das aktuelle Übungsziel.
enum PracticeHitStatus {
  /// Noch kein brauchbares Signal.
  listening,

  /// Note erkannt, aber nicht (vollständig) passend.
  mismatch,

  /// Ziel erreicht (Einzelnote oder alle Akkordnoten im Fenster).
  hit,
}

class PracticeCheckResult {
  const PracticeCheckResult({
    required this.status,
    this.heardMidi,
    this.heardDisplayName,
    this.matchedCount = 0,
    this.requiredCount = 1,
    this.hint,
  });

  final PracticeHitStatus status;
  final int? heardMidi;
  final String? heardDisplayName;
  final int matchedCount;
  final int requiredCount;
  final String? hint;

  bool get isHit => status == PracticeHitStatus.hit;

  static const listening = PracticeCheckResult(
    status: PracticeHitStatus.listening,
  );
}

/// Prüft Tuner-Readings gegen Übungsziele.
///
/// ## Akkord-Erkennung (pragmatisch, monophon)
///
/// Echte Polyphonie lösen wir im MVP nicht. Stattdessen:
/// 1. Aus dem Griff werden die **klingenden** Noten (MIDI) abgeleitet.
/// 2. Jede erkannte Pitch (Clarity + Cent-Toleranz) markiert die passende
///    Zielnote als „gehört“.
/// 3. Ein Akkord gilt als erkannt, wenn **alle** geforderten Noten innerhalb
///    eines kurzen Zeitfensters ([chordWindow]) nacheinander erkannt wurden
///    (typischer Strum + Ausklingen). Die Reihenfolge ist egal.
/// 4. Einzelnoten brauchen nur eine stabile Treffer innerhalb der Cent-Toleranz.
class PracticeChecker {
  PracticeChecker({
    NoteMapper? mapper,
    this.centsTolerance = 35,
    this.chordWindow = const Duration(milliseconds: 2000),
    this.minClarity = 0.75,
  }) : mapper = mapper ?? NoteMapper();

  final NoteMapper mapper;

  /// Maximaler Cent-Abstand zur Zielnote für einen Treffer.
  final double centsTolerance;

  /// Zeitfenster, in dem alle Akkordnoten erkannt sein müssen.
  final Duration chordWindow;

  final double minClarity;

  PracticeTarget? _target;
  final Map<int, DateTime> _heardAt = {};
  DateTime? _windowStart;
  String? _lastHeardName;
  int? _lastHeardMidi;

  PracticeTarget? get target => _target;

  void setTarget(PracticeTarget target) {
    _target = target;
    resetWindow();
  }

  void resetWindow() {
    _heardAt.clear();
    _windowStart = null;
    _lastHeardName = null;
    _lastHeardMidi = null;
  }

  /// Verarbeitet ein Tuner-Reading und liefert den aktuellen Check-Status.
  PracticeCheckResult process(TunerReading reading) {
    final target = _target;
    if (target == null) return PracticeCheckResult.listening;

    final required = target.requiredNotes;
    final requiredMidis = {for (final n in required) n.midiNumber};

    if (!reading.pitch.isValid || reading.pitch.clarity < minClarity) {
      return _partialOrListening(requiredMidis);
    }

    final heardMidi = reading.note.midiNumber;
    final heardName = reading.note.displayName;
    _lastHeardMidi = heardMidi;
    _lastHeardName = heardName;

    // Welche Zielnote liegt innerhalb der Cent-Toleranz?
    int? matchedMidi;
    var bestAbs = double.infinity;
    for (final midi in requiredMidis) {
      final targetHz = mapper.frequencyForMidi(midi);
      final cents = NoteMapper.centsBetween(
        targetHz,
        reading.pitch.frequencyHz,
      ).abs();
      if (cents <= centsTolerance && cents < bestAbs) {
        bestAbs = cents;
        matchedMidi = midi;
      }
    }

    final now = DateTime.now();

    if (matchedMidi != null) {
      if (target.kind == PracticeTargetKind.singleNote) {
        return PracticeCheckResult(
          status: PracticeHitStatus.hit,
          heardMidi: heardMidi,
          heardDisplayName: heardName,
          matchedCount: 1,
          requiredCount: 1,
        );
      }

      // Akkord: Fenster starten / verlängern
      _windowStart ??= now;
      if (now.difference(_windowStart!) > chordWindow) {
        // Fenster abgelaufen — neu mit dieser Note starten
        _heardAt.clear();
        _windowStart = now;
      }
      _heardAt[matchedMidi] = now;
      _pruneOutsideWindow(now);

      if (_heardAt.keys.toSet().containsAll(requiredMidis)) {
        return PracticeCheckResult(
          status: PracticeHitStatus.hit,
          heardMidi: heardMidi,
          heardDisplayName: heardName,
          matchedCount: requiredMidis.length,
          requiredCount: requiredMidis.length,
        );
      }

      return PracticeCheckResult(
        status: PracticeHitStatus.mismatch,
        heardMidi: heardMidi,
        heardDisplayName: heardName,
        matchedCount: _heardAt.length,
        requiredCount: requiredMidis.length,
        hint:
            'Gut: $heardName. Noch ${_remainingLabels(requiredMidis)} — '
            'weiter streichen.',
      );
    }

    // Falsche Note
    _pruneOutsideWindow(now);
    return PracticeCheckResult(
      status: PracticeHitStatus.mismatch,
      heardMidi: heardMidi,
      heardDisplayName: heardName,
      matchedCount: _heardAt.length,
      requiredCount: requiredMidis.length,
      hint: target.correctionHint(heardMidi, mapper),
    );
  }

  /// Test-Hilfe: speist eine reine MIDI-Frequenz als TunerReading ein.
  PracticeCheckResult processSyntheticMidi(
    int midi, {
    double clarity = 0.9,
  }) {
    final hz = mapper.frequencyForMidi(midi);
    final note = mapper.fromFrequency(hz);
    return process(
      TunerReading(
        pitch: PitchResult(frequencyHz: hz, clarity: clarity),
        note: note,
        nearestString: null,
        centsToString: note.cents,
      ),
    );
  }

  void _pruneOutsideWindow(DateTime now) {
    if (_windowStart == null) return;
    if (now.difference(_windowStart!) > chordWindow) {
      _heardAt.clear();
      _windowStart = null;
      return;
    }
    _heardAt.removeWhere((_, t) => now.difference(t) > chordWindow);
    if (_heardAt.isEmpty) {
      _windowStart = null;
    }
  }

  PracticeCheckResult _partialOrListening(Set<int> requiredMidis) {
    if (_heardAt.isEmpty) {
      return PracticeCheckResult.listening;
    }
    return PracticeCheckResult(
      status: PracticeHitStatus.mismatch,
      heardMidi: _lastHeardMidi,
      heardDisplayName: _lastHeardName,
      matchedCount: _heardAt.length,
      requiredCount: requiredMidis.length,
      hint:
          'Warte auf die restlichen Töne '
          '(${_heardAt.length}/${requiredMidis.length})…',
    );
  }

  String _remainingLabels(Set<int> requiredMidis) {
    final missing = requiredMidis.difference(_heardAt.keys.toSet());
    return missing
        .map(
          (m) =>
              mapper.fromFrequency(mapper.frequencyForMidi(m)).displayName,
        )
        .join(', ');
  }
}
