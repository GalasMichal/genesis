/// Eine Fingerposition auf dem Griffbrett.
///
/// [stringNumber]: 1 = hohe e-Saite … 6 = tiefe E-Saite.
/// [fret]: Bund ab 1 (leere Saiten gehören nicht hierher).
/// [finger]: 1 = Zeigefinger … 4 = kleiner Finger.
class FingerPosition {
  const FingerPosition({
    required this.stringNumber,
    required this.fret,
    required this.finger,
  }) : assert(stringNumber >= 1 && stringNumber <= 6),
       assert(fret >= 1),
       assert(finger >= 1 && finger <= 4);

  final int stringNumber;
  final int fret;
  final int finger;

  FingerPosition copyWith({int? stringNumber, int? fret, int? finger}) {
    return FingerPosition(
      stringNumber: stringNumber ?? this.stringNumber,
      fret: fret ?? this.fret,
      finger: finger ?? this.finger,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FingerPosition &&
        other.stringNumber == stringNumber &&
        other.fret == fret &&
        other.finger == finger;
  }

  @override
  int get hashCode => Object.hash(stringNumber, fret, finger);

  @override
  String toString() =>
      'FingerPosition(string: $stringNumber, fret: $fret, finger: $finger)';
}
