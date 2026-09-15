import 'dart:math' as math;
import 'dart:typed_data';

/// Synthetische Tonsignale für Unit-Tests (ohne Mikrofon).
class SyntheticSignal {
  SyntheticSignal._();

  /// Sinus (+ optionale Obertöne) als Float64-Samples.
  static Float64List sine({
    required double frequencyHz,
    required double sampleRate,
    required int length,
    double amplitude = 0.8,
    List<double> harmonicAmplitudes = const [0.45, 0.22, 0.1],
    double noiseAmplitude = 0.0,
    int? seed,
  }) {
    final out = Float64List(length);
    final rng = math.Random(seed ?? 42);
    final twoPi = 2 * math.pi;

    for (var i = 0; i < length; i++) {
      final t = i / sampleRate;
      var sample = amplitude * math.sin(twoPi * frequencyHz * t);
      for (var h = 0; h < harmonicAmplitudes.length; h++) {
        final harm = h + 2;
        sample +=
            harmonicAmplitudes[h] *
            amplitude *
            math.sin(twoPi * frequencyHz * harm * t);
      }
      if (noiseAmplitude > 0) {
        sample += (rng.nextDouble() * 2 - 1) * noiseAmplitude;
      }
      out[i] = sample.clamp(-1.0, 1.0);
    }
    return out;
  }
}
