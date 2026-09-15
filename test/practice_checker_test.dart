import 'package:flutter_test/flutter_test.dart';
import 'package:genesis/src/chords/beginner_chords.dart';
import 'package:genesis/src/pitch/note_mapper.dart';
import 'package:genesis/src/pitch/pitch_result.dart';
import 'package:genesis/src/pitch/synthetic_signal.dart';
import 'package:genesis/src/pitch/yin_detector.dart';
import 'package:genesis/src/practice/chord_notes.dart';
import 'package:genesis/src/practice/guitar_note.dart';
import 'package:genesis/src/practice/practice_checker.dart';
import 'package:genesis/src/practice/practice_sets.dart';
import 'package:genesis/src/practice/practice_target.dart';
import 'package:genesis/src/tuner/pitch_pipeline.dart';

void main() {
  final mapper = NoteMapper();

  group('GuitarNote / ChordNotes', () {
    test('leere E-Saite hat MIDI 40', () {
      const note = GuitarNote(stringNumber: 6, fret: 0);
      expect(note.midiNumber, 40);
      expect(note.displayName(mapper), 'E2');
    });

    test('Em klingende Noten inkl. offener Saiten', () {
      final notes = ChordNotes.soundingNotes(BeginnerChords.em);
      expect(notes.length, 6);
      final midis = notes.map((n) => n.midiNumber).toSet();
      expect(midis, containsAll([40, 47, 52, 55, 59, 64])); // E2 B2 E3 G3 H3 E4
    });

    test('Am dämpft tiefe E', () {
      final notes = ChordNotes.soundingNotes(BeginnerChords.am);
      expect(notes.every((n) => n.stringNumber != 6), isTrue);
      expect(notes.length, 5);
    });
  });

  group('PracticeChecker Einzelnote', () {
    test('Treffer bei passender Frequenz', () {
      final checker = PracticeChecker(mapper: mapper);
      checker.setTarget(PracticeTargets.openString(5)); // A2
      final result = checker.processSyntheticMidi(45);
      expect(result.status, PracticeHitStatus.hit);
    });

    test('Mismatch zeigt erkannte Note und Hinweis', () {
      final checker = PracticeChecker(mapper: mapper);
      checker.setTarget(PracticeTargets.openString(5)); // A2
      final result = checker.processSyntheticMidi(40); // E2
      expect(result.status, PracticeHitStatus.mismatch);
      expect(result.heardDisplayName, 'E2');
      expect(result.hint, isNotNull);
      expect(result.hint!, contains('Erkannt'));
    });

    test('zu geringe Clarity → listening', () {
      final checker = PracticeChecker(mapper: mapper, minClarity: 0.8);
      checker.setTarget(PracticeTargets.openString(6));
      final hz = mapper.frequencyForMidi(40);
      final note = mapper.fromFrequency(hz);
      final result = checker.process(
        TunerReading(
          pitch: PitchResult(frequencyHz: hz, clarity: 0.2),
          note: note,
          nearestString: null,
          centsToString: 0,
        ),
      );
      expect(result.status, PracticeHitStatus.listening);
    });

    test('YIN + synthetisches Signal trifft leere A', () {
      final detector = YinPitchDetector(sampleRate: 44100);
      final targetHz = mapper.frequencyForMidi(45);
      final samples = SyntheticSignal.sine(
        frequencyHz: targetHz,
        sampleRate: 44100,
        length: 2048,
      );
      final pitch = detector.detect(samples);
      expect(pitch.isValid, isTrue);

      final checker = PracticeChecker(mapper: mapper);
      checker.setTarget(PracticeTargets.openString(5));
      final note = mapper.fromFrequency(pitch.frequencyHz);
      final result = checker.process(
        TunerReading(
          pitch: pitch,
          note: note,
          nearestString: null,
          centsToString: note.cents,
        ),
      );
      expect(result.status, PracticeHitStatus.hit);
    });
  });

  group('PracticeChecker Akkord (Fenster)', () {
    test('Em erkannt wenn alle Noten im Fenster kommen', () {
      final checker = PracticeChecker(
        mapper: mapper,
        chordWindow: const Duration(seconds: 2),
      );
      checker.setTarget(PracticeTargets.forChord(BeginnerChords.em));

      PracticeCheckResult? last;
      for (final midi in [40, 47, 52, 55, 59, 64]) {
        last = checker.processSyntheticMidi(midi);
      }
      expect(last!.status, PracticeHitStatus.hit);
      expect(last.matchedCount, 6);
    });

    test('teilweise erkannte Noten → mismatch mit Zähler', () {
      final checker = PracticeChecker(mapper: mapper);
      checker.setTarget(PracticeTargets.forChord(BeginnerChords.am));

      final first = checker.processSyntheticMidi(45); // A2 open
      expect(first.status, PracticeHitStatus.mismatch);
      expect(first.matchedCount, 1);
      expect(first.requiredCount, 5);
      expect(first.hint, contains('weiter streichen'));
    });
  });

  group('PracticeSets', () {
    test('enthält die geforderten Sets aus den Lektionen', () {
      final ids = BeginnerPracticeSets.all.map((s) => s.id).toSet();
      expect(
        ids,
        containsAll([
          'saiten-kennenlernen',
          'em-uebung',
          'am-uebung',
          'griffwechsel-em-am',
          'c-uebung',
          'g-uebung',
          'd-uebung',
        ]),
      );
    });

    test('Saiten-Set startet mit leeren Saiten', () {
      final set = BeginnerPracticeSets.saitenKennenlernen;
      expect(set.targets.every((t) => t.kind == PracticeTargetKind.singleNote),
          isTrue);
      expect(set.targets.first.note!.fret, 0);
    });

    test('Em-Set steigert: offen → Bund → Akkord', () {
      final set = BeginnerPracticeSets.emUebung;
      expect(set.targets.first.kind, PracticeTargetKind.singleNote);
      expect(set.targets.last.kind, PracticeTargetKind.chord);
      expect(set.targets.last.chord!.id, 'em');
    });
  });
}
