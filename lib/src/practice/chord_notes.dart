import '../fretboard/chord_shape.dart';
import 'guitar_note.dart';

/// Leitet die klingenden Zielnoten eines Akkordgriffs ab.
abstract final class ChordNotes {
  /// Alle Saiten, die beim Akkord klingen sollen (ohne Mute).
  ///
  /// Fretted-Saiten aus [ChordShape.positions] und Barré; leere Saiten aus
  /// [ChordShape.openStrings]. Bund 0 = leer.
  static List<GuitarNote> soundingNotes(ChordShape chord) {
    final byString = <int, int>{};

    if (chord.barre != null) {
      final b = chord.barre!;
      for (var s = b.lowString; s <= b.highString; s++) {
        byString[s] = b.fret;
      }
    }

    for (final p in chord.positions) {
      byString[p.stringNumber] = p.fret;
    }

    for (final s in chord.openStrings) {
      byString.putIfAbsent(s, () => 0);
    }

    final notes = <GuitarNote>[
      for (final entry in byString.entries)
        if (!chord.mutedStrings.contains(entry.key))
          GuitarNote(stringNumber: entry.key, fret: entry.value),
    ];
    notes.sort((a, b) => b.stringNumber.compareTo(a.stringNumber));
    return notes;
  }
}
