import '../chords/beginner_chords.dart';
import '../strumming/pattern_validator.dart';
import 'song.dart';

/// Validiert Genesis-Song-Datensätze (Format + inhaltliche Plausibilität).
abstract final class SongValidator {
  static const minBpm = 40;
  static const maxBpm = 200;
  static const minDifficulty = 1;
  static const maxDifficulty = 5;

  /// Prüft einen Song; leere Liste = gültig.
  static List<String> validate(Song song) {
    final errors = <String>[];
    final prefix = song.id.isEmpty ? '(ohne-id)' : song.id;

    if (song.id.trim().isEmpty) {
      errors.add('$prefix: id fehlt');
    }
    if (song.title.trim().isEmpty) {
      errors.add('$prefix: Titel fehlt');
    }
    errors.addAll(
      PatternValidator.validatePatternId(song.patternId, songId: prefix),
    );
    if (song.difficulty < minDifficulty || song.difficulty > maxDifficulty) {
      errors.add(
        '$prefix: Schwierigkeit ${song.difficulty} außerhalb '
        '$minDifficulty–$maxDifficulty',
      );
    }
    if (song.bpm < minBpm || song.bpm > maxBpm) {
      errors.add(
        '$prefix: Tempo ${song.bpm} BPM außerhalb $minBpm–$maxBpm',
      );
    }
    if (song.source.note.trim().isEmpty) {
      errors.add('$prefix: Quellen-Vermerk fehlt');
    }
    if (song.events.isEmpty) {
      errors.add('$prefix: keine Events');
      return errors;
    }

    double? prevBeat;
    for (var i = 0; i < song.events.length; i++) {
      final e = song.events[i];
      if (e.beat < 0) {
        errors.add('$prefix: Event[$i] beat ${e.beat} < 0');
      }
      if (prevBeat != null && e.beat <= prevBeat) {
        errors.add(
          '$prefix: Event[$i] beat ${e.beat} nicht monoton steigend '
          '(vorher $prevBeat)',
        );
      }
      prevBeat = e.beat;

      if (BeginnerChords.byId(e.chordId) == null) {
        errors.add(
          '$prefix: Event[$i] unbekannter Akkord "${e.chordId}"',
        );
      }
    }

    for (final section in song.sections) {
      if (section.endBeat <= section.startBeat) {
        errors.add(
          '$prefix: Abschnitt "${section.id}" endBeat muss > startBeat sein',
        );
      }
      if (section.startBeat < 0) {
        errors.add('$prefix: Abschnitt "${section.id}" startBeat < 0');
      }
      if (section.endBeat > song.durationBeats + 0.001) {
        errors.add(
          '$prefix: Abschnitt "${section.id}" endet nach Songende '
          '(${section.endBeat} > ${song.durationBeats})',
        );
      }
    }

    if (song.defaultHoldBeats <= 0) {
      errors.add('$prefix: defaultHoldBeats muss > 0 sein');
    }

    return errors;
  }

  static List<String> validateAll(Iterable<Song> songs) {
    return [for (final s in songs) ...validate(s)];
  }
}
