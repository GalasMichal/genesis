import '../fretboard/chord_shape.dart';
import '../fretboard/finger_position.dart';

/// Die wichtigsten offenen Anfänger-Akkorde (Griffmuster = Fakten).
///
/// Nummerierung: Saite 1 = hohe e, Saite 6 = tiefe E.
abstract final class BeginnerChords {
  static const em = ChordShape(
    id: 'em',
    name: 'Em',
    mutedStrings: {},
    positions: [
      FingerPosition(stringNumber: 5, fret: 2, finger: 2),
      FingerPosition(stringNumber: 4, fret: 2, finger: 3),
    ],
  );

  static const am = ChordShape(
    id: 'am',
    name: 'Am',
    mutedStrings: {6},
    positions: [
      FingerPosition(stringNumber: 2, fret: 1, finger: 1),
      FingerPosition(stringNumber: 4, fret: 2, finger: 2),
      FingerPosition(stringNumber: 3, fret: 2, finger: 3),
    ],
  );

  static const c = ChordShape(
    id: 'c',
    name: 'C',
    mutedStrings: {6},
    positions: [
      FingerPosition(stringNumber: 2, fret: 1, finger: 1),
      FingerPosition(stringNumber: 4, fret: 2, finger: 2),
      FingerPosition(stringNumber: 5, fret: 3, finger: 3),
    ],
  );

  static const g = ChordShape(
    id: 'g',
    name: 'G',
    mutedStrings: {},
    positions: [
      FingerPosition(stringNumber: 5, fret: 2, finger: 1),
      FingerPosition(stringNumber: 6, fret: 3, finger: 2),
      FingerPosition(stringNumber: 1, fret: 3, finger: 3),
    ],
  );

  static const d = ChordShape(
    id: 'd',
    name: 'D',
    mutedStrings: {6, 5},
    positions: [
      FingerPosition(stringNumber: 3, fret: 2, finger: 1),
      FingerPosition(stringNumber: 1, fret: 2, finger: 2),
      FingerPosition(stringNumber: 2, fret: 3, finger: 3),
    ],
  );

  static const e = ChordShape(
    id: 'e',
    name: 'E',
    mutedStrings: {},
    positions: [
      FingerPosition(stringNumber: 3, fret: 1, finger: 1),
      FingerPosition(stringNumber: 5, fret: 2, finger: 2),
      FingerPosition(stringNumber: 4, fret: 2, finger: 3),
    ],
  );

  static const a = ChordShape(
    id: 'a',
    name: 'A',
    mutedStrings: {6},
    positions: [
      FingerPosition(stringNumber: 4, fret: 2, finger: 1),
      FingerPosition(stringNumber: 3, fret: 2, finger: 2),
      FingerPosition(stringNumber: 2, fret: 2, finger: 3),
    ],
  );

  static const dm = ChordShape(
    id: 'dm',
    name: 'Dm',
    mutedStrings: {6, 5},
    positions: [
      FingerPosition(stringNumber: 1, fret: 1, finger: 1),
      FingerPosition(stringNumber: 3, fret: 2, finger: 2),
      FingerPosition(stringNumber: 2, fret: 3, finger: 3),
    ],
  );

  static const e7 = ChordShape(
    id: 'e7',
    name: 'E7',
    mutedStrings: {},
    positions: [
      FingerPosition(stringNumber: 3, fret: 1, finger: 1),
      FingerPosition(stringNumber: 5, fret: 2, finger: 2),
    ],
  );

  static const g7 = ChordShape(
    id: 'g7',
    name: 'G7',
    mutedStrings: {},
    positions: [
      FingerPosition(stringNumber: 1, fret: 1, finger: 1),
      FingerPosition(stringNumber: 5, fret: 2, finger: 2),
      FingerPosition(stringNumber: 6, fret: 3, finger: 3),
    ],
  );

  /// Alle Anfänger-Akkorde in sinnvoller Lernreihenfolge.
  static const List<ChordShape> all = [
    em,
    am,
    c,
    g,
    d,
    e,
    a,
    dm,
    e7,
    g7,
  ];

  static ChordShape? byId(String id) {
    for (final c in all) {
      if (c.id == id) return c;
    }
    return null;
  }

  /// Prüft Finger 1–4 sowie Bund/Saite im gültigen Bereich.
  static List<String> validate(ChordShape chord) {
    final errors = <String>[];
    for (final m in chord.mutedStrings) {
      if (m < 1 || m > 6) {
        errors.add('${chord.id}: gedämpfte Saite $m ungültig (1–6)');
      }
    }
    for (final p in chord.positions) {
      if (p.stringNumber < 1 || p.stringNumber > 6) {
        errors.add('${chord.id}: Saite ${p.stringNumber} ungültig');
      }
      if (p.fret < 1 || p.fret > 12) {
        errors.add('${chord.id}: Bund ${p.fret} außerhalb 1–12');
      }
      if (p.finger < 1 || p.finger > 4) {
        errors.add('${chord.id}: Finger ${p.finger} außerhalb 1–4');
      }
      if (chord.mutedStrings.contains(p.stringNumber)) {
        errors.add(
          '${chord.id}: Saite ${p.stringNumber} ist gedämpft und fretted',
        );
      }
    }
    final fretted = <int>{};
    for (final p in chord.positions) {
      if (!fretted.add(p.stringNumber)) {
        errors.add('${chord.id}: doppelte Saite ${p.stringNumber}');
      }
    }
    return errors;
  }

  static List<String> validateAll() {
    return [for (final c in all) ...validate(c)];
  }
}
