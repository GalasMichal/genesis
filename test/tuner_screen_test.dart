import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genesis/screens/stimmen_screen.dart';
import 'package:genesis/src/pitch/note_mapper.dart';
import 'package:genesis/src/pitch/pitch_result.dart';
import 'package:genesis/src/tuner/guitar_tuning.dart';
import 'package:genesis/src/tuner/pitch_pipeline.dart';

void main() {
  testWidgets('Tuner zeigt Note und Cent aus Fake-Pitch-Stream', (
    WidgetTester tester,
  ) async {
    final controller = StreamController<TunerReading>.broadcast();
    final mapper = NoteMapper();
    final a2 = StandardGuitarTuning.strings[1];
    final hz = a2.frequencyHz(mapper);
    final note = mapper.fromFrequency(hz);

    await tester.pumpWidget(
      MaterialApp(
        home: StimmenScreen(
          readingStream: controller.stream,
          autoStart: false,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Stimmen'), findsOneWidget);
    expect(find.text('—'), findsWidgets);
    expect(find.textContaining('E A D G H E'), findsOneWidget);

    controller.add(
      TunerReading(
        pitch: PitchResult(frequencyHz: hz, clarity: 0.95),
        note: note,
        nearestString: a2,
        centsToString: 0,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('A2'), findsWidgets);
    expect(find.textContaining('110.0 Hz'), findsOneWidget);
    expect(find.text('Stimmt'), findsOneWidget);

    final sharpHz = hz * math.pow(2, 20 / 1200).toDouble();
    final sharpNote = mapper.fromFrequency(sharpHz);
    controller.add(
      TunerReading(
        pitch: PitchResult(frequencyHz: sharpHz, clarity: 0.9),
        note: DetectedNote(
          noteName: sharpNote.noteName,
          octave: sharpNote.octave,
          cents: 20,
          midiNumber: sharpNote.midiNumber,
          frequencyHz: sharpHz,
          targetFrequencyHz: hz,
        ),
        nearestString: a2,
        centsToString: 20,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Zu hoch'), findsOneWidget);

    await controller.close();
  });

  testWidgets('Tuner ohne Stream zeigt Start-Hinweis auf Deutsch', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: StimmenScreen(autoStart: false),
      ),
    );
    await tester.pump();

    expect(find.textContaining('braucht dein Mikrofon'), findsOneWidget);
    expect(find.text('Mikrofon starten'), findsOneWidget);
  });
}
