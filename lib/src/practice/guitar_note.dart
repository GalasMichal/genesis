import '../pitch/note_mapper.dart';
import '../tuner/guitar_tuning.dart';

/// Eine klingende Gitarrenton-Position (Saite × Bund).
///
/// [stringNumber]: 1 = hohe e … 6 = tiefe E (wie FingerPosition / ChordShape).
/// [fret]: 0 = leere Saite, sonst Bund 1+.
class GuitarNote {
  const GuitarNote({
    required this.stringNumber,
    required this.fret,
  }) : assert(stringNumber >= 1 && stringNumber <= 6),
       assert(fret >= 0);

  final int stringNumber;
  final int fret;

  /// Index in [StandardGuitarTuning.strings] (0 = tiefe E).
  int get tuningIndex => 6 - stringNumber;

  GuitarString get openString => StandardGuitarTuning.strings[tuningIndex];

  int get midiNumber => openString.midiNumber + fret;

  double frequencyHz(NoteMapper mapper) => mapper.frequencyForMidi(midiNumber);

  String displayName(NoteMapper mapper) {
    final note = mapper.fromFrequency(frequencyHz(mapper));
    return note.displayName;
  }

  /// Kurzes Label für die UI, z. B. „E2 (leer)“ oder „A2 Bund 2“.
  String positionLabel(NoteMapper mapper) {
    final note = displayName(mapper);
    if (fret == 0) {
      return '$note · Saite $stringNumber leer';
    }
    return '$note · Saite $stringNumber Bund $fret';
  }

  @override
  bool operator ==(Object other) {
    return other is GuitarNote &&
        other.stringNumber == stringNumber &&
        other.fret == fret;
  }

  @override
  int get hashCode => Object.hash(stringNumber, fret);

  @override
  String toString() => 'GuitarNote(s$stringNumber/f$fret)';
}
