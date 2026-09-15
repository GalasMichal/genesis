import 'package:shared_preferences/shared_preferences.dart';

/// Lokaler Fortschritt für Übungs-Sets (shared_preferences, analog Tutorial).
class PracticeProgressStore {
  PracticeProgressStore({this._prefs});

  static const _completedPrefix = 'practice_set_done_';
  static const _bestPrefix = 'practice_set_best_';

  SharedPreferences? _prefs;

  Future<SharedPreferences> _ensurePrefs() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  Future<bool> isCompleted(String setId) async {
    final prefs = await _ensurePrefs();
    return prefs.getBool('$_completedPrefix$setId') ?? false;
  }

  Future<void> setCompleted(String setId, {required bool completed}) async {
    final prefs = await _ensurePrefs();
    await prefs.setBool('$_completedPrefix$setId', completed);
  }

  /// Bester erreichter Schritt-Index (0-basiert, exklusiv = Anzahl geschafft).
  Future<int> bestStep(String setId) async {
    final prefs = await _ensurePrefs();
    return prefs.getInt('$_bestPrefix$setId') ?? 0;
  }

  Future<void> recordStep(String setId, int stepsCompleted) async {
    final prefs = await _ensurePrefs();
    final prev = prefs.getInt('$_bestPrefix$setId') ?? 0;
    if (stepsCompleted > prev) {
      await prefs.setInt('$_bestPrefix$setId', stepsCompleted);
    }
  }

  Future<void> markSetFinished(String setId, int totalSteps) async {
    await recordStep(setId, totalSteps);
    await setCompleted(setId, completed: true);
  }

  Future<Set<String>> completedIds(Iterable<String> setIds) async {
    final prefs = await _ensurePrefs();
    return {
      for (final id in setIds)
        if (prefs.getBool('$_completedPrefix$id') ?? false) id,
    };
  }

  Future<double> progressFraction(List<String> setIds) async {
    if (setIds.isEmpty) return 0;
    final done = await completedIds(setIds);
    return done.length / setIds.length;
  }
}
