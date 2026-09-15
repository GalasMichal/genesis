/// Ergebnis einer Pitch-Schätzung.
class PitchResult {
  const PitchResult({
    required this.frequencyHz,
    required this.clarity,
  });

  /// Geschätzte Grundfrequenz in Hz (0 wenn unzuverlässig).
  final double frequencyHz;

  /// Klarheit / Confidence in [0, 1]. Höher = klarerer periodischer Ton.
  final double clarity;

  bool get isValid => frequencyHz > 0 && clarity > 0;

  @override
  String toString() =>
      'PitchResult(f=${frequencyHz.toStringAsFixed(2)} Hz, '
      'clarity=${clarity.toStringAsFixed(3)})';
}
