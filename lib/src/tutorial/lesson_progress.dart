import 'package:shared_preferences/shared_preferences.dart';

/// Lokaler Fortschritt für den Tutorial-Pfad.
class LessonProgressStore {
  LessonProgressStore({this._prefs});

  static const _keyPrefix = 'lesson_done_';

  SharedPreferences? _prefs;

  Future<SharedPreferences> _ensurePrefs() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  String _key(String lessonId) => '$_keyPrefix$lessonId';

  Future<bool> isCompleted(String lessonId) async {
    final prefs = await _ensurePrefs();
    return prefs.getBool(_key(lessonId)) ?? false;
  }

  Future<void> setCompleted(String lessonId, {required bool completed}) async {
    final prefs = await _ensurePrefs();
    await prefs.setBool(_key(lessonId), completed);
  }

  Future<Set<String>> completedIds(Iterable<String> lessonIds) async {
    final prefs = await _ensurePrefs();
    return {
      for (final id in lessonIds)
        if (prefs.getBool(_key(id)) ?? false) id,
    };
  }

  Future<double> progressFraction(List<String> lessonIds) async {
    if (lessonIds.isEmpty) return 0;
    final done = await completedIds(lessonIds);
    return done.length / lessonIds.length;
  }
}
