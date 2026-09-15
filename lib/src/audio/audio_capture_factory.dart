import 'audio_capture.dart';
import 'audio_capture_stub.dart'
    if (dart.library.io) 'audio_capture_record.dart' as impl;

/// Factory: auf IO (Android/iOS/Desktop) → record-Package,
/// auf Web → Stub mit freundlichem Hinweis.
AudioCaptureSource createAudioCapture() => impl.createAudioCapture();
