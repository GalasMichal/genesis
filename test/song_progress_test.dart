import 'package:flutter_test/flutter_test.dart';
import 'package:genesis/src/songs/song_progress.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('SongProgressStore markiert und zählt gespielte Songs', () async {
    final store = SongProgressStore();
    expect(await store.isPlayed('a'), isFalse);

    await store.markPlayed('a');
    await store.markPlayed('b');

    expect(await store.isPlayed('a'), isTrue);
    expect(await store.playedCount(['a', 'b', 'c']), 2);
    expect(await store.playedIds(['a', 'c', 'x']), {'a'});
  });
}
