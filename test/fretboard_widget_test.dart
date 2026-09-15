import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genesis/src/chords/beginner_chords.dart';
import 'package:genesis/src/fretboard/fretboard_painter.dart';
import 'package:genesis/src/fretboard/fretboard_view_mode.dart';
import 'package:genesis/src/fretboard/fretboard_widget.dart';

void main() {
  testWidgets('Griffbrett rendert Fingerpositionen und Akkordname', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: FretboardWidget(chord: BeginnerChords.em),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Em'), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);

    final state = tester.state<FretboardWidgetState>(
      find.byType(FretboardWidget),
    );
    expect(state.displayedChord.positions, BeginnerChords.em.positions);
    expect(state.displayedChord.positions, isNotEmpty);
    expect(state.leftHanded, isFalse);
    expect(state.viewMode, FretboardViewMode.chordDiagram);

    expect(find.text('Zeigefinger'), findsOneWidget);
    expect(find.text('Mittelfinger'), findsOneWidget);
    expect(find.text('Diagramm'), findsOneWidget);
    expect(find.text('Griffbrett'), findsOneWidget);
  });

  testWidgets('Ansicht umschalten: Diagramm ↔ Griffbrett', (
    WidgetTester tester,
  ) async {
    final key = GlobalKey<FretboardWidgetState>();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: FretboardWidget(
              key: key,
              chord: BeginnerChords.am,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(key.currentState!.viewMode, FretboardViewMode.chordDiagram);

    await tester.tap(find.text('Griffbrett'));
    await tester.pumpAndSettle();
    expect(key.currentState!.viewMode, FretboardViewMode.horizontal);

    await tester.tap(find.text('Diagramm'));
    await tester.pumpAndSettle();
    expect(key.currentState!.viewMode, FretboardViewMode.chordDiagram);
  });

  testWidgets('Links-/Rechtshänder spiegelt Saitenpositionen', (
    WidgetTester tester,
  ) async {
    final key = GlobalKey<FretboardWidgetState>();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: FretboardWidget(
              key: key,
              chord: BeginnerChords.am,
            ),
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

    expect(y6Right, lessThan(y1Right));
    expect(y6Left, greaterThan(y1Left));
    expect(y6Right, closeTo(y1Left, 0.001));
    expect(y1Right, closeTo(y6Left, 0.001));

    final diagram = ChordDiagramLayout.fromSize(const Size(200, 280), frets: 5);
    final x6Right = diagram.stringX(6, false);
    final x1Right = diagram.stringX(1, false);
    expect(x6Right, lessThan(x1Right));
    expect(diagram.stringX(6, true), greaterThan(diagram.stringX(1, true)));

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
    var chord = BeginnerChords.em;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    FretboardWidget(chord: chord),
                    TextButton(
                      onPressed: () => setState(() {
                        chord = BeginnerChords.am;
                      }),
                      child: const Text('Zu Am'),
                    ),
                  ],
                ),
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

  testWidgets('Barré-Akkord rendert ohne Fehler', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: FretboardWidget(chord: BeginnerChords.fBarre),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('F'), findsOneWidget);
    expect(BeginnerChords.fBarre.barre, isNotNull);
  });
}
