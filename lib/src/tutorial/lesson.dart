import '../fretboard/chord_shape.dart';

/// Eine Lektion im Anfänger-Pfad.
class Lesson {
  const Lesson({
    required this.id,
    required this.title,
    required this.body,
    this.chord,
    this.practiceHint,
    this.opensTuner = false,
  });

  final String id;
  final String title;

  /// Pädagogischer Erklärtext (Deutsch, Eigencontent).
  final String body;

  /// Optionales Griffbild über das Griffbrett-Widget.
  final ChordShape? chord;

  /// Kurzer Übungshinweis unter dem Griff / Text.
  final String? practiceHint;

  /// Wenn true, zeigt die UI einen Sprung zum Stimmen-Tab.
  final bool opensTuner;
}
