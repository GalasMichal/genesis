/// Ein Barré: ein Finger drückt mehrere Saiten auf demselben Bund.
class Barre {
  const Barre({
    required this.fret,
    required this.fromString,
    required this.endString,
    this.finger = 1,
  }) : assert(fret >= 1),
       assert(fromString >= 1 && fromString <= 6),
       assert(endString >= 1 && endString <= 6),
       assert(finger >= 1 && finger <= 4),
       assert(fromString != endString);

  /// Bund ab 1.
  final int fret;

  /// Erste Saite des Barrés (1–6).
  final int fromString;

  /// Letzte Saite des Barrés (1–6).
  final int endString;

  /// Finger, der das Barré hält (meist 1 = Zeigefinger).
  final int finger;

  int get lowString => fromString < endString ? fromString : endString;
  int get highString => fromString > endString ? fromString : endString;

  bool covers(int stringNumber) =>
      stringNumber >= lowString && stringNumber <= highString;

  @override
  bool operator ==(Object other) {
    return other is Barre &&
        other.fret == fret &&
        other.fromString == fromString &&
        other.endString == endString &&
        other.finger == finger;
  }

  @override
  int get hashCode => Object.hash(fret, fromString, endString, finger);
}
