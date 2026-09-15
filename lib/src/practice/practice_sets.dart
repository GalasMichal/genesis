import '../chords/beginner_chords.dart';
import 'practice_set.dart';
import 'practice_target.dart';

/// Übungs-Sets abgeleitet aus den Anfänger-Tutorial-Lektionen.
///
/// Ablauf je Set: leere Saiten → einzelne Bünde → Akkorde (wo sinnvoll).
abstract final class BeginnerPracticeSets {
  static final List<PracticeSet> all = [
    saitenKennenlernen,
    emUebung,
    amUebung,
    griffwechselEmAm,
    cUebung,
    gUebung,
    dUebung,
  ];

  /// Aus Lektion „Gitarre kennenlernen“.
  static final saitenKennenlernen = PracticeSet(
    id: 'saiten-kennenlernen',
    title: 'Saiten-Kennenlernen',
    summary:
        'Schlage nacheinander alle sechs leeren Saiten an — von der tiefen E '
        'zur hohen e. genesis prüft jede Note übers Mikrofon.',
    lessonId: 'kennenlernen',
    targets: [
      PracticeTargets.openString(6),
      PracticeTargets.openString(5),
      PracticeTargets.openString(4),
      PracticeTargets.openString(3),
      PracticeTargets.openString(2),
      PracticeTargets.openString(1),
    ],
  );

  /// Aus Lektion „Erster Akkord: Em“.
  static final emUebung = PracticeSet(
    id: 'em-uebung',
    title: 'Em-Übung',
    summary:
        'Zuerst die zwei Greif-Noten einzeln, dann den ganzen Em-Griff. '
        'Klarheit vor Tempo.',
    lessonId: 'erster-akkord-em',
    targets: [
      PracticeTargets.openString(6, id: 'em-open-e'),
      PracticeTargets.fretted(stringNumber: 5, fret: 2, id: 'em-a2'),
      PracticeTargets.fretted(stringNumber: 4, fret: 2, id: 'em-d2'),
      PracticeTargets.forChord(BeginnerChords.em, id: 'em-chord-1'),
      PracticeTargets.forChord(BeginnerChords.em, id: 'em-chord-2'),
    ],
  );

  /// Aus Lektion „Zweiter Akkord: Am“.
  static final amUebung = PracticeSet(
    id: 'am-uebung',
    title: 'Am-Übung',
    summary:
        'Die drei Fingerpositionen einzeln, danach zweimal den Am-Griff '
        'streichen (tiefe E bleibt stumm).',
    lessonId: 'akkord-am',
    targets: [
      PracticeTargets.fretted(stringNumber: 2, fret: 1, id: 'am-h1'),
      PracticeTargets.fretted(stringNumber: 4, fret: 2, id: 'am-d2'),
      PracticeTargets.fretted(stringNumber: 3, fret: 2, id: 'am-g2'),
      PracticeTargets.forChord(BeginnerChords.am, id: 'am-chord-1'),
      PracticeTargets.forChord(BeginnerChords.am, id: 'am-chord-2'),
    ],
  );

  /// Aus Lektion „Griffwechsel: Em ↔ Am“.
  static final griffwechselEmAm = PracticeSet(
    id: 'griffwechsel-em-am',
    title: 'Griffwechsel Em ↔ Am',
    summary:
        'Wechsle ruhig zwischen Em und Am. Jeder Griff muss übers Mic '
        'bestätigt werden — kein Durchwinken.',
    lessonId: 'griffwechsel',
    targets: [
      PracticeTargets.forChord(BeginnerChords.em, id: 'wechsel-em-1'),
      PracticeTargets.forChord(BeginnerChords.am, id: 'wechsel-am-1'),
      PracticeTargets.forChord(BeginnerChords.em, id: 'wechsel-em-2'),
      PracticeTargets.forChord(BeginnerChords.am, id: 'wechsel-am-2'),
      PracticeTargets.forChord(BeginnerChords.em, id: 'wechsel-em-3'),
      PracticeTargets.forChord(BeginnerChords.am, id: 'wechsel-am-3'),
    ],
  );

  /// Aus Lektion „C und G“.
  static final cUebung = PracticeSet(
    id: 'c-uebung',
    title: 'C-Übung',
    summary:
        'Einzelne Bünde von C, dann den ganzen offenen C-Griff '
        '(tiefe E stumm).',
    lessonId: 'akkord-c-g',
    targets: [
      PracticeTargets.fretted(stringNumber: 2, fret: 1, id: 'c-h1'),
      PracticeTargets.fretted(stringNumber: 4, fret: 2, id: 'c-d2'),
      PracticeTargets.fretted(stringNumber: 5, fret: 3, id: 'c-a3'),
      PracticeTargets.forChord(BeginnerChords.c, id: 'c-chord-1'),
      PracticeTargets.forChord(BeginnerChords.c, id: 'c-chord-2'),
    ],
  );

  /// Aus Lektion „C und G“.
  static final gUebung = PracticeSet(
    id: 'g-uebung',
    title: 'G-Übung',
    summary:
        'Die drei Greifstellen von G einzeln, danach zweimal den G-Griff.',
    lessonId: 'akkord-c-g',
    targets: [
      PracticeTargets.fretted(stringNumber: 5, fret: 2, id: 'g-a2'),
      PracticeTargets.fretted(stringNumber: 6, fret: 3, id: 'g-e3'),
      PracticeTargets.fretted(stringNumber: 1, fret: 3, id: 'g-e4'),
      PracticeTargets.forChord(BeginnerChords.g, id: 'g-chord-1'),
      PracticeTargets.forChord(BeginnerChords.g, id: 'g-chord-2'),
    ],
  );

  /// Aus Lektion „Akkord D“.
  static final dUebung = PracticeSet(
    id: 'd-uebung',
    title: 'D-Übung',
    summary:
        'Enge Fingerstellung: die drei Töne von D einzeln, dann den Griff '
        '(nur die vier oberen Saiten).',
    lessonId: 'akkord-d',
    targets: [
      PracticeTargets.fretted(stringNumber: 3, fret: 2, id: 'd-g2'),
      PracticeTargets.fretted(stringNumber: 1, fret: 2, id: 'd-e2'),
      PracticeTargets.fretted(stringNumber: 2, fret: 3, id: 'd-h3'),
      PracticeTargets.forChord(BeginnerChords.d, id: 'd-chord-1'),
      PracticeTargets.forChord(BeginnerChords.d, id: 'd-chord-2'),
    ],
  );

  static PracticeSet? byId(String id) {
    for (final s in all) {
      if (s.id == id) return s;
    }
    return null;
  }
}
