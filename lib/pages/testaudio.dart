import 'dart:async';
import 'dart:convert';
import 'dart:io' show File, Platform;
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_audio_capture/flutter_audio_capture.dart';

class GeminiLiveDuplexPage extends StatefulWidget {
  const GeminiLiveDuplexPage({super.key});
  @override
  State<GeminiLiveDuplexPage> createState() => _GeminiLiveDuplexPageState();
}

class _GeminiLiveDuplexPageState extends State<GeminiLiveDuplexPage> {
  // ===== Audio spec (server must match) =====
  static const int sampleRate = 24000;
  static const int numChannels = 1;
  static const int bitsPerSample = 16;

  // Reduce stutter by batching PCM before playback
  static const Duration prebuffer = Duration(milliseconds: 650);

  // ===== UI =====
  final _wsUrlCtrl = TextEditingController(text: 'ws://18.224.8.111:3000');
  final _textCtrl = TextEditingController();
  final _log = <_LogLine>[];
  final _scroll = ScrollController();

  // ===== WebSocket =====
  WebSocketChannel? _ws;
  StreamSubscription? _wsSub;
  bool _connected = false;

  // ===== Playback =====
  final AudioPlayer _player = AudioPlayer();
  final ConcatenatingAudioSource _playlist = ConcatenatingAudioSource(
    children: [],
  );
  bool _playlistAttached = false;

  // Accumulate PCM then wrap to WAV
  final BytesBuilder _pcmAccumulator = BytesBuilder();
  int _targetChunkBytes = 0;
  Timer? _flushTimer;

  // ===== Microphone (uplink) + VAD =====
  final FlutterAudioCapture _audioCapture = FlutterAudioCapture();
  bool _micOn = false;
  bool _speaking = false;
  int _silenceFrames = 0;

  static const double _rmsStartThreshold = 0.018;
  static const double _rmsStopThreshold = 0.012;
  static const int _hangoverFrames = 8;
  final BytesBuilder _micAccumulator = BytesBuilder();
  static const int _micPacketMs = 40;

