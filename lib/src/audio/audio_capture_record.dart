import 'dart:async';
import 'dart:typed_data';

import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

import 'audio_capture.dart';

/// Capture über das Package `record` (BSD):
/// PCM16-Stream, autoGain/echoCancel/noiseSuppress = false.
class RecordAudioCapture implements AudioCaptureSource {
  RecordAudioCapture({AudioRecorder? recorder})
    : _recorder = recorder ?? AudioRecorder();

  final AudioRecorder _recorder;
  StreamSubscription<Uint8List>? _sub;
  StreamController<PcmChunk>? _controller;
  final BytesBuilder _pending = BytesBuilder(copy: false);
  int _sampleRate = 44100;
  int _bufferBytes = 2048 * 2;

  @override
  bool get isSupported => true;

  @override
  String get unsupportedMessage => '';

  @override
  Future<bool> ensurePermission() async {
    // record hat eigene Permission-API; permission_handler für Settings-Pfad.
    final mic = await Permission.microphone.request();
    if (mic.isGranted) return true;
    // Fallback: record-eigene Prüfung (manche Desktop-Targets)
    try {
      return await _recorder.hasPermission();
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> openSystemSettings() async {
    await openAppSettings();
  }

  @override
  Stream<PcmChunk> start({int sampleRate = 44100, int bufferSize = 2048}) {
    _sampleRate = sampleRate;
    _bufferBytes = bufferSize * 2;
    _pending.clear();

    final controller = StreamController<PcmChunk>.broadcast(
      onListen: () {},
      onCancel: () async {
        if (!(_controller?.hasListener ?? true)) {
          await stop();
        }
      },
    );
    _controller = controller;

    () async {
      try {
        final stream = await _recorder.startStream(
          RecordConfig(
            encoder: AudioEncoder.pcm16bits,
            sampleRate: sampleRate,
            numChannels: 1,
            autoGain: false,
            echoCancel: false,
            noiseSuppress: false,
          ),
        );
        _sub = stream.listen(
          _onBytes,
          onError: controller.addError,
          onDone: () {
            if (!controller.isClosed) controller.close();
          },
        );
      } catch (e, st) {
        if (!controller.isClosed) {
          controller.addError(e, st);
          await controller.close();
        }
      }
    }();

    return controller.stream;
  }

  void _onBytes(Uint8List chunk) {
    final controller = _controller;
    if (controller == null || controller.isClosed) return;
    _pending.add(chunk);
    var data = _pending.takeBytes();
    while (data.length >= _bufferBytes) {
      final frame = Uint8List.fromList(data.sublist(0, _bufferBytes));
      controller.add(PcmChunk(bytes: frame, sampleRate: _sampleRate));
      data = data.sublist(_bufferBytes);
    }
    if (data.isNotEmpty) {
      _pending.add(data);
    }
  }

  @override
  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
    try {
      if (await _recorder.isRecording()) {
        await _recorder.stop();
      }
    } catch (_) {
      // ignore
    }
    _pending.clear();
    final c = _controller;
    _controller = null;
    if (c != null && !c.isClosed) {
      await c.close();
    }
  }

  @override
  Future<void> dispose() async {
    await stop();
    await _recorder.dispose();
  }
}

AudioCaptureSource createAudioCapture() => RecordAudioCapture();
