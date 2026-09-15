import 'fingerpicking_pattern.dart';
import 'picking_finger.dart';
import 'stroke_type.dart';
import 'strumming_pattern.dart';
import 'technique_pattern.dart';

/// Katalog der Schlag- und Zupfmuster (Eigencontent für genesis).
abstract final class PatternCatalog {
  static const List<StrummingPattern> strumming = [
    grundschlag44,
    mitPause44,
    betont44,
    ballade44,
    walzer34,
  ];

  static const List<FingerpickingPattern> fingerpicking = [
    arpeggioPima,
    travisEinfach,
  ];

  static List<TechniquePattern> get all => [
        for (final p in strumming) StrumTechnique(p),
        for (final p in fingerpicking) PickTechnique(p),
      ];

  static TechniquePattern? byId(String id) {
    for (final p in strumming) {
      if (p.id == id) return StrumTechnique(p);
    }
    for (final p in fingerpicking) {
      if (p.id == id) return PickTechnique(p);
    }
    return null;
  }

  static StrummingPattern? strummingById(String id) {
    for (final p in strumming) {
      if (p.id == id) return p;
    }
    return null;
  }

  static FingerpickingPattern? fingerpickingById(String id) {
    for (final p in fingerpicking) {
      if (p.id == id) return p;
    }
    return null;
  }

  // ─── Schlagmuster ────────────────────────────────────────────

  /// 4/4-Grundschlag: ↓  ↓↑  ↓↑
  static const grundschlag44 = StrummingPattern(
    id: 'grundschlag-44',
    title: '4/4-Grundschlag',
    summary:
        'Klassischer Einstieg: Abschlag auf 1, dann ↓↑ auf 2 und 3. '
        'Beat 4 bleibt frei zum Atmen.',
    beatsPerBar: 4,
    eighths: [
      StrokeType.down, StrokeType.rest, // 1
      StrokeType.down, StrokeType.up, // 2
      StrokeType.down, StrokeType.up, // 3
      StrokeType.rest, StrokeType.rest, // 4
    ],
  );

  /// 4/4 mit Pause: ↓ – ↓↑ – ↓↑
  static const mitPause44 = StrummingPattern(
    id: 'mit-pause-44',
    title: '4/4 mit Pause',
    summary:
        'Abschlag auf 1, kurze Pause, dann ↓↑ auf 2 und auf 3+4. '
        'Die Pausen geben dem Groove Luft.',
    beatsPerBar: 4,
    eighths: [
      StrokeType.down, StrokeType.rest, // 1 +
      StrokeType.down, StrokeType.up, // 2 +
      StrokeType.rest, StrokeType.down, // 3 +
      StrokeType.up, StrokeType.rest, // 4 +
    ],
  );

  /// Betontes Muster: ↓ ↓↑ × ↑↓↑
  static const betont44 = StrummingPattern(
    id: 'betont-44',
    title: 'Betontes Muster',
    summary:
        'Fester Start, dann gedämpfter Schlag (×) als Akzent und '
        'ein Auf-Ab-Auf zum Taktende — klingt rockiger.',
    beatsPerBar: 4,
    eighths: [
      StrokeType.down, StrokeType.rest, // 1
      StrokeType.down, StrokeType.up, // 2
      StrokeType.muted, StrokeType.up, // 3
      StrokeType.down, StrokeType.up, // 4
    ],
  );

  /// Langsames Balladen-Muster: ruhige Abschläge auf den Vierteln.
  static const ballade44 = StrummingPattern(
    id: 'ballade-44',
    title: 'Langsame Ballade',
    summary:
        'Nur Abschläge auf 1 und 3 — viel Raum zwischen den Schlägen. '
        'Ideal für ruhige Lieder und klare Akkorde.',
    beatsPerBar: 4,
    eighths: [
      StrokeType.down, StrokeType.rest,
      StrokeType.rest, StrokeType.rest,
      StrokeType.down, StrokeType.rest,
      StrokeType.rest, StrokeType.rest,
    ],
  );

  /// 3/4-Walzer: ↓ ↑ ↑
  static const walzer34 = StrummingPattern(
    id: 'walzer-34',
    title: '3/4-Walzer',
    summary:
        'Dreiertakt: starker Abschlag auf 1, leichte Aufschläge auf 2 und 3. '
        'Zähle „eins–zwei–drei“ im Kreis.',
    beatsPerBar: 3,
    eighths: [
      StrokeType.down, StrokeType.rest, // 1
      StrokeType.up, StrokeType.rest, // 2
      StrokeType.up, StrokeType.rest, // 3
    ],
  );

  // ─── Zupfmuster ──────────────────────────────────────────────

  /// Einfaches Arpeggio p–i–m–a (Bass → hohe e).
  static const arpeggioPima = FingerpickingPattern(
    id: 'arpeggio-pima',
    title: 'Einfaches Arpeggio (p–i–m–a)',
    summary:
        'Daumen spielt den Bass, dann Zeige-, Mittel- und Ringfinger '
        'nacheinander die oberen Saiten — ein klarer Einstieg ins Zupfen.',
    beatsPerBar: 4,
    steps: [
      PickingStep(finger: PickingFinger.p, stringNumber: 4), // d
      null,
      PickingStep(finger: PickingFinger.i, stringNumber: 3), // g
      null,
      PickingStep(finger: PickingFinger.m, stringNumber: 2), // h
      null,
      PickingStep(finger: PickingFinger.a, stringNumber: 1), // e
      null,
    ],
  );

  /// Einfaches Travis-Picking: wechselnder Bass + i/m.
  static const travisEinfach = FingerpickingPattern(
    id: 'travis-einfach',
    title: 'Einfaches Travis-Picking',
    summary:
        'Daumen wechselt zwischen zwei Bass-Saiten; Zeige- und Mittelfinger '
        'füllen die Zwischenräume — typischer Folk-/Country-Groove.',
    beatsPerBar: 4,
    steps: [
      PickingStep(finger: PickingFinger.p, stringNumber: 5), // a
      PickingStep(finger: PickingFinger.i, stringNumber: 3), // g
      PickingStep(finger: PickingFinger.p, stringNumber: 4), // d
      PickingStep(finger: PickingFinger.m, stringNumber: 2), // h
      PickingStep(finger: PickingFinger.p, stringNumber: 5),
      PickingStep(finger: PickingFinger.i, stringNumber: 3),
      PickingStep(finger: PickingFinger.p, stringNumber: 4),
      PickingStep(finger: PickingFinger.m, stringNumber: 2),
    ],
  );
}
