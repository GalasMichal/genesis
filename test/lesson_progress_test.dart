import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:genesis/src/tutorial/lesson_progress.dart';
import 'package:genesis/src/tutorial/lessons.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('Fortschritt speichert und lädt Lektions-Status', () async {
    final store = LessonProgressStore();
    final id = BeginnerLessons.all.first.id;

    expect(await store.isCompleted(id), isFalse);

    await store.setCompleted(id, completed: true);
    expect(await store.isCompleted(id), isTrue);

    await store.setCompleted(id, completed: false);
    expect(await store.isCompleted(id), isFalse);
  });

  test('progressFraction und completedIds', () async {
    final store = LessonProgressStore();
    final ids = BeginnerLessons.all.map((l) => l.id).toList();

    expect(await store.progressFraction(ids), 0);

    await store.setCompleted(ids[0], completed: true);
    await store.setCompleted(ids[1], completed: true);

    final done = await store.completedIds(ids);
    expect(done, containsAll([ids[0], ids[1]]));
    expect(done.length, 2);
    expect(await store.progressFraction(ids), closeTo(2 / ids.length, 1e-9));
  });

  test('LessonProgressStore akzeptiert injizierte Prefs (Mock)', () async {
    SharedPreferences.setMockInitialValues({
      'lesson_done_demo': true,
    });
    final prefs = await SharedPreferences.getInstance();
    final store = LessonProgressStore(prefs: prefs);

    expect(await store.isCompleted('demo'), isTrue);
    expect(await store.isCompleted('other'), isFalse);
  });
}
