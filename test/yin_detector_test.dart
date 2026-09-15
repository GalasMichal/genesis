import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:genesis/src/pitch/note_mapper.dart';
import 'package:genesis/src/pitch/synthetic_signal.dart';
import 'package:genesis/src/pitch/yin_detector.dart';
import 'package:genesis/src/tuner/guitar_tuning.dart';

void main() {
  const sampleRate = 44100.0;
  const bufferSize = 2048;

  /// ±5 Cent bei Frequenz f ≈ f * (2^(5/1200) - 1)
  double centsError(double expected, double actual) {
    if (expected <= 0 || actual <= 0) return double.infinity;
    return (1200 * (math.log(actual / expected) / math.ln2)).abs();
  }

  group('NoteMapper', () {
    test('A4 = 440 Hz → A4, 0 Cent', () {
      final note = NoteMapper().fromFrequency(440);
      expect(note.noteName, 'A');
      expect(note.octave, 4);
      expect(note.cents.abs(), lessThan(0.01));
    });

    test('deutsche Notation: MIDI 59 → H3', () {
      final mapper = NoteMapper();
      final hz = mapper.frequencyForMidi(59);
      final note = mapper.fromFrequency(hz);
      expect(note.noteName, 'H');
      expect(note.octave, 3);
    });

    test('Referenz A4=442 konfigurierbar', () {
      final mapper = NoteMapper(referenceA4Hz: 442);
      expect(mapper.frequencyForMidi(69), closeTo(442, 1e-9));
    });
  });

  group('YIN Detector — offene Saiten', () {
    final detector = YinPitchDetector(
      sampleRate: sampleRate,
      threshold: 0.15,
      minFrequencyHz: 70,
      maxFrequencyHz: 500,
    );

    final expected = <String, double>{
      for (final s in StandardGuitarTuning.strings)
        s.label: NoteMapper().frequencyForMidi(s.midiNumber),
    };

    for (final entry in expected.entries) {
      test('${entry.key}: sauberer Sinus+Obertöne ±5 Cent', () {
        final signal = SyntheticSignal.sine(
          frequencyHz: entry.value,
          sampleRate: sampleRate,
          length: bufferSize,
        );
        final result = detector.detect(signal);
        expect(result.isValid, isTrue, reason: 'kein Pitch für ${entry.key}');
        expect(result.clarity, greaterThan(0.8));
        final err = centsError(entry.value, result.frequencyHz);
        expect(
          err,
          lessThanOrEqualTo(5.0),
          reason:
              '${entry.key}: erwartet ${entry.value.toStringAsFixed(2)} Hz, '
              'erkannt ${result.frequencyHz.toStringAsFixed(2)} Hz '
              '(${err.toStringAsFixed(2)} Cent)',
        );
      });

      test('${entry.key}: leichtes Rauschen ±5 Cent', () {
        final signal = SyntheticSignal.sine(
          frequencyHz: entry.value,
          sampleRate: sampleRate,
          length: bufferSize,
          noiseAmplitude: 0.05,
          seed: entry.key.hashCode,
        );
        final result = detector.detect(signal);
        expect(result.isValid, isTrue);
        final err = centsError(entry.value, result.frequencyHz);
        expect(
          err,
          lessThanOrEqualTo(5.0),
          reason:
              '${entry.key} mit Rauschen: erwartet ${entry.value.toStringAsFixed(2)}, '
              'erkannt ${result.frequencyHz.toStringAsFixed(2)} '
              '(${err.toStringAsFixed(2)} Cent)',
        );
      });
    }

    test('48 kHz Sample-Rate E2', () {
      const sr = 48000.0;
      final d = YinPitchDetector(sampleRate: sr);
      const f = 82.4068892280175;
      final signal = SyntheticSignal.sine(
        frequencyHz: f,
        sampleRate: sr,
        length: bufferSize,
      );
      final result = d.detect(signal);
      expect(centsError(f, result.frequencyHz), lessThanOrEqualTo(5.0));
    });
  });

  group('StandardGuitarTuning', () {
    test('sechs Saiten E2…E4', () {
      final freqs = StandardGuitarTuning().withFrequencies();
      expect(freqs.map((e) => e.string.label).toList(), [
        'E2',
        'A2',
        'D3',
        'G3',
        'H3',
        'E4',
      ]);
      expect(freqs.first.frequencyHz, closeTo(82.41, 0.02));
      expect(freqs.last.frequencyHz, closeTo(329.63, 0.02));
    });
  });
}
