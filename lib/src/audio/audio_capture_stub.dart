import 'dart:async';

import 'audio_capture.dart';

/// Web- / Fallback-Capture: kompiliert überall, liefert keinen Stream.
class StubAudioCapture implements AudioCaptureSource {
  @override
  bool get isSupported => false;

  @override
  String get unsupportedMessage =>
      'Live-Mikrofon ist in dieser Umgebung nicht verfügbar. '
      'Bitte die App auf einem Smartphone oder Tablet nutzen — '
      'der Tuner braucht Zugriff auf das Mikrofon.';

  @override
  Future<bool> ensurePermission() async => false;

  @override
  Future<void> openSystemSettings() async {}

  @override
  Stream<PcmChunk> start({int sampleRate = 44100, int bufferSize = 2048}) {
    return const Stream<PcmChunk>.empty();
  }

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {}
}

AudioCaptureSource createAudioCapture() => StubAudioCapture();
