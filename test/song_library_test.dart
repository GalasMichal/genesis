import 'package:flutter_test/flutter_test.dart';
import 'package:genesis/src/chords/beginner_chords.dart';
import 'package:genesis/src/songs/play_along_controller.dart';
import 'package:genesis/src/songs/song.dart';
import 'package:genesis/src/songs/song_category.dart';
import 'package:genesis/src/songs/song_library.dart';
import 'package:genesis/src/songs/song_validator.dart';

void main() {
  group('SongValidator', () {
    test('Bibliothek: 10–14 Songs, alle gültig', () {
      expect(SongLibrary.all.length, inInclusiveRange(10, 14));
      final errors = SongValidator.validateAll(SongLibrary.all);
      expect(errors, isEmpty, reason: errors.join('\n'));
    });

    test('Jeder Akkord existiert im Datensatz', () {
      for (final song in SongLibrary.all) {
        for (final e in song.events) {
          expect(
            BeginnerChords.byId(e.chordId),
            isNotNull,
            reason: '${song.id}: unbekannter Akkord ${e.chordId}',
          );
        }
      }
    });

    test('Timing ist streng monoton steigend', () {
      for (final song in SongLibrary.all) {
        double? prev;
        for (final e in song.events) {
          if (prev != null) {
            expect(e.beat, greaterThan(prev), reason: song.id);
          }
          prev = e.beat;
        }
      }
    });

    test('Tempo und Schwierigkeit sind plausibel', () {
      for (final song in SongLibrary.all) {
        expect(song.bpm, inInclusiveRange(SongValidator.minBpm, SongValidator.maxBpm));
        expect(
          song.difficulty,
          inInclusiveRange(SongValidator.minDifficulty, SongValidator.maxDifficulty),
        );
        expect(song.source.note, isNotEmpty);
      }
    });

    test('Alle Kategorien sind vertreten', () {
      final cats = SongLibrary.all.map((s) => s.category).toSet();
      expect(cats, containsAll(SongCategory.values));
    });

    test('Quellen-Vermerke: Eigen vs. gemeinfrei je Kategorie', () {
      for (final song in SongLibrary.all) {
        final expectOriginal =
            song.category == SongCategory.beginnerExercises ||
            song.category == SongCategory.originalPopRock;
        if (expectOriginal) {
          expect(song.source.kind, SongSourceKind.original, reason: song.id);
        } else {
          expect(song.source.kind, SongSourceKind.publicDomain, reason: song.id);
        }
        expect(song.source.note.toLowerCase(), contains(
          expectOriginal ? 'eigen' : 'gemeinfrei',
        ), reason: song.id);
      }
    });

    test('validate meldet ungültige Songs', () {
      const bad = Song(
        id: 'bad',
        title: 'Bad',
        category: SongCategory.beginnerExercises,
        difficulty: 9,
        bpm: 10,
        patternId: '',
        source: SongSource(kind: SongSourceKind.original, note: ''),
        events: [
          SongEvent(beat: 4, chordId: 'em'),
          SongEvent(beat: 2, chordId: 'xyz'),
        ],
      );
      final errors = SongValidator.validate(bad);
      expect(errors, isNotEmpty);
      expect(errors.any((e) => e.contains('Schwierigkeit')), isTrue);
      expect(errors.any((e) => e.contains('Tempo')), isTrue);
      expect(errors.any((e) => e.contains('monoton')), isTrue);
      expect(errors.any((e) => e.contains('unbekannter Akkord')), isTrue);
      expect(errors.any((e) => e.contains('Quellen')), isTrue);
      expect(errors.any((e) => e.contains('Technik-Muster')), isTrue);
    });

    test('Jeder Song hat ein gültiges Technik-Muster', () {
      for (final song in SongLibrary.all) {
        expect(song.patternId, isNotEmpty, reason: song.id);
        final errors = SongValidator.validate(song);
        expect(
          errors.where((e) => e.contains('Technik-Muster')),
          isEmpty,
          reason: '${song.id}: ${errors.join(", ")}',
        );
      }
    });

    test('byCategory filtert korrekt', () {
      final polish = SongLibrary.byCategory(SongCategory.polishFolk);
      expect(polish, isNotEmpty);
      expect(
        polish.every((s) => s.category == SongCategory.polishFolk),
        isTrue,
      );
      expect(SongLibrary.byCategory(null).length, SongLibrary.all.length);
    });

    test('Spektrum: Einsteiger, Englisch, Polnisch, Klassik, Pop/Rock', () {
      expect(
        SongLibrary.byCategory(SongCategory.beginnerExercises).length,
        greaterThanOrEqualTo(2),
      );
      expect(
        SongLibrary.byCategory(SongCategory.englishTraditionals).length,
        greaterThanOrEqualTo(4),
      );
      expect(
        SongLibrary.byCategory(SongCategory.polishFolk).length,
        greaterThanOrEqualTo(3),
      );
      expect(
        SongLibrary.byCategory(SongCategory.classical).length,
        greaterThanOrEqualTo(1),
      );
      expect(
        SongLibrary.byCategory(SongCategory.originalPopRock).length,
        greaterThanOrEqualTo(2),
      );
    });
  });

  group('PlayAlongController', () {
    test('Tempo 50–100 %, Beat läuft und looped', () {
      final song = SongLibrary.emAmTakt;
      final c = PlayAlongController(song);
      expect(c.tempoPercent, 100);
      c.setTempoPercent(50);
      expect(c.tempoPercent, 50);
      expect(c.effectiveBpm, song.bpm * 0.5);

      c.setTempoPercent(200);
      expect(c.tempoPercent, 100);

      c.play();
      c.tick(const Duration(seconds: 1));
      expect(c.beat, greaterThan(0));
      expect(c.isPlaying, isTrue);

      c.setLoopSection(song.sections.first);
      expect(c.loopStart, 0);
      expect(c.loopEnd, 8);

      c.seek(7.5);
      c.tick(const Duration(seconds: 30));
      expect(c.beat, lessThan(8));
      expect(c.beat, greaterThanOrEqualTo(0));

      c.stop();
      expect(c.isPlaying, isFalse);
      expect(c.beat, 0);
    });

    test('currentChordId folgt der Timeline', () {
      final c = PlayAlongController(SongLibrary.emAmTakt);
      expect(c.currentChordId, 'em');
      c.seek(4);
      expect(c.currentChordId, 'am');
      c.seek(8);
      expect(c.currentChordId, 'em');
    });
  });
}
