// A Flutter page for a real-time voice assistant
// that connects to the Node.js Gemini Live Agent server.

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:just_audio/just_audio.dart' as ja;
import 'dart:typed_data';
import 'dart:async';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class LiveAgentScreen extends StatefulWidget {
  const LiveAgentScreen({super.key});

  @override
  State<LiveAgentScreen> createState() => _LiveAgentScreenState();
}

class _LiveAgentScreenState extends State<LiveAgentScreen> {
  // Use your computer's local IP address, NOT localhost (127.0.0.1).
  final TextEditingController _urlController =
      TextEditingController(text: 'ws://10.0.2.2:3000');
  final TextEditingController _inputController = TextEditingController();

  WebSocketChannel? _channel;
  bool _isConnected = false;
  bool _isRecording = false;

  final List<String> _messages = [];
  final ja.AudioPlayer _audioPlayer = ja.AudioPlayer();

  // Audio Input/Output Management
  final List<Uint8List> _audioBuffer = [];
  bool _isAudioPlaying = false;
  late StreamSubscription _playerStateSubscription;
  StreamSubscription<Uint8List>? _micSubscription;
  RecorderController? _recorderController;
  String? _recordingPath;

  @override
  void initState() {
    super.initState();
    // Subscription to handle seamless playback of incoming audio chunks
    _playerStateSubscription = _audioPlayer.playerStateStream.listen((state) {
      print('🎵 Audio player state: ${state.processingState}, playing: ${state.playing}');
      
      if (state.processingState == ja.ProcessingState.ready &&
          !_isAudioPlaying) {
        print('▶️ Starting audio playback');
        _audioPlayer.play();
        _isAudioPlaying = true;
      }
      if (state.processingState == ja.ProcessingState.completed) {
        print('✅ Audio playback completed');
        _isAudioPlaying = false;
        _playNextAudioChunk();
      }
    });
  }

  @override
  void dispose() {
    _playerStateSubscription.cancel();
    _micSubscription?.cancel();
    _recorderController?.dispose();
    _audioPlayer.dispose();
    _channel?.sink.close();
    _urlController.dispose();
    _inputController.dispose();
    super.dispose();
  }

  // --- WEBSOCKET METHODS ---

  void _connect() {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(_urlController.text));
      setState(() {
        _messages.add('System: Connecting to ${_urlController.text}...');
        _isConnected = true;
      });

