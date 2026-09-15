import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:genesis/app.dart';
import 'package:genesis/screens/lernen_screen.dart';
import 'package:genesis/screens/lesson_detail_screen.dart';
import 'package:genesis/src/tutorial/lesson_progress.dart';
import 'package:genesis/src/tutorial/lessons.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> setTallSurface(WidgetTester tester) async {
    final view = tester.view;
    view.physicalSize = const Size(900, 2000);
    view.devicePixelRatio = 1.0;
    addTearDown(view.resetPhysicalSize);
    addTearDown(view.resetDevicePixelRatio);
  }

  testWidgets('Lernen-Screen listet Lektionen mit Fortschritt', (
    WidgetTester tester,
  ) async {
    await setTallSurface(tester);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final progress = LessonProgressStore(prefs: prefs);

    await tester.pumpWidget(
      MaterialApp(
        home: LernenScreen(progress: progress),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Anfänger-Pfad'), findsOneWidget);
    expect(
      find.text('0 von ${BeginnerLessons.all.length} Lektionen'),
      findsOneWidget,
    );
    expect(find.text('Em'), findsWidgets);
    expect(find.text(BeginnerLessons.all.first.title), findsOneWidget);
    expect(find.text(BeginnerLessons.all.last.title), findsOneWidget);
  });

  testWidgets('Lektions-Navigation öffnet Detail und speichert Fortschritt', (
    WidgetTester tester,
  ) async {
    await setTallSurface(tester);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final progress = LessonProgressStore(prefs: prefs);
    final lesson = BeginnerLessons.all.first;

    await tester.pumpWidget(
      MaterialApp(
        home: LernenScreen(progress: progress),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text(lesson.title));
    await tester.pumpAndSettle();
    await tester.tap(find.text(lesson.title));
    await tester.pumpAndSettle();

    expect(find.byType(LessonDetailScreen), findsOneWidget);
    expect(find.text('Schritte'), findsOneWidget);

    await tester.ensureVisible(find.text('Lektion abhaken'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lektion abhaken'));
    await tester.pumpAndSettle();
    expect(await progress.isCompleted(lesson.id), isTrue);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(
      find.text('1 von ${BeginnerLessons.all.length} Lektionen'),
      findsOneWidget,
    );
  });

  testWidgets('App-Shell: Lernen zeigt Pfad, Wechsel zu Stimmen', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const GenesisApp());
    await tester.pumpAndSettle();

    expect(find.text('Lernen'), findsWidgets);
    expect(find.text('Anfänger-Pfad'), findsOneWidget);

    await tester.tap(find.text('Stimmen').last);
    await tester.pumpAndSettle();

    expect(find.text('Stimmen'), findsWidgets);
    expect(find.textContaining('Standard-Stimmung'), findsOneWidget);
    expect(find.text('Mikrofon starten'), findsOneWidget);
  });
}
