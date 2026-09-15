import 'stroke_type.dart';

/// Ein Schlagmuster in Achtel-Auflösung.
///
/// ## Format
///
/// - [beatsPerBar]: Taktart-Nenner in Viertelnoten (4 = 4/4, 3 = 3/4).
/// - [eighths]: genau `beatsPerBar * 2` Einträge — ein Slot pro Achtel.
/// - Typen: [StrokeType.down] ↓, [StrokeType.up] ↑, [StrokeType.rest] –,
///   [StrokeType.muted] ×.
///
/// Beispiel 4/4-Grundschlag `↓ ↓↑ ↓↑`:
/// `[↓, –, ↓, ↑, ↓, ↑, –, –]`
class StrummingPattern {
  const StrummingPattern({
    required this.id,
    required this.title,
    required this.summary,
    required this.beatsPerBar,
    required this.eighths,
  });

  final String id;
  final String title;
  final String summary;

  /// Viertelnoten pro Takt (3 oder 4).
  final int beatsPerBar;

  /// Achtel-Slots eines Taktes (`beatsPerBar * 2` Einträge).
  final List<StrokeType> eighths;

  int get eighthCount => eighths.length;

  /// Erwartete Slot-Anzahl für diese Taktart.
  int get expectedEighthCount => beatsPerBar * 2;

  /// Symbolkette z. B. `↓–↓↑↓↑––` (ohne Leerzeichen).
  String get symbolString => eighths.map((s) => s.symbol).join();

  /// Lesbare Kurzform mit Leerzeichen.
  String get displaySymbols => eighths.map((s) => s.symbol).join(' ');
}