      _channel!.stream.listen(
        _handleIncomingData,
        onDone: _onDisconnect,
        onError: (error) {
          _onDisconnect('Connection Error: $error');
        },
      );
    } catch (e) {
      _onDisconnect('Connection Failed: $e');
    }
  }

  void _disconnect() {
    // If recording, stop it cleanly before closing the channel
    if (_isRecording) _stopRecording();
    _channel?.sink.close();
    _onDisconnect('System: Disconnected.');
  }

  void _onDisconnect([dynamic reason]) {
    setState(() {
      _isConnected = false;
      _isAudioPlaying = false;
      _audioPlayer.stop();
      _audioBuffer.clear();
      if (reason != null) {
        _messages.add('System: Disconnected ($reason)');
      }
    });
  }

  // --- DATA HANDLING ---

  void _handleIncomingData(dynamic data) {
    print('📥 Received data: ${data.runtimeType}');
    
    if (data is String) {
      // Handles the final, buffered text message (transcript/response)
      print('📝 Received text: $data');
      setState(() {
        _messages.add('AI: $data');
      });
    } else if (data is Uint8List) {
      // Handles the incoming binary audio chunks (raw 24kHz PCM)
      print('🔊 Received audio chunk: ${data.length} bytes');
      _audioBuffer.add(data);
      if (!_isAudioPlaying) {
        print('▶️ Starting audio playback...');
        _playNextAudioChunk();
      }
    } else {
      print('❓ Unknown data type: ${data.runtimeType}, content: $data');
    }
  }

  void _sendText(String text) {
    if (_isConnected && text.isNotEmpty) {
      // Send text input as a string to the server
      print('📤 Sending text to server: $text');
      _channel!.sink.add(text);
      setState(() {
        _messages.add('User (Text): $text');
        _inputController.clear();
      });
    }
  }

  // Test method to check if server is responding
  void _testServerResponse() {
    if (_isConnected) {
      print('🧪 Testing server response...');
      _channel!.sink.add('Hello, can you hear me?');
      setState(() {
        _messages.add('User (Test): Hello, can you hear me?');
      });
    }
  }

  // --- VOICE INPUT METHODS ---

  Future<void> _startRecording() async {
    print('🎤 Starting recording...');

    // 1. Check permissions
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      print('❌ Microphone permission denied');
      setState(() {
        _messages
            .add('System: Microphone permission denied. Please grant access.');
      });
      return;
    }

    if (!_isConnected) {
      print('❌ Not connected to server');
      setState(() {
        _messages.add('System: Connect to server first.');
      });
      return;
    }

    // 2. Initialize recorder controller
    try {
      print('🎤 Initializing recorder...');
      _recorderController = RecorderController();

      // Get temporary directory for recording
      final Directory tempDir = await getTemporaryDirectory();
      _recordingPath = '${tempDir.path}/temp_recording.wav';
      print('🎤 Recording path: $_recordingPath');

      // Start recording to file
      await _recorderController!.record(path: _recordingPath);
      print('✅ Recording started successfully');

      setState(() {
        _isRecording = true;
        _messages.add('User (Voice): Recording started...');
      });

      // Note: For real-time streaming, we would need to implement
      // periodic file reading or use a different approach
      // This is a simplified version for demonstration
    } catch (e) {
      print('❌ Recording error: $e');
      setState(() {
        _messages.add('System: Recording error: $e');
        _isRecording = false;
      });
    }
  }

  void _stopRecording() async {
    print('🛑 Stopping recording...');
    if (!_isRecording) {
      print('❌ Not currently recording');
      return;
    }

    // 1. Stop the recorder
    try {
      if (_recorderController != null) {
        print('🛑 Stopping recorder controller...');
        await _recorderController!.stop();

        // Read the recorded file and send it to the server
        if (_recordingPath != null) {
          final File recordedFile = File(_recordingPath!);
          if (await recordedFile.exists()) {
            print('📁 Reading recorded file: $_recordingPath');
            final Uint8List audioData = await recordedFile.readAsBytes();
            print('📤 Sending ${audioData.length} bytes to server');
            _channel!.sink.add(audioData);

            // Clean up the temporary file
            await recordedFile.delete();
            print('🗑️ Temporary file deleted');
          } else {
            print('❌ Recording file does not exist');
          }
        }
      }
    } catch (e) {
      print('❌ Error stopping recorder: $e');
    }

    // 2. Cancel the stream subscription
    _micSubscription?.cancel();
    _micSubscription = null;

    // 3. Signal the end of the user's turn to the server
    _channel!.sink.add(' ');

    setState(() {
      _isRecording = false;
      _messages.add('User (Voice): Recording stopped. Waiting for response...');
    });
  }

  // --- AUDIO PLAYBACK METHODS ---

  Future<void> _playNextAudioChunk() async {
    print('🎵 _playNextAudioChunk called, buffer size: ${_audioBuffer.length}');
    
    if (_audioBuffer.isEmpty) {
      print('🔇 Audio buffer is empty, stopping playback');
      _isAudioPlaying = false;
      return;
    }

    final Uint8List rawPcmChunk = _audioBuffer.removeAt(0);
    print('🎶 Playing audio chunk: ${rawPcmChunk.length} bytes');

    try {
      // Convert raw PCM to WAV format for better compatibility
      final wavData = _convertPcmToWav(rawPcmChunk);
      print('🎵 Converted to WAV: ${wavData.length} bytes');

      final audioSource = ja.AudioSource.uri(
        Uri.dataFromBytes(wavData, mimeType: 'audio/wav'),
      );

      print('🎧 Setting audio source...');
      await _audioPlayer.setAudioSource(audioSource, preload: false);
      print('✅ Audio source set successfully');
      
    } catch (e) {
      // Fallback: just skip this audio chunk and try the next one
      print('❌ Audio playback error: $e');
      if (_audioBuffer.isNotEmpty) {
        _playNextAudioChunk();
      } else {
        _isAudioPlaying = false;
      }
    }
  }

  // Convert raw PCM data to WAV format for better audio player compatibility
  Uint8List _convertPcmToWav(Uint8List pcmData) {
    const int sampleRate = 24000; // Server sends 24kHz audio
    const int bitsPerSample = 16;
    const int numChannels = 1;

    final int dataSize = pcmData.length;
    final int fileSize = 36 + dataSize;

    final List<int> wavHeader = [
      // RIFF header
      0x52, 0x49, 0x46, 0x46, // "RIFF"
      fileSize & 0xff, (fileSize >> 8) & 0xff, (fileSize >> 16) & 0xff,
      (fileSize >> 24) & 0xff,
      0x57, 0x41, 0x56, 0x45, // "WAVE"

      // fmt chunk
      0x66, 0x6d, 0x74, 0x20, // "fmt "
      0x10, 0x00, 0x00, 0x00, // chunk size (16)
      0x01, 0x00, // audio format (1 = PCM)
      numChannels & 0xff, (numChannels >> 8) & 0xff, // number of channels
      sampleRate & 0xff, (sampleRate >> 8) & 0xff, (sampleRate >> 16) & 0xff,
      (sampleRate >> 24) & 0xff,
      (sampleRate * numChannels * bitsPerSample ~/ 8) & 0xff,
      ((sampleRate * numChannels * bitsPerSample ~/ 8) >> 8) & 0xff,
      ((sampleRate * numChannels * bitsPerSample ~/ 8) >> 16) & 0xff,
      ((sampleRate * numChannels * bitsPerSample ~/ 8) >> 24) &
          0xff, // byte rate
      (numChannels * bitsPerSample ~/ 8) & 0xff,
      ((numChannels * bitsPerSample ~/ 8) >> 8) & 0xff, // block align
      bitsPerSample & 0xff, (bitsPerSample >> 8) & 0xff, // bits per sample

      // data chunk
      0x64, 0x61, 0x74, 0x61, // "data"
      dataSize & 0xff, (dataSize >> 8) & 0xff, (dataSize >> 16) & 0xff,
      (dataSize >> 24) & 0xff,
    ];

    return Uint8List.fromList([...wavHeader, ...pcmData]);
  }

  // --- UI WIDGETS ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Corporate Gemini Live Agent'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 1. Connection Controls
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _urlController,
                    decoration: const InputDecoration(labelText: 'Server URL'),
                    enabled: !_isConnected,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isConnected ? _disconnect : _connect,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isConnected ? Colors.red : Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(_isConnected ? 'Disconnect' : 'Connect'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 2. Message History
            Expanded(
              child: ListView.builder(
                reverse: true,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[_messages.length - 1 - index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text(
                      message,
                      style: TextStyle(
                        color: message.startsWith('User')
                            ? Colors.blue
                            : message.startsWith('AI')
                                ? Colors.deepPurple
                                : Colors.grey,
                        fontWeight: message.startsWith('System')
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  );
                },
              ),
            ),

            // 3. Input Field (Modified to include Push-to-Talk button)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    decoration: const InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: _sendText,
                    enabled: _isConnected &&
                        !_isRecording, // Disable text input while recording
                  ),
                ),
                const SizedBox(width: 8),
                // Microphone Button: Tap to start/stop recording
                GestureDetector(
                  onTap: _isConnected
                      ? () {
                          if (_isRecording) {
                            _stopRecording();
                          } else {
                            _startRecording();
                          }
                        }
                      : null,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _isConnected
                          ? (_isRecording
                              ? Colors.red.shade600
                              : Colors.deepPurple)
                          : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      _isRecording ? Icons.stop : Icons.mic,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Send Text Button
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _isConnected && !_isRecording
                      ? () => _sendText(_inputController.text)
                      : null,
                  color: Colors.deepPurple,
                  disabledColor: Colors.grey,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
