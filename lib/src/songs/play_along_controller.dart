import 'package:flutter/foundation.dart';

import 'song.dart';

/// Steuert Play-Along: Beat-Position, Tempo 50–100 %, Loop-Abschnitt.
///
/// Unabhängig von Flutter-Widgets testbar; UI pollt [tick] oder nutzt
/// [Listenable] über [ChangeNotifier].
class PlayAlongController extends ChangeNotifier {
  PlayAlongController(this.song, {double initialTempoPercent = 100})
      : _tempoPercent = initialTempoPercent.clamp(50, 100);

  final Song song;

  double _tempoPercent;
  double _beat = 0;
  bool _playing = false;
  SongSection? _loopSection;
  DateTime? _lastTick;

  double get tempoPercent => _tempoPercent;
  double get beat => _beat;
  bool get isPlaying => _playing;
  SongSection? get loopSection => _loopSection;

  /// Effektives BPM nach Tempo-Regler.
  double get effectiveBpm => song.bpm * (_tempoPercent / 100.0);

  double get loopStart => _loopSection?.startBeat ?? 0;
  double get loopEnd => _loopSection?.endBeat ?? song.durationBeats;

  int get currentEventIndex => song.eventIndexAtBeat(_beat);

  SongEvent? get currentEvent {
    final i = currentEventIndex;
    if (i < 0 || i >= song.events.length) return null;
    return song.events[i];
  }

  String? get currentChordId => currentEvent?.chordId;

  /// Fortschritt 0–1 innerhalb des aktuellen Loop-Bereichs.
  double get progressInLoop {
    final span = loopEnd - loopStart;
    if (span <= 0) return 0;
    return ((_beat - loopStart) / span).clamp(0.0, 1.0);
  }

  void setTempoPercent(double percent) {
    _tempoPercent = percent.clamp(50, 100);
    notifyListeners();
  }

  void setLoopSection(SongSection? section) {
    _loopSection = section;
    if (section != null && (_beat < section.startBeat || _beat >= section.endBeat)) {
      _beat = section.startBeat;
    }
    notifyListeners();
  }

  void seek(double beat) {
    final start = loopStart;
    final end = loopEnd;
    _beat = beat.clamp(start, end > start ? end - 0.0001 : start);
    notifyListeners();
  }

  void play() {
    if (_playing) return;
    _playing = true;
    _lastTick = null;
    notifyListeners();
  }

  void pause() {
    if (!_playing) return;
    _playing = false;
    _lastTick = null;
    notifyListeners();
  }

  void togglePlay() {
    if (_playing) {
      pause();
    } else {
      play();
    }
  }

  void stop() {
    _playing = false;
    _lastTick = null;
    _beat = loopStart;
    notifyListeners();
  }

  /// Fortschritt um [elapsed] (echte Wandzeit). Idempotent bei Pause.
  void tick(Duration elapsed) {
    if (!_playing) {
      _lastTick = null;
      return;
    }
    final seconds = elapsed.inMicroseconds / 1e6;
    if (seconds <= 0) return;

    final beatsPerSecond = effectiveBpm / 60.0;
    var next = _beat + seconds * beatsPerSecond;

    if (next >= loopEnd) {
      // Loop zurück zum Anfang des Abschnitts
      final span = loopEnd - loopStart;
      if (span <= 0) {
        next = loopStart;
        _playing = false;
      } else {
        next = loopStart + ((next - loopStart) % span);
      }
    }

    _beat = next;
    notifyListeners();
  }

  /// Convenience: tick mit Delta seit letztem Aufruf (Wall-Clock).
  void tickNow() {
    final now = DateTime.now();
    if (_lastTick == null) {
      _lastTick = now;
      return;
    }
    final delta = now.difference(_lastTick!);
    _lastTick = now;
    tick(delta);
  }
}
