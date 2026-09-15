import 'practice_target.dart';

/// Ein Übungs-Set: benannte Sequenz von Zielen mit steigender Schwierigkeit.
class PracticeSet {
  const PracticeSet({
    required this.id,
    required this.title,
    required this.summary,
    required this.lessonId,
    required this.targets,
  });

  final String id;
  final String title;
  final String summary;

  /// Zugehörige Tutorial-Lektion (für Ableitung/Navigation).
  final String lessonId;

  /// Ziele in Übungsreihenfolge (leicht → schwerer).
  final List<PracticeTarget> targets;

  int get stepCount => targets.length;
}
