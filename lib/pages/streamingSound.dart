import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_audio_capture/flutter_audio_capture.dart';
import 'package:just_audio/just_audio.dart' as ja;
// TTS موجود لكن معطّل
import 'package:flutter_tts/flutter_tts.dart';

class StreamingSoundScreen extends StatefulWidget {
  const StreamingSoundScreen({super.key});
  @override
  State<StreamingSoundScreen> createState() => _StreamingSoundScreenState();
}

class _StreamingSoundScreenState extends State<StreamingSoundScreen> {
  final _urlController = TextEditingController(text: 'ws://18.224.8.111:3000');
  final _inputController = TextEditingController();

  WebSocketChannel? _channel;
  bool _isConnected = false;
  bool _manualDisconnect = false;
  int _reconnectAttempts = 0;
  Timer? _reconnectTimer;
  Timer? _keepAliveTimer;

  // Capture / stream
  final _audioCapture = FlutterAudioCapture();
  bool _isRecording = false;
  bool _isStartInProgress = false;
  bool _isStopInProgress = false;
  bool _allowMicStream = false; // يمنع أي تدفّق بعد Stop

  // Playback pipeline
  final ja.AudioPlayer _player = ja.AudioPlayer();
  late final StreamSubscription _playerSub;
  late final ja.ConcatenatingAudioSource _playlist;

  // جِتّر بافر (تجميع PCM ذكي لتقليل التقطيع)
  final BytesBuilder _pcmBuffer = BytesBuilder();
  int _pcmBufferedBytes = 0;
  bool _firstChunkFlushed = false;
  Timer? _pcmFlushTimer;

  // سرعة الاستجابة مقابل السلاسة
  static const int _firstChunkMs = 90; // لتقليل التأخير الأولي
  static const int _nextChunkMs = 220; // لتقليل عدد القطع بعد التشغيل
  static const int serverOutSampleRate = 24000;
  static const int serverOutNumChannels = 1;
  static const int serverOutBitsPerSample = 16;
  static const int _bytesPerSample = serverOutBitsPerSample ~/ 8; // 2
  static int get _bytesPerMs =>
      (serverOutSampleRate * serverOutNumChannels * _bytesPerSample) ~/ 1000;
  int get _firstChunkBytes => _bytesPerMs * _firstChunkMs;
  int get _nextChunkBytes => _bytesPerMs * _nextChunkMs;

  // سياسة الرد
  bool _oneShotResponse = true;
  bool _awaitingResponse = false;
  bool _lockedUntilNextRecording = false;
  bool _gotFirstAudioThisTurn = false;
  Timer? _responseGuardTimer;
  Timer? _textGuardTimer;
  static const int _maxTurnTextMs = 2500; // لو السيرفر يرد نص فقط
  static const int _maxTurnAudioMs = 8000000000; // أقصى زمن مسموح لرد الصوت

  // TTS (معطّل)
  final FlutterTts _tts = FlutterTts();

  // Recorded uplink (اختياري للـ playback)
  final List<Uint8List> _recordedAudioBuffer = [];
  bool _showPlaybackButton = false;

  // Audio level UI
  double _currentAudioLevel = 0.0;
  Timer? _audioLevelTimer;

  final List<String> _messages = [];

  // Uplink format
  static const int inputSampleRate = 16000;
  static const int inputNumChannels = 1;

  @override
  void initState() {
    super.initState();

    _playlist = ja.ConcatenatingAudioSource(children: []);
    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      await _audioCapture.init();

      // اربط البلاي ليست مرة وحدة من البداية لتجنب أي تقطيع/تأخير
      await _player.setAudioSource(_playlist);
      await _player.setVolume(1.0);
      await _player.setSpeed(1.0);

      // كروس فيد خفيف لطمس الفراغ بين القطع
      // Crossfade skipped (not available on this just_audio version)

      _playerSub = _player.playerStateStream.listen((st) async {
        // لما يفضى البلاي ليست ونكون خارج التسجيل، نقفل الدور نهائيًا
        if (st.processingState == ja.ProcessingState.completed ||
            (st.processingState == ja.ProcessingState.idle &&
                !_isRecording &&
                _playlist.length == 0)) {
          _finalizeTurnIfNeeded();
        }
      });
    } catch (e) {
      setState(() => _messages.add('System: Failed to init audio: $e'));
      // حتى لو فشل init، أمنع الكراش على dispose
      _playerSub = const Stream.empty().listen((_) {});
    }

