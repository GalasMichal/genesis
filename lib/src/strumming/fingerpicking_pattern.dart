import 'picking_finger.dart';

/// Ein Zupf-Schritt: welcher Finger welche Saite spielt.
///
/// Saitennummerierung wie im Griffbrett: 1 = hohe e … 6 = tiefe E.
/// `null`-Slots in der Sequenz sind Pausen (Achtel-Raster).
class PickingStep {
  const PickingStep({
    required this.finger,
    required this.stringNumber,
  });

  final PickingFinger finger;

  /// 1 (hohe e) … 6 (tiefe E).
  final int stringNumber;

  String get labelDe =>
      '${finger.symbol}→${_stringName(stringNumber)}';

  static String _stringName(int n) => switch (n) {
        1 => 'e',
        2 => 'h',
        3 => 'g',
        4 => 'd',
        5 => 'a',
        6 => 'E',
        _ => '?',
      };
}

/// Fingerpicking-Muster als Achtel-Sequenz.
///
/// ## Format
///
/// - [beatsPerBar]: Viertel pro Takt.
/// - [steps]: Länge `beatsPerBar * 2`; `null` = Pause in diesem Achtel.
/// - Jeder gesetzte Schritt: Finger (p/i/m/a) → Saite (1–6).
class FingerpickingPattern {
  const FingerpickingPattern({
    required this.id,
    required this.title,
    required this.summary,
    required this.beatsPerBar,
    required this.steps,
  });

  final String id;
  final String title;
  final String summary;
  final int beatsPerBar;

  /// Achtel-Slots; `null` = Pause.
  final List<PickingStep?> steps;

  int get eighthCount => steps.length;
  int get expectedEighthCount => beatsPerBar * 2;

  String get displaySymbols => steps
      .map((s) => s == null ? '–' : '${s.finger.symbol}${s.stringNumber}')
      .join(' ');
}
