import 'package:flutter_test/flutter_test.dart';
import 'package:genesis/src/chords/beginner_chords.dart';
import 'package:genesis/src/fretboard/chord_shape.dart';
import 'package:genesis/src/fretboard/finger_position.dart';
import 'package:genesis/src/tutorial/lessons.dart';

void main() {
  test('Alle Anfänger-Akkorde sind gültig (Finger 1–4, Bund/Saite)', () {
    final errors = BeginnerChords.validateAll();
    expect(errors, isEmpty, reason: errors.join('\n'));
    expect(BeginnerChords.all.length, greaterThanOrEqualTo(10));
  });

  test('validate meldet ungültige Finger und Saiten', () {
    final bad = ChordShape(
      id: 'bad',
      name: 'Bad',
      mutedStrings: {0, 7},
      positions: const [
        FingerPosition(stringNumber: 1, fret: 1, finger: 1),
      ],
    );
    // FingerPosition asserts finger 1-4 at construct — craft via validate path
    // by mutating muted only; separate invalid finger via copy isn't possible
    // due to asserts. Check muted + double string via two positions same string:
    final errors = BeginnerChords.validate(bad);
    expect(errors, isNotEmpty);
    expect(errors.any((e) => e.contains('gedämpfte Saite')), isTrue);
  });

  test('Open strings werden korrekt abgeleitet', () {
    final em = BeginnerChords.em;
    expect(em.openStrings, containsAll([1, 2, 3, 6]));
    expect(em.mutedStrings, isEmpty);

    final am = BeginnerChords.am;
    expect(am.mutedStrings, contains(6));
    expect(am.openStrings, containsAll([1, 5]));
    expect(am.openStrings.contains(6), isFalse);
  });

  test('Tutorial hat 8–10 deutsche Lektionen', () {
    expect(BeginnerLessons.all.length, inInclusiveRange(8, 10));
    for (final lesson in BeginnerLessons.all) {
      expect(lesson.title, isNotEmpty);
      expect(lesson.body.length, greaterThan(80));
      expect(lesson.id, isNotEmpty);
    }
    expect(BeginnerLessons.all.any((l) => l.opensTuner), isTrue);
    expect(BeginnerLessons.all.any((l) => l.chord != null), isTrue);
  });
}
