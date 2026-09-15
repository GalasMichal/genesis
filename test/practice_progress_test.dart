import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:genesis/src/practice/practice_progress.dart';
import 'package:genesis/src/practice/practice_sets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('speichert Abschluss und besten Schritt', () async {
    final store = PracticeProgressStore();
    final id = BeginnerPracticeSets.emUebung.id;

    expect(await store.isCompleted(id), isFalse);
    expect(await store.bestStep(id), 0);

    await store.recordStep(id, 2);
    expect(await store.bestStep(id), 2);

    await store.recordStep(id, 1); // niedriger — nicht überschreiben
    expect(await store.bestStep(id), 2);

    await store.markSetFinished(id, 5);
    expect(await store.isCompleted(id), isTrue);
    expect(await store.bestStep(id), 5);
  });

  test('progressFraction über alle Sets', () async {
    final store = PracticeProgressStore();
    final ids = BeginnerPracticeSets.all.map((s) => s.id).toList();

    expect(await store.progressFraction(ids), 0);

    await store.setCompleted(ids[0], completed: true);
    expect(await store.progressFraction(ids), closeTo(1 / ids.length, 1e-9));
  });

  test('akzeptiert injizierte Prefs', () async {
    SharedPreferences.setMockInitialValues({
      'practice_set_done_demo': true,
      'practice_set_best_demo': 3,
    });
    final prefs = await SharedPreferences.getInstance();
    final store = PracticeProgressStore(prefs: prefs);

    expect(await store.isCompleted('demo'), isTrue);
    expect(await store.bestStep('demo'), 3);
  });
}
