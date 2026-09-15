import '../fretboard/chord_shape.dart';

/// Eine Lektion im Anfänger-Pfad.
class Lesson {
  const Lesson({
    required this.id,
    required this.title,
    required this.summary,
    required this.steps,
    this.chord,
    this.practiceHint,
    this.opensTuner = false,
    this.techniquePatternId,
  });

  final String id;
  final String title;

  /// Kurzer Einstiegstext (Deutsch, Eigencontent).
  final String summary;

  /// Schritt-für-Schritt-Anleitung.
  final List<String> steps;

  /// Optionales Griffbild über das Griffbrett-Widget.
  final ChordShape? chord;

  /// Kurzer Übungshinweis unter dem Griff / Text.
  final String? practiceHint;

  /// Wenn true, zeigt die UI einen Sprung zum Stimmen-Tab.
  final bool opensTuner;

  /// Optionales Schlag-/Zupfmuster zum Mitüben (PatternCatalog-ID).
  final String? techniquePatternId;

  /// Zusammengefügter Fließtext (für Tests / Suche).
  String get body => '$summary\n\n${steps.map((s) => '• $s').join('\n')}';
}
