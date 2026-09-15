import 'dart:typed_data';

/// Roh-PCM-Chunk vom Mikrofon (16-bit little-endian Mono).
class PcmChunk {
  const PcmChunk({
    required this.bytes,
    required this.sampleRate,
  });

  final Uint8List bytes;
  final int sampleRate;

  int get sampleCount => bytes.length ~/ 2;
}

enum AudioCaptureAvailability {
  /// Capture kann gestartet werden (nach Permission).
  available,

  /// Plattform unterstützt kein Live-Capture (z. B. Web-Stub).
  unsupported,

  /// Berechtigung fehlt / abgelehnt.
  permissionDenied,
}

/// Austauschbare Capture-Quelle für die Pitch-Pipeline.
abstract class AudioCaptureSource {
  /// Ob Live-Mikrofon auf dieser Plattform vorgesehen ist.
  bool get isSupported;

  /// Kurzer Hinweis wenn [isSupported] == false (DE).
  String get unsupportedMessage;

  /// Prüft / fragt Mikrofon-Berechtigung an.
  Future<bool> ensurePermission();

  /// Öffnet System-Einstellungen der App (falls möglich).
  Future<void> openSystemSettings();

  /// Startet PCM16-Stream. Voice-Processing muss abgeschaltet sein.
  Stream<PcmChunk> start({
    int sampleRate = 44100,
    int bufferSize = 2048,
  });

  Future<void> stop();

  Future<void> dispose();
}