  @override
  void initState() {
    super.initState();
    //Prebuffer
    final bytesPerMs = sampleRate * numChannels * (bitsPerSample ~/ 8) / 1000.0;
    _targetChunkBytes = max(1, (bytesPerMs * prebuffer.inMilliseconds).round());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _logLine('Ready.');
    });
  }

  @override
  void dispose() {
    _stopMic();
    _wsSub?.cancel();
    _ws?.sink.close();
    _player.dispose();
    _textCtrl.dispose();
    _wsUrlCtrl.dispose();
    _scroll.dispose();
    _flushTimer?.cancel();
    super.dispose();
  }

  // ===== Logging =====
  void _logLine(String text, [_LogType t = _LogType.system]) {
    final now = DateTime.now();
    final ts =
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}';
    setState(() => _log.add(_LogLine('[$ts] $text', t)));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Color _logColor(_LogType t) {
    switch (t) {
      case _LogType.user:
        return Colors.blue;
      case _LogType.ai:
        return Colors.green;
      case _LogType.audio:
        return Colors.orange;
      case _LogType.system:
      default:
        return Colors.grey;
    }
  }

  // ===== WAV utils =====
  Uint8List _wrapPcmAsWav(Uint8List pcm) {
    final headerLen = 44;
    final fileLen = headerLen + pcm.length;
    final header = ByteData(headerLen);

    void writeString(int offset, String s) {
      for (int i = 0; i < s.length; i++) {
        header.setUint8(offset + i, s.codeUnitAt(i));
      }
    }

    writeString(0, 'RIFF');
    header.setUint32(4, fileLen - 8, Endian.little);
    writeString(8, 'WAVE');
    writeString(12, 'fmt ');
    header.setUint32(16, 16, Endian.little); // PCM fmt chunk
    header.setUint16(20, 1, Endian.little); // AudioFormat = 1 (PCM)
    header.setUint16(22, numChannels, Endian.little);
    header.setUint32(24, sampleRate, Endian.little);
    final byteRate = (sampleRate * numChannels * (bitsPerSample ~/ 8));
    header.setUint32(28, byteRate, Endian.little);
    final blockAlign = (numChannels * (bitsPerSample ~/ 8));
    header.setUint16(32, blockAlign, Endian.little);
    header.setUint16(34, bitsPerSample, Endian.little);
    writeString(36, 'data');
    header.setUint32(40, pcm.length, Endian.little);

    final bb = BytesBuilder();
    bb.add(header.buffer.asUint8List());
    bb.add(pcm);
    return bb.toBytes();
  }

  Future<Uri> _wavToPlayableUri(Uint8List wav) async {
    if (kIsWeb) {
      return Uri.dataFromBytes(wav, mimeType: 'audio/wav');
    } else {
      final dir = await getTemporaryDirectory();
      final f = File(
        '${dir.path}/chunk_${DateTime.now().microsecondsSinceEpoch}.wav',
      );
      await f.writeAsBytes(wav, flush: true);
      return Uri.file(f.path);
    }
  }

  Future<void> _enqueueWav(Uint8List wavBytes) async {
    final uri = await _wavToPlayableUri(wavBytes);
    final src = AudioSource.uri(uri);
    await _playlist.add(src);

    if (!_playlistAttached) {
      await _player.setAudioSource(_playlist);
      _playlistAttached = true;
      if (!_player.playing) {
        await _player.play();
      }
    }
  }

  // ===== WebSocket =====
  Future<void> _connect() async {
    try {
      _disconnect();
      final url = _wsUrlCtrl.text.trim();
      _ws = WebSocketChannel.connect(Uri.parse(url));
      _connected = true;
      setState(() {});
      _logLine('Connected: $url');

      _wsSub = _ws!.stream.listen(
        (event) {
          if (event is String) {
            _logLine('[AI] $event', _LogType.ai);
            return;
          }

          final bytes = event is Uint8List
              ? event
              : Uint8List.fromList(event as List<int>);

          if (_maybeUtf8Text(bytes)) {
            final txt = utf8.decode(bytes).trim();
            if (txt.isNotEmpty) {
              _logLine('[AI] $txt', _LogType.ai);
              return;
            }
          }

          // PCM audio -> accumulate -> WAV -> enqueue
          _pcmAccumulator.add(bytes);
          if (_pcmAccumulator.length >= _targetChunkBytes) {
            final chunk = _pcmAccumulator.toBytes();
            _pcmAccumulator.clear();
            final wav = _wrapPcmAsWav(chunk);
            // ignore: unawaited_futures
            _enqueueWav(wav);
          }
          _scheduleFlush();
        },
        onDone: () {
          _logLine(
            'WS closed (code=${_ws?.closeCode}, reason=${_ws?.closeReason})',
          );
          _connected = false;
          setState(() {});
        },
        onError: (e) {
          _logLine('WS error: $e');
          _connected = false;
          setState(() {});
        },
      );
    } catch (e) {
      _logLine('Connect failed: $e');
      _connected = false;
      setState(() {});
    }
  }

  bool _maybeUtf8Text(Uint8List bytes) {
    if (bytes.isEmpty || bytes.length > 512) return false;
    try {
      final s = utf8.decode(bytes, allowMalformed: false);
      if (s.trim().isEmpty) return false;

      int printable = 0;
      for (final cp in s.runes) {
        if (cp == 0) return false;
        if (cp >= 0x20 || cp == 0x0A || cp == 0x0D || cp == 0x09) printable++;
      }
      return printable / s.runes.length > 0.95;
    } catch (_) {
      return false;
    }
  }

  void _disconnect() {
    _wsSub?.cancel();
    _wsSub = null;
    _ws?.sink.close(1000, 'Client disconnect');
    _ws = null;
    _connected = false;
    setState(() {});
    _resetPlayback();
  }

  void _resetPlayback() {
    _pcmAccumulator.clear();
    _flushTimer?.cancel();
    _playlist.clear();
    _playlistAttached = false;
    _player.stop();
  }

  void _sendText() {
    final t = _textCtrl.text.trim();
    if (t.isEmpty || _ws == null) return;
    _ws!.sink.add(t);
    _logLine('[USER] $t', _LogType.user);
    _textCtrl.clear();
  }

  void _scheduleFlush() {
    _flushTimer?.cancel();
    _flushTimer = Timer(const Duration(milliseconds: 220), () {
      if (_pcmAccumulator.length > 0) {
        final chunk = _pcmAccumulator.toBytes();
        _pcmAccumulator.clear();
        final wav = _wrapPcmAsWav(chunk);
        // ignore: unawaited_futures
        _enqueueWav(wav);
      }
    });
  }

  // ===== Microphone (uplink) with VAD & half-duplex =====
  Future<void> _startMic() async {
    if (_micOn) return;

    if (kIsWeb) {
      _logLine(
        'Mic on web via flutter_audio_capture غير مدعوم رسميًا (ممكن نعمل WebAudio).',
      );
      return;
    }

    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      _logLine('Mic permission denied');
      return;
    }

    try {
      await _audioCapture.init();
      await Future.delayed(const Duration(milliseconds: 80));

      if (_player.playing) {
        await _player.pause();
      }

      _speaking = false;
      _silenceFrames = 0;
      _micAccumulator.clear();

      await _audioCapture.start(
        _micListener,
        _micError,
        sampleRate: sampleRate,
        bufferSize: 2048,
      );

      setState(() => _micOn = true);
      _logLine('Mic started (24kHz / 16-bit mono).');
    } catch (e) {
      _logLine('Mic start failed: $e');
    }
  }

  Future<void> _stopMic() async {
    if (!_micOn) return;
    try {
      await _audioCapture.stop();
    } catch (_) {}
    setState(() => _micOn = false);
    _logLine('Mic stopped.');

    if (_playlist.length > 0 && !_player.playing) {
      // small delay to let server start TTS
      await Future.delayed(const Duration(milliseconds: 80));
      await _player.play();
    }
  }

  void _micListener(dynamic obj) {
    if (_ws == null) return;

    // Expected Float32List/Float64List
    late final Float32List floatData;
    if (obj is Float32List) {
      floatData = obj;
    } else if (obj is Float64List) {
      floatData = Float32List.fromList(
        obj.map((e) => e.toDouble()).toList().cast<double>(),
      );
    } else {
      return;
    }

    //  RMS
    double sum = 0;
    for (var v in floatData) {
      sum += v * v;
    }
    final rms = sqrt(sum / floatData.length);

    //Start/stop sending
    if (!_speaking) {
      if (rms >= _rmsStartThreshold) {
        _speaking = true;
        _silenceFrames = 0;
        _logLine('VAD: start speaking (rms=${rms.toStringAsFixed(3)})');
      } else {
        // dont send anything
        return;
      }
    } else {
      // speaking
      if (rms < _rmsStopThreshold) {
        _silenceFrames++;
        if (_silenceFrames >= _hangoverFrames) {
          _speaking = false;
          _silenceFrames = 0;
          _logLine('VAD: stop speaking');
          // End recording automatically (one sentence) — an excellent option to prevent multiple triggers
          _stopMic();
          return;
        }
      } else {
        _silenceFrames = 0;
      }
    }

    // Convert float [-1,1] -> Int16 PCM LE
    final pcm = _float32ToInt16LE(floatData);

    _micAccumulator.add(pcm);
    final bytesPerMs = sampleRate * numChannels * (bitsPerSample ~/ 8) / 1000.0;
    final targetBytes = max(1, (bytesPerMs * _micPacketMs).round());
    if (_micAccumulator.length >= targetBytes) {
      final packet = _micAccumulator.toBytes();
      _micAccumulator.clear();
      try {
        _ws!.sink.add(packet);
      } catch (e) {
        _logLine('Mic send error: $e');
      }
    }
  }

  void _micError(Object e) {
    _logLine('Mic error: $e');
  }

  Uint8List _float32ToInt16LE(Float32List f32) {
    final out = Uint8List(f32.length * 2);
    final bd = ByteData.view(out.buffer);
    for (int i = 0; i < f32.length; i++) {
      double s = f32[i];
      if (s > 1.0) s = 1.0;
      if (s < -1.0) s = -1.0;
      final v = (s * 32767.0).round();
      bd.setInt16(i * 2, v, Endian.little);
    }
    return out;
  }

  // ===== UI =====
  @override
  Widget build(BuildContext context) {
    final connectedColor = _connected ? Colors.green : Colors.red;
    return Scaffold(
      appBar: AppBar(title: const Text('Gemini Live (Duplex WS)')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Text('WS URL:'),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _wsUrlCtrl,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'ws://18.224.8.111:3000',
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _connected ? null : _connect,
                  child: const Text('Connect'),
                ),
                const SizedBox(width: 6),
                ElevatedButton(
                  onPressed: _connected ? _disconnect : null,
                  child: const Text('Disconnect'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text(
                  'Status: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  _connected ? 'CONNECTED' : 'DISCONNECTED',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: connectedColor,
                  ),
                ),
                const Spacer(),
                // push to talk
                Listener(
                  onPointerDown: (_) {
                    if (_connected && !_micOn) _startMic();
                  },
                  onPointerUp: (_) {
                    if (_micOn) _stopMic();
                  },
                  child: ElevatedButton.icon(
                    onPressed: _connected
                        ? (_micOn ? _stopMic : _startMic)
                        : null,
                    icon: Icon(_micOn ? Icons.mic : Icons.mic_none),
                    label: Text(_micOn ? 'Release to Send' : 'Push-to-Talk'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _micOn ? Colors.red : null,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Send Text (for testing)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textCtrl,
                    enabled: _connected,
                    onSubmitted: (_) => _sendText(),
                    decoration: const InputDecoration(
                      hintText: 'Type your message…',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _connected ? _sendText : null,
                  child: const Text('Send'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Transcript / System',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  color: const Color(0xFFF9F9F9),
                ),
                child: ListView.builder(
                  controller: _scroll,
                  itemCount: _log.length,
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Text(
                      _log[i].text,
                      style: TextStyle(color: _logColor(_log[i].type)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _LogType { system, user, ai, audio }

class _LogLine {
  final String text;
  final _LogType type;
  _LogLine(this.text, [this.type = _LogType.system]);
}
