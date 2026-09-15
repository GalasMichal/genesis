import 'dart:math' as math;
import 'dart:typed_data';

import 'pitch_result.dart';

/// YIN-Pitch-Detector (de Cheveigné & Kawahara) in reinem Dart.
///
/// Ausgelegt für Echtzeit-Tuner: typisch Buffer 2048 @ 44,1/48 kHz.
/// Liefert Frequenz + Clarity (1 − normalisierter Differenzwert am τ).
class YinPitchDetector {
  YinPitchDetector({
    this.sampleRate = 44100,
    this.threshold = 0.15,
    this.minFrequencyHz = 60,
    this.maxFrequencyHz = 1200,
  });

  final double sampleRate;

  /// Absolute-threshold auf der CMND-Kurve (klassisch ~0.1–0.2).
  final double threshold;

  /// Untergrenze (unterhalb E2 mit etwas Spielraum).
  final double minFrequencyHz;

  /// Obergrenze (über E4 / Melodiesaiten).
  final double maxFrequencyHz;

  /// Schätzt Pitch aus Float-Samples im Bereich ca. [-1, 1].
  PitchResult detect(Float64List samples) {
    final n = samples.length;
    if (n < 64 || sampleRate <= 0) {
      return const PitchResult(frequencyHz: 0, clarity: 0);
    }

    final tauMax = math.min(n ~/ 2, (sampleRate / minFrequencyHz).floor());
    final tauMin = math.max(2, (sampleRate / maxFrequencyHz).ceil());
    if (tauMax <= tauMin) {
      return const PitchResult(frequencyHz: 0, clarity: 0);
    }

    // Difference function d(τ)
    final diff = Float64List(tauMax + 1);
    for (var tau = 1; tau <= tauMax; tau++) {
      var sum = 0.0;
      final limit = n - tau;
      for (var i = 0; i < limit; i++) {
        final delta = samples[i] - samples[i + tau];
        sum += delta * delta;
      }
      diff[tau] = sum;
    }

    // Cumulative mean normalized difference
    final cmnd = Float64List(tauMax + 1);
    cmnd[0] = 1.0;
    var running = 0.0;
    for (var tau = 1; tau <= tauMax; tau++) {
      running += diff[tau];
      cmnd[tau] = running > 0 ? diff[tau] * tau / running : 1.0;
    }

    // Absolute threshold: erstes τ wo CMND < threshold, dann lokales Minimum
    var tauEstimate = -1;
    for (var tau = tauMin; tau < tauMax; tau++) {
      if (cmnd[tau] < threshold) {
        while (tau + 1 <= tauMax && cmnd[tau + 1] < cmnd[tau]) {
          tau++;
        }
        tauEstimate = tau;
        break;
      }
    }

    // Fallback: globales Minimum im Suchfenster
    if (tauEstimate < 0) {
      var bestTau = tauMin;
      var bestVal = cmnd[tauMin];
      for (var tau = tauMin + 1; tau <= tauMax; tau++) {
        if (cmnd[tau] < bestVal) {
          bestVal = cmnd[tau];
          bestTau = tau;
        }
      }
      // Nur akzeptieren wenn halbwegs periodisch
      if (bestVal < 0.4) {
        tauEstimate = bestTau;
      } else {
        return PitchResult(frequencyHz: 0, clarity: (1.0 - bestVal).clamp(0.0, 1.0));
      }
    }

    final refined = _parabolicInterpolation(cmnd, tauEstimate);
    if (refined <= 0) {
      return const PitchResult(frequencyHz: 0, clarity: 0);
    }

    final frequency = sampleRate / refined;
    final cmndAt = cmnd[tauEstimate.clamp(0, tauMax)];
    final clarity = (1.0 - cmndAt).clamp(0.0, 1.0);

    if (frequency < minFrequencyHz || frequency > maxFrequencyHz) {
      return PitchResult(frequencyHz: 0, clarity: clarity);
    }

    return PitchResult(frequencyHz: frequency, clarity: clarity);
  }

  /// PCM16 little-endian Bytes → Float und detect.
  PitchResult detectPcm16(Uint8List bytes, {int offset = 0, int? length}) {
    final byteLen = length ?? (bytes.length - offset);
    final sampleCount = byteLen ~/ 2;
    final samples = Float64List(sampleCount);
    final data = ByteData.sublistView(bytes, offset, offset + byteLen);
    for (var i = 0; i < sampleCount; i++) {
      samples[i] = data.getInt16(i * 2, Endian.little) / 32768.0;
    }
    return detect(samples);
  }

  static double _parabolicInterpolation(Float64List cmnd, int tau) {
    if (tau <= 0 || tau >= cmnd.length - 1) return tau.toDouble();
    final s0 = cmnd[tau - 1];
    final s1 = cmnd[tau];
    final s2 = cmnd[tau + 1];
    final denom = 2 * (2 * s1 - s2 - s0);
    if (denom.abs() < 1e-12) return tau.toDouble();
    final delta = (s2 - s0) / denom;
    return tau + delta;
  }
}
