import 'dart:math' as math;

/// Mapping Frequenz → Notenname, Oktave und Cent-Abweichung.
///
/// Standard: A4 = [referenceA4Hz] (default 440 Hz).
/// Deutsche Notation: H statt B.
class DetectedNote {
  const DetectedNote({
    required this.noteName,
    required this.octave,
    required this.cents,
    required this.midiNumber,
    required this.frequencyHz,
    required this.targetFrequencyHz,
  });

  /// Notenname ohne Oktave (C, C#, D, …, A, A#, H).
  final String noteName;

  /// Wissenschaftliche Oktave (mittleres C = C4).
  final int octave;

  /// Abweichung in Cent vom nächsten Halbton (−50 … +50 typisch).
  final double cents;

  final int midiNumber;
  final double frequencyHz;
  final double targetFrequencyHz;

  String get displayName => '$noteName$octave';

  bool get isInTune => cents.abs() <= 5;
}

/// Konfigurierbares Noten-Mapping (A4-Referenz).
class NoteMapper {
  NoteMapper({this.referenceA4Hz = 440.0});

  /// Referenzfrequenz für A4 in Hz.
  final double referenceA4Hz;

  static const List<String> _names = [
    'C',
    'C#',
    'D',
    'D#',
    'E',
    'F',
    'F#',
    'G',
    'G#',
    'A',
    'A#',
    'H', // deutsch: H statt B
  ];

  /// Frequenz eines MIDI-Notenwerts (A4 = 69 → [referenceA4Hz]).
  double frequencyForMidi(int midi) {
    return referenceA4Hz * math.pow(2.0, (midi - 69) / 12.0).toDouble();
  }

  /// Hz → nächste Note inkl. Cent-Abweichung.
  DetectedNote fromFrequency(double frequencyHz) {
    if (frequencyHz <= 0 || !frequencyHz.isFinite) {
      return DetectedNote(
        noteName: '—',
        octave: 0,
        cents: 0,
        midiNumber: 0,
        frequencyHz: frequencyHz,
        targetFrequencyHz: 0,
      );
    }

    final midiFloat =
        69 + 12 * (math.log(frequencyHz / referenceA4Hz) / math.ln2);
    final midiRound = midiFloat.round();
    final target = frequencyForMidi(midiRound);
    final cents = 1200 * (math.log(frequencyHz / target) / math.ln2);
    final noteIndex = midiRound % 12;
    // MIDI 0 = C-1 → Oktave = (midi / 12) - 1
    final octave = (midiRound ~/ 12) - 1;

    return DetectedNote(
      noteName: _names[noteIndex < 0 ? noteIndex + 12 : noteIndex],
      octave: octave,
      cents: cents,
      midiNumber: midiRound,
      frequencyHz: frequencyHz,
      targetFrequencyHz: target,
    );
  }

  /// Cent-Abstand zwischen zwei Frequenzen.
  static double centsBetween(double fromHz, double toHz) {
    if (fromHz <= 0 || toHz <= 0) return 0;
    return 1200 * (math.log(toHz / fromHz) / math.ln2);
  }
}
