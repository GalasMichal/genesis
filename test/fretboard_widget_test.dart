import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genesis/src/chords/beginner_chords.dart';
import 'package:genesis/src/fretboard/fretboard_painter.dart';
import 'package:genesis/src/fretboard/fretboard_widget.dart';

void main() {
  testWidgets('Griffbrett rendert Fingerpositionen und Akkordname', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FretboardWidget(chord: BeginnerChords.em),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Em'), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);

    final state = tester.state<FretboardWidgetState>(find.byType(FretboardWidget));
    expect(state.displayedChord.positions, BeginnerChords.em.positions);
    expect(state.displayedChord.positions, isNotEmpty);
    expect(state.leftHanded, isFalse);

    // Finger-Nummern in der Legende
    expect(find.text('Zeigefinger'), findsOneWidget);
    expect(find.text('Mittelfinger'), findsOneWidget);
  });

  testWidgets('Links-/Rechtshänder spiegelt Saitenpositionen', (
    WidgetTester tester,
  ) async {
    final key = GlobalKey<FretboardWidgetState>();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FretboardWidget(
            key: key,
            chord: BeginnerChords.am,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final layout = FretboardLayout.fromSize(const Size(400, 200), frets: 5);
    final y6Right = layout.stringY(6, false);
    final y1Right = layout.stringY(1, false);
    final y6Left = layout.stringY(6, true);
    final y1Left = layout.stringY(1, true);

    // Rechtshänder: tiefe E (6) oben, hohe e (1) unten
    expect(y6Right, lessThan(y1Right));
    // Linkshänder: gespiegelt
    expect(y6Left, greaterThan(y1Left));
    expect(y6Right, closeTo(y1Left, 0.001));
    expect(y1Right, closeTo(y6Left, 0.001));

    expect(key.currentState!.leftHanded, isFalse);
    await tester.tap(find.text('Links'));
    await tester.pumpAndSettle();
    expect(key.currentState!.leftHanded, isTrue);

    await tester.tap(find.text('Rechts'));
    await tester.pumpAndSettle();
    expect(key.currentState!.leftHanded, isFalse);
  });

  testWidgets('Griffwechsel aktualisiert angezeigten Akkord', (
    WidgetTester tester,
  ) async {
    ChordShapeHolder holder = ChordShapeHolder(BeginnerChords.em);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                children: [
                  FretboardWidget(chord: holder.chord),
                  TextButton(
                    onPressed: () => setState(() {
                      holder = ChordShapeHolder(BeginnerChords.am);
                    }),
                    child: const Text('Zu Am'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Em'), findsOneWidget);

    await tester.tap(find.text('Zu Am'));
    await tester.pumpAndSettle();
    expect(find.text('Am'), findsOneWidget);
  });
}

class ChordShapeHolder {
  ChordShapeHolder(this.chord);
  final dynamic chord;
}
