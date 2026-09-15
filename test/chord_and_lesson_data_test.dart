import 'package:flutter_test/flutter_test.dart';
import 'package:genesis/src/chords/beginner_chords.dart';
import 'package:genesis/src/fretboard/barre.dart';
import 'package:genesis/src/fretboard/chord_shape.dart';
import 'package:genesis/src/fretboard/finger_position.dart';
import 'package:genesis/src/tutorial/lessons.dart';

void main() {
  test('Alle Anfänger-Akkorde sind gültig (Finger 1–4, Bund/Saite)', () {
    final errors = BeginnerChords.validateAll();
    expect(errors, isEmpty, reason: errors.join('\n'));
    expect(BeginnerChords.all.length, greaterThanOrEqualTo(10));
    expect(BeginnerChords.all.map((c) => c.id), containsAll([
      'em', 'e', 'am', 'a', 'c', 'g', 'd', 'dm', 'e7', 'g7',
    ]));
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
    final errors = BeginnerChords.validate(bad);
    expect(errors, isNotEmpty);
    expect(errors.any((e) => e.contains('gedämpfte Saite')), isTrue);
  });

  test('Open strings und Barré werden korrekt abgeleitet', () {
    final em = BeginnerChords.em;
    expect(em.openStrings, containsAll([1, 2, 3, 6]));
    expect(em.mutedStrings, isEmpty);

    final am = BeginnerChords.am;
    expect(am.mutedStrings, contains(6));
    expect(am.openStrings, containsAll([1, 5]));
    expect(am.openStrings.contains(6), isFalse);

    final f = BeginnerChords.fBarre;
    expect(f.barre, isA<Barre>());
    expect(f.openStrings, isEmpty);
    expect(f.barre!.covers(1), isTrue);
    expect(f.barre!.covers(6), isTrue);
  });

  test('Tutorial hat 8–10 deutsche Lektionen mit Schritten', () {
    expect(BeginnerLessons.all.length, inInclusiveRange(8, 10));
    for (final lesson in BeginnerLessons.all) {
      expect(lesson.title, isNotEmpty);
      expect(lesson.summary.length, greaterThan(40));
      expect(lesson.steps.length, greaterThanOrEqualTo(3));
      expect(lesson.body.length, greaterThan(80));
      expect(lesson.id, isNotEmpty);
    }
    expect(BeginnerLessons.all.any((l) => l.opensTuner), isTrue);
    expect(BeginnerLessons.all.any((l) => l.chord != null), isTrue);

    final titles = BeginnerLessons.all.map((l) => l.title).toList();
    expect(titles.any((t) => t.contains('Em')), isTrue);
    expect(titles.any((t) => t.contains('Am')), isTrue);
    expect(titles.any((t) => t.contains('D')), isTrue);
    expect(titles.any((t) => t.contains('Griffwechsel')), isTrue);
    expect(titles.any((t) => t.contains('Mini-Song')), isTrue);

    // Reihenfolge: Griffwechsel vor C/G, D vor Schlagmuster
    final ids = BeginnerLessons.all.map((l) => l.id).toList();
    expect(ids.indexOf('griffwechsel'), lessThan(ids.indexOf('akkord-c-g')));
    expect(ids.indexOf('akkord-d'), lessThan(ids.indexOf('schlagmuster')));
  });
}
