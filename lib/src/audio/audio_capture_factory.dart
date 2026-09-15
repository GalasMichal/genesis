import 'audio_capture.dart';
import 'audio_capture_record.dart' as impl;

/// Factory: `record` inkl. Web (PCM16 via AudioWorklet).
AudioCaptureSource createAudioCapture() => impl.createAudioCapture();