    // عطّل أي TTS
    _configureTts();
  }

  @override
  void dispose() {
    _stopKeepAlive();
    _reconnectTimer?.cancel();
    _responseGuardTimer?.cancel();
    _textGuardTimer?.cancel();
    _playerSub.cancel();
    _player.dispose();
    _audioLevelTimer?.cancel();
    if (_isRecording) {
      _audioCapture.stop();
    }
    _safeTtsStop();
    _channel?.sink.close();
    _inputController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  // ---------------- WebSocket ----------------
  void _connect() {
    try {
      _manualDisconnect = false;
      _reconnectTimer?.cancel();
      _channel = WebSocketChannel.connect(Uri.parse(_urlController.text));
      setState(() {
        _isConnected = true;
        _messages.add('System: Connecting to ${_urlController.text}…');
      });

      _channel!.stream.listen(
        _onServerData,
        onDone: _onDisconnected,
        onError: (e) => _onDisconnected('Connection Error: $e'),
      );

      // عطّل keep-alive لأن بعض السيرفرات تتعامل مع "ping" كرد
      // _startKeepAlive();
      _reconnectAttempts = 0;
    } catch (e) {
      _onDisconnected('Connection Failed: $e');
    }
  }

  void _disconnect() {
    if (_isRecording) _stopRecording();
    _manualDisconnect = true;
    _stopKeepAlive();
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _onDisconnected('System: Disconnected.');
  }

  void _onDisconnected([dynamic reason]) {
    setState(() {
      _isConnected = false;
      _messages.add(
        'System: Disconnected${reason != null ? ' ($reason)' : ''}',
      );
    });
    _stopKeepAlive();
    _resetPlaybackPipeline();

    if (!_manualDisconnect) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_isConnected) return;
    _reconnectTimer?.cancel();
    _reconnectAttempts = (_reconnectAttempts + 1).clamp(1, 10);
    final seconds = (1 << (_reconnectAttempts - 1));
    final delay = Duration(seconds: seconds > 30 ? 30 : seconds);
    setState(
      () => _messages.add('System: Reconnecting in ${delay.inSeconds}s…'),
    );
    _reconnectTimer = Timer(delay, () {
      if (!_manualDisconnect) _connect();
    });
  }

  void _stopKeepAlive() {
    _keepAliveTimer?.cancel();
    _keepAliveTimer = null;
  }

  // ---------------- Incoming ----------------
  void _onServerData(dynamic data) {
    // لو الدور مقفول، تجاهل كل شيء لحد التسجيل القادم
    if (_lockedUntilNextRecording) return;

    if (data is String) {
      // عرض نص فقط أثناء نافذة الرد
      if (!_awaitingResponse && _oneShotResponse) return;
      setState(() => _messages.add('AI: $data'));
      // فعّل حارس النص لو ما فيش صوت
      _startTextGuard();
      return;
    }

    if (data is Uint8List || data is List<int> || data is ByteBuffer) {
      if (!_awaitingResponse && _oneShotResponse) return;

      _safeTtsStop();

      Uint8List bytes;
      if (data is Uint8List) {
        bytes = data;
      } else if (data is List<int>) {
        bytes = Uint8List.fromList(data);
      } else {
        bytes = (data as ByteBuffer).asUint8List();
      }

      // أول باكيت صوت = بداية الرد
      if (!_gotFirstAudioThisTurn) {
        _gotFirstAudioThisTurn = true;
        _startResponseGuard(); // حارس زمن أقصى للرد
        // أول حزمة صوت = flush أسرع
        _firstChunkFlushed = false;
      }

      if (_isWavData(bytes)) {
        _enqueueWav(bytes);
      } else {
        _enqueuePcm(bytes);
      }
      return;
    }

    setState(() => _messages.add('System: Unknown data from server'));
  }

  // ---------------- Turn gating ----------------
  void _openTurnForReply() {
    _awaitingResponse = true;
    _lockedUntilNextRecording = false;
    _gotFirstAudioThisTurn = false;
    _responseGuardTimer?.cancel();
  }

  void _startResponseGuard() {
    _responseGuardTimer?.cancel();
    _responseGuardTimer = Timer(
      const Duration(milliseconds: _maxTurnAudioMs),
      () {
        _finalizeTurnIfNeeded();
      },
    );
  }

  void _startTextGuard() {
    _textGuardTimer?.cancel();
    _textGuardTimer = Timer(const Duration(milliseconds: _maxTurnTextMs), () {
      _finalizeTurnIfNeeded();
    });
  }

  void _finalizeTurnIfNeeded() {
    if (_oneShotResponse) {
      _awaitingResponse = false;
      _lockedUntilNextRecording = true; // امنع أي ذيول من السيرفر
    }
    _responseGuardTimer?.cancel();
    _responseGuardTimer = null;
    _textGuardTimer?.cancel();
    _textGuardTimer = null;
  }

  // resetTurn removed; gating handled by guards

  // ---------------- Outgoing ----------------
  void _sendText(String text) {
    if (!_isConnected || text.trim().isEmpty) return;
    _channel!.sink.add(text);
    setState(() {
      _messages.add('User (Text): $text');
      _inputController.clear();
    });
    if (_oneShotResponse) _openTurnForReply();
  }

  // ---------------- Mic ----------------
  Future<void> _toggleRecording() async {
    if (!_isConnected) return;
    if (_isStartInProgress || _isStopInProgress) return;
    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    if (!_isConnected) {
      setState(() => _messages.add('System: Connect to server first.'));
      return;
    }

    final micStatus = await Permission.microphone.request();
    if (micStatus != PermissionStatus.granted) {
      setState(() => _messages.add('System: Microphone permission denied.'));
      return;
    }

    if (_isRecording || _isStartInProgress) return;
    _isStartInProgress = true;
    try {
      _recordedAudioBuffer.clear();
      setState(() => _showPlaybackButton = false);

      _allowMicStream = true;

      await _audioCapture.start(
        _onAudioCaptured,
        _onAudioError,
        sampleRate: inputSampleRate,
        bufferSize: 1024,
      );

      await _safeTtsStop();

      setState(() {
        _isRecording = true;
      });

      _audioLevelTimer?.cancel();
      _audioLevelTimer = Timer.periodic(const Duration(milliseconds: 120), (_) {
        if (!_isRecording) {
          _audioLevelTimer?.cancel();
        } else if (mounted) {
          setState(() {});
        }
      });

      // بمجرد بدء تسجيل جديد، افتح نافذة رد جديدة
      if (_oneShotResponse) _openTurnForReply();
      // ابدأ دورة جديدة: أوقف أي تشغيل سابق وافرغ البافرات حتى لا يتداخل الصوت
      _resetPlaybackPipeline();
    } catch (e) {
      setState(() {
        _isRecording = false;
        _messages.add('System: Recording error: $e');
      });
    } finally {
      _isStartInProgress = false;
    }
  }

  Future<void> _stopRecording() async {
    if (!_isRecording || _isStopInProgress) return;
    _isStopInProgress = true;

    try {
      _allowMicStream = false;
      await _audioCapture.stop().timeout(const Duration(seconds: 2));
    } catch (_) {}

    // إشارة نهاية الدور — فقط END_OF_TURN (بدون \n لتجنّب prompts إضافية)
    try {
      _channel?.sink.add('END_OF_TURN');
    } catch (_) {}

    setState(() {
      _isRecording = false;
      _currentAudioLevel = 0.0;
      _showPlaybackButton = _recordedAudioBuffer.isNotEmpty;
    });
    _audioLevelTimer?.cancel();

    // بعد التوقف مباشرةً، ابدأ تشغيل الصوت القادم من السيرفر إن وجد
    try {
      if (_playlist.length > 0) {
        final newIndex = _playlist.length - 1;
        if (_player.processingState == ja.ProcessingState.completed ||
            _player.currentIndex == null ||
            (_player.currentIndex ?? -1) != newIndex) {
          await _player.seek(Duration.zero, index: newIndex);
        }
        if (!_player.playing) {
          await _player.play();
        }
      }
    } catch (_) {}

    _isStopInProgress = false;
  }

  // flutter_audio_capture callback
  void _onAudioCaptured(dynamic obj) {
    if (!_isRecording || !_allowMicStream) return;

    Float32List floatData;
    if (obj is Float32List) {
      floatData = obj;
    } else if (obj is List) {
      floatData = Float32List.fromList(obj.cast<double>());
    } else {
      return;
    }

    double maxAmplitude = 0.0;
    for (int i = 0; i < floatData.length; i++) {
      final v = floatData[i].abs();
      if (v > maxAmplitude) maxAmplitude = v;
    }

    setState(() => _currentAudioLevel = maxAmplitude);

    // Boost بسيط
    Float32List processedData = floatData;
    if (maxAmplitude > 0 && maxAmplitude < 0.1) {
      final gainFactor = (0.3 / maxAmplitude).clamp(1.0, 3.0);
      processedData = Float32List(floatData.length);
      for (int i = 0; i < floatData.length; i++) {
        processedData[i] = (floatData[i] * gainFactor).clamp(-1.0, 1.0);
      }
    }

    final chunk = _float32ToPCM16(
      processedData,
      numChannels: inputNumChannels,
      clamp: true,
    );

    _recordedAudioBuffer.add(chunk); // اختياري
    _channel?.sink.add(chunk); // uplink
  }

  void _onAudioError(Object e) {
    setState(() => _messages.add('System: Capture error: $e'));
  }

  // ---------------- Playback ----------------
  void _enqueuePcm(Uint8List rawPcm) {
    // ضيف للباڤر
    _pcmBuffer.add(rawPcm);
    _pcmBufferedBytes += rawPcm.length;

    // احسب العتبة الحالية
    final int threshold = _firstChunkFlushed
        ? _nextChunkBytes
        : _firstChunkBytes;

    // flush فوري لو عدينا العتبة
    if (_pcmBufferedBytes >= threshold) {
      _flushPcmBufferToWav();
      _firstChunkFlushed = true;
      return;
    }

    // أو جدولة flush سريع لو مفيش باكيتات جديدة
    _pcmFlushTimer?.cancel();
    _pcmFlushTimer = Timer(const Duration(milliseconds: 60), () {
      if (_pcmBufferedBytes > 0) {
        _flushPcmBufferToWav();
        _firstChunkFlushed = true;
      }
    });
  }

  void _flushPcmBufferToWav() {
    if (_pcmBufferedBytes == 0) return;
    final pcmChunk = _pcmBuffer.toBytes();
    _pcmBuffer.clear();
    _pcmBufferedBytes = 0;

    final wav = _pcmToWav(
      pcmChunk,
      sampleRate: serverOutSampleRate,
      numChannels: serverOutNumChannels,
      bitsPerSample: serverOutBitsPerSample,
    );
    _enqueueWav(wav);
  }

  void _enqueueWav(Uint8List wavBytes) async {
    final source = ja.AudioSource.uri(
      Uri.dataFromBytes(wavBytes, mimeType: 'audio/wav'),
    );

    try {
      await _playlist.add(source);
    } catch (_) {}
    if (!_isRecording) {
      try {
        final newIndex = _playlist.length - 1;
        if (_player.processingState == ja.ProcessingState.completed ||
            _player.currentIndex == null ||
            (_player.currentIndex ?? -1) != newIndex) {
          await _player.seek(Duration.zero, index: newIndex);
        }
        if (!_player.playing) {
          await _player.play();
        }
      } catch (_) {}
    }
  }

  void _resetPlaybackPipeline() {
    _player.stop();
    _playlist.clear();
    _pcmBuffer.clear();
    _pcmBufferedBytes = 0;
    _pcmFlushTimer?.cancel();
    _pcmFlushTimer = null;
    _firstChunkFlushed = false;
  }

  // ---------------- Helpers ----------------
  bool _isWavData(Uint8List data) {
    if (data.length < 12) return false;
    return data[0] == 0x52 &&
        data[1] == 0x49 &&
        data[2] == 0x46 &&
        data[3] == 0x46 &&
        data[8] == 0x57 &&
        data[9] == 0x41 &&
        data[10] == 0x56 &&
        data[11] == 0x45;
  }

  Future<void> _configureTts() async {
    await _safeTtsStop();
  }

  Future<void> _safeTtsStop() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }

  Uint8List _float32ToPCM16(
    Float32List floats, {
    int numChannels = 1,
    bool clamp = true,
  }) {
    final out = BytesBuilder();
    for (var i = 0; i < floats.length; i++) {
      var s = floats[i];
      if (clamp) {
        if (s > 1.0) s = 1.0;
        if (s < -1.0) s = -1.0;
      }
      final intSample = (s * 32767.0).round();
      final lo = intSample & 0xff;
      final hi = (intSample >> 8) & 0xff;
      out.add([lo, hi]);
    }
    return out.toBytes();
  }

  Uint8List _pcmToWav(
    Uint8List pcmData, {
    required int sampleRate,
    required int numChannels,
    required int bitsPerSample,
  }) {
    final byteRate = sampleRate * numChannels * (bitsPerSample ~/ 8);
    final blockAlign = numChannels * (bitsPerSample ~/ 8);
    final dataSize = pcmData.length;
    final fileSize = 36 + dataSize;

    final header = BytesBuilder();
    header.add([0x52, 0x49, 0x46, 0x46]); // RIFF
    header.add(_le32(fileSize));
    header.add([0x57, 0x41, 0x56, 0x45]); // WAVE
    header.add([0x66, 0x6d, 0x74, 0x20]); // fmt
    header.add(_le32(16));
    header.add(_le16(1));
    header.add(_le16(numChannels));
    header.add(_le32(sampleRate));
    header.add(_le32(byteRate));
    header.add(_le16(blockAlign));
    header.add(_le16(bitsPerSample));
    header.add([0x64, 0x61, 0x74, 0x61]); // data
    header.add(_le32(dataSize));

    return Uint8List.fromList([...header.toBytes(), ...pcmData]);
  }

  List<int> _le16(int v) => [v & 0xff, (v >> 8) & 0xff];
  List<int> _le32(int v) => [
    v & 0xff,
    (v >> 8) & 0xff,
    (v >> 16) & 0xff,
    (v >> 24) & 0xff,
  ];

  // ---------------- Optional: play uplink ----------------
  Future<void> _playRecordedAudio() async {
    if (_recordedAudioBuffer.isEmpty) {
      setState(() => _messages.add('System: No recorded audio to play'));
      return;
    }

    try {
      final combined = Uint8List.fromList(
        _recordedAudioBuffer.expand((b) => b).toList(),
      );
      final wav = _pcmToWav(
        combined,
        sampleRate: inputSampleRate,
        numChannels: inputNumChannels,
        bitsPerSample: 16,
      );

      await _player.stop();
      await _player.setAudioSource(
        ja.AudioSource.uri(Uri.dataFromBytes(wav, mimeType: 'audio/wav')),
      );
      await _player.play();
    } catch (e) {
      setState(
        () => _messages.add('System: Failed to play recorded audio: $e'),
      );
    }
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Corporate Gemini Live Agent')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Connection
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _urlController,
                    enabled: !_isConnected,
                    decoration: const InputDecoration(
                      labelText: 'Server WebSocket URL',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isConnected ? Colors.red : Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _isConnected ? _disconnect : _connect,
                  child: Text(_isConnected ? 'Disconnect' : 'Connect'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (_showPlaybackButton)
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _playRecordedAudio,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Play What I Recorded'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _showPlaybackButton = false;
                        _recordedAudioBuffer.clear();
                      });
                    },
                    icon: const Icon(Icons.close),
                    tooltip: 'Hide playback button',
                  ),
                ],
              ),
            Text('Recorded: ${_recordedAudioBuffer.length} chunks'),

            if (_isRecording) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Audio Level: '),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: _currentAudioLevel.clamp(0.0, 1.0),
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _currentAudioLevel > 0.1
                            ? Colors.green
                            : _currentAudioLevel > 0.01
                            ? Colors.orange
                            : Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${(_currentAudioLevel * 100).toStringAsFixed(0)}%'),
                ],
              ),
              if (_currentAudioLevel < 0.01)
                const Text(
                  'Very quiet - speak louder or move closer to microphone',
                  style: TextStyle(color: Colors.orange, fontSize: 12),
                ),
            ],
            const SizedBox(height: 8),

            Expanded(
              child: ListView.builder(
                reverse: true,
                itemCount: _messages.length,
                itemBuilder: (context, i) {
                  final m = _messages[_messages.length - 1 - i];
                  Color c = Colors.grey;
                  FontWeight w = FontWeight.normal;
                  if (m.startsWith('User')) c = Colors.blue;
                  if (m.startsWith('AI')) c = Colors.deepPurple;
                  if (m.startsWith('System')) w = FontWeight.bold;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      m,
                      style: TextStyle(color: c, fontWeight: w),
                    ),
                  );
                },
              ),
            ),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    enabled: _isConnected && !_isRecording,
                    decoration: const InputDecoration(
                      hintText: 'Type your message…',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: _sendText,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _isConnected ? _toggleRecording : null,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _isConnected
                          ? (_isRecording ? Colors.red : Colors.deepPurple)
                          : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(12),
                    child: (_isStartInProgress || _isStopInProgress)
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Icon(
                            _isRecording ? Icons.stop : Icons.mic,
                            color: Colors.white,
                            size: 28,
                          ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  color: Colors.deepPurple,
                  onPressed: _isConnected && !_isRecording
                      ? () => _sendText(_inputController.text)
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
