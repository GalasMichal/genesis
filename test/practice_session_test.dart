import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:genesis/screens/practice_session_screen.dart';
import 'package:genesis/screens/ueben_screen.dart';
import 'package:genesis/src/pitch/note_mapper.dart';
import 'package:genesis/src/pitch/pitch_result.dart';
import 'package:genesis/src/practice/practice_progress.dart';
import 'package:genesis/src/practice/practice_sets.dart';
import 'package:genesis/src/tuner/pitch_pipeline.dart';

TunerReading _readingForMidi(NoteMapper mapper, int midi) {
  final hz = mapper.frequencyForMidi(midi);
  final note = mapper.fromFrequency(hz);
  return TunerReading(
    pitch: PitchResult(frequencyHz: hz, clarity: 0.95),
    note: note,
    nearestString: null,
    centsToString: 0,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Üben-Übersicht listet Sets auf Deutsch', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: UebenScreen(progress: PracticeProgressStore()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Üben'), findsOneWidget);
    expect(find.text('Mic-Check'), findsOneWidget);
    expect(find.text('Saiten-Kennenlernen'), findsOneWidget);
    expect(find.text('Em-Übung'), findsOneWidget);

    await tester.drag(find.byType(Scrollable), const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(find.textContaining('Griffwechsel'), findsOneWidget);
    expect(find.text('D-Übung'), findsOneWidget);
  });

  testWidgets('Session: Fake-Pitch trifft leere Saite und zeigt Grün', (
    tester,
  ) async {
    final controller = StreamController<TunerReading>.broadcast();
    addTearDown(controller.close);
    final mapper = NoteMapper();
    final set = BeginnerPracticeSets.saitenKennenlernen;
    final store = PracticeProgressStore();

    await tester.pumpWidget(
      MaterialApp(
        home: PracticeSessionScreen(
          practiceSet: set,
          progress: store,
          readingStream: controller.stream,
          advanceDelay: Duration.zero,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Saiten-Kennenlernen'), findsOneWidget);
    expect(find.textContaining('leere Saite'), findsOneWidget);
    expect(find.text('Warte auf Ton…'), findsOneWidget);

    controller.add(_readingForMidi(mapper, 40)); // E2
    await tester.pump();
    await tester.pump(Duration.zero);
    await tester.pumpAndSettle();

    expect(find.text('2 / 6'), findsOneWidget);
  });

  testWidgets('Session: falsche Note zeigt Erkannt-Hinweis', (tester) async {
    final controller = StreamController<TunerReading>.broadcast();
    addTearDown(controller.close);
    final mapper = NoteMapper();
    final set = BeginnerPracticeSets.saitenKennenlernen;
    final store = PracticeProgressStore();

    await tester.pumpWidget(
      MaterialApp(
        home: PracticeSessionScreen(
          practiceSet: set,
          progress: store,
          readingStream: controller.stream,
        ),
      ),
    );
    await tester.pump();

    controller.add(_readingForMidi(mapper, 45)); // A2 statt E2
    await tester.pumpAndSettle();

    expect(find.textContaining('Erkannt: A2'), findsWidgets);
    expect(find.textContaining('Zu hoch'), findsOneWidget);
    expect(find.text('1 / 6'), findsOneWidget);
  });

  testWidgets('Session ohne Stream zeigt Mikrofon-Start', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PracticeSessionScreen(
          practiceSet: BeginnerPracticeSets.emUebung,
          progress: PracticeProgressStore(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Mikrofon starten'), findsOneWidget);
    expect(find.text('Em-Übung'), findsOneWidget);
  });
}
