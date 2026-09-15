import 'package:shared_preferences/shared_preferences.dart';

/// Lokaler Fortschritt: welche Songs schon gespielt wurden (Play-Along).
class SongProgressStore {
  SongProgressStore({this._prefs});

  static const _playedPrefix = 'song_played_';

  SharedPreferences? _prefs;

  Future<SharedPreferences> _ensurePrefs() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  Future<bool> isPlayed(String songId) async {
    final prefs = await _ensurePrefs();
    return prefs.getBool('$_playedPrefix$songId') ?? false;
  }

  Future<void> markPlayed(String songId) async {
    final prefs = await _ensurePrefs();
    await prefs.setBool('$_playedPrefix$songId', true);
  }

  Future<Set<String>> playedIds(Iterable<String> songIds) async {
    final prefs = await _ensurePrefs();
    return {
      for (final id in songIds)
        if (prefs.getBool('$_playedPrefix$id') ?? false) id,
    };
  }

  Future<int> playedCount(Iterable<String> songIds) async {
    final ids = await playedIds(songIds);
    return ids.length;
  }
}
