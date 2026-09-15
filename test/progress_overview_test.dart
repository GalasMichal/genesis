import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genesis/screens/lernen_screen.dart';
import 'package:genesis/src/practice/practice_progress.dart';
import 'package:genesis/src/songs/song_progress.dart';
import 'package:genesis/src/tutorial/lesson_progress.dart';
import 'package:genesis/src/tutorial/lessons.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'lesson_done_kennenlernen': true,
      'lesson_done_halten': true,
      'practice_set_done_em-uebung': true,
      'practice_set_best_saiten-kennenlernen': 2,
      'song_played_em-am-takt': true,
    });
  });

  testWidgets('Lernen zeigt Fortschritts-Karte mit Lektionen, Übungen, Songs', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LernenScreen(
          progress: LessonProgressStore(),
          practiceProgress: PracticeProgressStore(),
          songProgress: SongProgressStore(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Dein Fortschritt'), findsOneWidget);
    expect(
      find.textContaining('2/${BeginnerLessons.all.length} abgeschlossen'),
      findsOneWidget,
    );
    expect(find.textContaining('2/7 mit Fortschritt'), findsOneWidget);
    expect(find.textContaining('gespielt'), findsOneWidget);
  });
}
