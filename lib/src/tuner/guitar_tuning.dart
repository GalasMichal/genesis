import '../pitch/note_mapper.dart';

/// Eine offene Saite der Standard-Stimmung.
class GuitarString {
  const GuitarString({
    required this.index,
    required this.label,
    required this.noteName,
    required this.octave,
    required this.midiNumber,
  });

  /// 0 = tiefe E-Saite … 5 = hohe E-Saite.
  final int index;

  /// Anzeige-Label (z. B. „E2“, „H3“).
  final String label;

  final String noteName;
  final int octave;
  final int midiNumber;

  double frequencyHz(NoteMapper mapper) => mapper.frequencyForMidi(midiNumber);
}

/// Standard-Stimmung E A D G H E (A4 konfigurierbar über [NoteMapper]).
class StandardGuitarTuning {
  StandardGuitarTuning({NoteMapper? mapper})
    : mapper = mapper ?? NoteMapper();

  final NoteMapper mapper;

  /// Deutsche Bezeichnung: H statt B für die H-Saite.
  static const strings = <GuitarString>[
    GuitarString(
      index: 0,
      label: 'E2',
      noteName: 'E',
      octave: 2,
      midiNumber: 40,
    ),
    GuitarString(
      index: 1,
      label: 'A2',
      noteName: 'A',
      octave: 2,
      midiNumber: 45,
    ),
    GuitarString(
      index: 2,
      label: 'D3',
      noteName: 'D',
      octave: 3,
      midiNumber: 50,
    ),
    GuitarString(
      index: 3,
      label: 'G3',
      noteName: 'G',
      octave: 3,
      midiNumber: 55,
    ),
    GuitarString(
      index: 4,
      label: 'H3',
      noteName: 'H',
      octave: 3,
      midiNumber: 59,
    ),
    GuitarString(
      index: 5,
      label: 'E4',
      noteName: 'E',
      octave: 4,
      midiNumber: 64,
    ),
  ];

  List<({GuitarString string, double frequencyHz})> withFrequencies() {
    return [
      for (final s in strings) (string: s, frequencyHz: s.frequencyHz(mapper)),
    ];
  }

  /// Nächste offene Saite zur erkannten Frequenz (innerhalb ±100 Cent).
  GuitarString? nearestString(double frequencyHz, {double maxCents = 100}) {
    if (frequencyHz <= 0) return null;
    GuitarString? best;
    var bestAbs = double.infinity;
    for (final s in strings) {
      final target = s.frequencyHz(mapper);
      final cents = NoteMapper.centsBetween(target, frequencyHz).abs();
      if (cents < bestAbs) {
        bestAbs = cents;
        best = s;
      }
    }
    if (best == null || bestAbs > maxCents) return null;
    return best;
  }
}
