import '../chords/beginner_chords.dart';
import '../fretboard/chord_shape.dart';
import '../fretboard/finger_position.dart';
import '../pitch/note_mapper.dart';
import 'chord_notes.dart';
import 'guitar_note.dart';

enum PracticeTargetKind { singleNote, chord }

/// Ein Übungsschritt: einzelne Saite/Bund oder ganzer Akkord.
class PracticeTarget {
  const PracticeTarget._({
    required this.id,
    required this.kind,
    required this.label,
    required this.instruction,
    this.note,
    this.chord,
  });

  factory PracticeTarget.singleNote({
    required String id,
    required GuitarNote note,
    String? label,
    String? instruction,
    NoteMapper? mapper,
  }) {
    final m = mapper ?? NoteMapper();
    final display = note.displayName(m);
    return PracticeTarget._(
      id: id,
      kind: PracticeTargetKind.singleNote,
      label: label ?? display,
      instruction:
          instruction ??
          (note.fret == 0
              ? 'Schlage die leere Saite ${note.stringNumber} an ($display).'
              : 'Greife Saite ${note.stringNumber} Bund ${note.fret} ($display) und schlage klar an.'),
      note: note,
    );
  }

  factory PracticeTarget.chord({
    required String id,
    required ChordShape chord,
    String? label,
    String? instruction,
  }) {
    return PracticeTarget._(
      id: id,
      kind: PracticeTargetKind.chord,
      label: label ?? chord.name,
      instruction:
          instruction ??
          'Baue ${chord.name} und streiche die klingenden Saiten langsam an.',
      chord: chord,
    );
  }

  final String id;
  final PracticeTargetKind kind;
  final String label;
  final String instruction;
  final GuitarNote? note;
  final ChordShape? chord;

  /// Noten, die für „richtig“ erkannt werden müssen.
  List<GuitarNote> get requiredNotes {
    switch (kind) {
      case PracticeTargetKind.singleNote:
        return [note!];
      case PracticeTargetKind.chord:
        return ChordNotes.soundingNotes(chord!);
    }
  }

  /// Griffbrett-Darstellung für dieses Ziel.
  ChordShape get displayChord {
    if (kind == PracticeTargetKind.chord) return chord!;
    final n = note!;
    if (n.fret == 0) {
      return ChordShape(
        id: 'open-${n.stringNumber}',
        name: label,
        positions: const [],
        mutedStrings: {
          for (var s = 1; s <= 6; s++)
            if (s != n.stringNumber) s,
        },
      );
    }
    return ChordShape(
      id: 'note-${n.stringNumber}-${n.fret}',
      name: label,
      positions: [
        FingerPosition(
          stringNumber: n.stringNumber,
          fret: n.fret,
          finger: 1,
        ),
      ],
      mutedStrings: {
        for (var s = 1; s <= 6; s++)
          if (s != n.stringNumber) s,
      },
    );
  }

  /// Kurze Korrekturhilfe, wenn [heardMidi] nicht zum Ziel passt.
  String correctionHint(int heardMidi, NoteMapper mapper) {
    final heard = mapper.fromFrequency(mapper.frequencyForMidi(heardMidi));
    final required = requiredNotes;
    if (required.length == 1) {
      final target = required.first;
      final targetMidi = target.midiNumber;
      final delta = heardMidi - targetMidi;
      if (delta == 0) return 'Fast — warte auf einen klaren Ton.';
      if (delta.abs() == 12) {
        return 'Oktave daneben: du spielst ${heard.displayName}, Ziel ist '
            '${target.displayName(mapper)}. Prüfe die Saite.';
      }
      if (delta > 0) {
        return 'Erkannt: ${heard.displayName}. Zu hoch — ein Bund tiefer '
            'oder die tiefere Saite versuchen.';
      }
      return 'Erkannt: ${heard.displayName}. Zu tief — Bund höher greifen '
          'oder die richtige Saite anschlagen.';
    }

    final missing = required
        .where((n) => n.midiNumber != heardMidi)
        .map((n) => n.displayName(mapper))
        .take(3)
        .join(', ');
    return 'Erkannt: ${heard.displayName}. Noch im Akkord nötig: $missing.';
  }
}

/// Hilfs-Factory für bekannte Anfänger-Akkorde.
abstract final class PracticeTargets {
  static PracticeTarget openString(int stringNumber, {String? id}) {
    final note = GuitarNote(stringNumber: stringNumber, fret: 0);
    return PracticeTarget.singleNote(
      id: id ?? 'open-$stringNumber',
      note: note,
    );
  }

  static PracticeTarget fretted({
    required int stringNumber,
    required int fret,
    String? id,
  }) {
    final note = GuitarNote(stringNumber: stringNumber, fret: fret);
    return PracticeTarget.singleNote(
      id: id ?? 's$stringNumber-f$fret',
      note: note,
    );
  }

  static PracticeTarget forChord(ChordShape chord, {String? id}) {
    return PracticeTarget.chord(
      id: id ?? 'chord-${chord.id}',
      chord: chord,
    );
  }

  static PracticeTarget em() => forChord(BeginnerChords.em);
  static PracticeTarget am() => forChord(BeginnerChords.am);
  static PracticeTarget c() => forChord(BeginnerChords.c);
  static PracticeTarget g() => forChord(BeginnerChords.g);
  static PracticeTarget d() => forChord(BeginnerChords.d);
}
