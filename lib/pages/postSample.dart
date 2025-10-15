import 'package:streamapp/templates/mainTemplates.dart';

import '../global/globalWidgets.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../global/globalConfig.dart';
import 'dart:convert';
import 'dart:developer';
import 'dart:async';
import 'dart:io';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

late bool _postRespLoading;
late TextEditingController _URLTE;
late TextEditingController InputTextTE;
late TextEditingController _detailsTE;
late String response;
late List<AttachmentTemplate> _attachmentsList;

// Audio recording variables
RecorderController? _recorderController;
late AudioPlayer _audioPlayer;
Timer? _recordingTimer;
bool _isRecording = false;
bool _isPlaying = false;
String? _audioPath;
Duration _recordDuration = Duration.zero;
Duration _playPosition = Duration.zero;

class postSamplePage extends StatefulWidget {
  @override
  State<postSamplePage> createState() => _postSamplePageState();
}

class _postSamplePageState extends State<postSamplePage> {
  Future initCalls() async {
    //_paymentsMap = await getUserPayments();
    // _catsMap = await getListDetails(Type: 'cats');

    // setState(() {
    //   _postRespLoading = false;
    // });

    _URLTE.text = await getLocalData('postInputURL');
  }

  Future<String> postAPIData({
    required String url,
    required String inputText,
  }) async {
    try {
      await setLocalData('postInputURL', url);
      String body = jsonEncode({"input": inputText});
      myLog(body.toString());
      final resp = await http.post(
        Uri.parse(url),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: body,
      );
      var result = json.decode(utf8.decode(resp.bodyBytes));
      log(result.toString());

      return result.toString();
    } catch (e) {
      setState(() {
        _postRespLoading = false;
      });
      return 'Error: ' + e.toString();
    }
  }

  // Send voice recording to API
  Future<String> sendVoiceToAPI({
    required String url,
    required String audioFilePath,
  }) async {
    try {
      await setLocalData('postInputURL', url);

      // Create multipart request
      var request = http.MultipartRequest('POST', Uri.parse(url));

      // Add the audio file
      var audioFile = await http.MultipartFile.fromPath(
        'audio', // field name for the audio file - change this based on your API requirements
        audioFilePath,
        filename: 'recording.wav',
      );
      request.files.add(audioFile);

      // Add additional form fields if your API requires them
      request.fields.addAll({
        'format': 'wav',
        'language': 'en', // or any language code your API expects
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
      });

      // Add any additional headers if needed
      request.headers.addAll({
        "Accept": "application/json",
        // Add authorization headers if required:
        // "Authorization": "Bearer YOUR_TOKEN_HERE",
      });

      myLog('Sending audio file: $audioFilePath to URL: $url');

      // Send the request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      myLog('Response status: ${response.statusCode}');
      myLog('Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Try to parse as JSON, if that fails return raw response
        try {
          var result = json.decode(utf8.decode(response.bodyBytes));
          return json.encode(result); // Pretty format the JSON
        } catch (e) {
          // If not JSON, return raw response
          return response.body;
        }
      } else {
        return 'Error: HTTP ${response.statusCode} - ${response.body}';
      }
    } catch (e) {
      setState(() {
        _postRespLoading = false;
      });
      myLog('Error sending voice to API: $e');
      return 'Error: ' + e.toString();
    }
  }

  // Audio recording methods
  Future<void> _startRecording() async {
    try {
      // Request microphone permission
      final permission = await Permission.microphone.request();
      if (permission != PermissionStatus.granted) {
        myToast(
          context: context,
          text: 'Microphone permission denied',
          statusCode: 'F',
          duartion: 3,
        );
        return;
      }

      // Get the app's document directory
      final directory = await getApplicationDocumentsDirectory();
      final path =
          '${directory.path}/recorded_audio_${DateTime.now().millisecondsSinceEpoch}.wav';

      myLog('Starting recording to: $path');

      // Initialize and start recorder
      _recorderController = RecorderController();
      await _recorderController!.record(path: path);

      setState(() {
        _isRecording = true;
        _audioPath = path;
        _recordDuration = Duration.zero;
      });

      // Start timer to update recording duration
      _startTimer();

      myLog('Recording started successfully');
    } catch (e) {
      myLog('Error starting recording: $e');
      myToast(
        context: context,
        text: 'Error starting recording: ${e.toString()}',
        statusCode: 'F',
        duartion: 3,
      );
    }
  }

  Future<void> _stopRecording() async {
    try {
      if (_recorderController != null) {
        final path = await _recorderController!.stop();
        _recordingTimer?.cancel();
        setState(() {
          _isRecording = false;
        });

        myLog('Recording stopped. File saved at: $path');

        if (path != null) {
          setState(() {
            _audioPath = path;
          });
        }

        myToast(
          context: context,
          text: 'Recording saved successfully',
          statusCode: 'S',
          duartion: 2,
        );
      }
    } catch (e) {
      myLog('Error stopping recording: $e');
      myToast(
        context: context,
        text: 'Error stopping recording: ${e.toString()}',
        statusCode: 'F',
        duartion: 3,
      );
    }
  }

  Future<void> _playRecording() async {
    if (_audioPath == null) {
      myToast(
        context: context,
        text: 'No recording found',
        statusCode: 'F',
        duartion: 2,
      );
      return;
    }

    try {
      myLog('Attempting to play: $_audioPath');

      // Check if file exists
      final file = File(_audioPath!);
      if (!await file.exists()) {
        myLog('File does not exist: $_audioPath');
        myToast(
          context: context,
          text: 'Recording file not found',
          statusCode: 'F',
          duartion: 3,
        );
        return;
      }

      final fileSize = await file.length();
      myLog('File exists, size: $fileSize bytes');

      if (fileSize == 0) {
        myLog('Audio file is empty');
        myToast(
          context: context,
          text: 'Audio file is empty',
          statusCode: 'F',
          duartion: 3,
        );
        return;
      }

      if (_isPlaying) {
        await _audioPlayer.pause();
        myLog('Playback paused');
      } else {
        // Stop any current playback first
        await _audioPlayer.stop();
        myLog('Previous playback stopped');

        // Wait a moment for the player to properly stop
        await Future.delayed(Duration(milliseconds: 100));

        myLog('Starting playback with just_audio...');

        // Set the audio source and play
        await _audioPlayer.setFilePath(_audioPath!);
        await _audioPlayer.play();

        myLog('Playback started successfully');
        myToast(
          context: context,
          text: 'Playing recording...',
          statusCode: 'S',
          duartion: 2,
        );

        // Check if playback actually started after a short delay
        await Future.delayed(Duration(milliseconds: 500));
        final isActuallyPlaying = _audioPlayer.playing;
        myLog('Playback status after 500ms: $isActuallyPlaying');

        if (!isActuallyPlaying) {
          myLog('Warning: Player not actually playing after start command');
          myToast(
            context: context,
            text: 'Playback failed to start',
            statusCode: 'F',
            duartion: 3,
          );
        }
      }
    } catch (e) {
      myLog('Error playing recording: $e');
      setState(() {
        _isPlaying = false;
      });
      myToast(
        context: context,
        text: 'Error playing recording: ${e.toString()}',
        statusCode: 'F',
        duartion: 3,
      );
    }
  }

  // Method to send voice recording to API
  Future<void> _sendVoiceToAPI() async {
    if (_audioPath == null) {
      myToast(
        context: context,
        text: 'No audio recording found. Please record audio first.',
        statusCode: 'F',
        duartion: 3,
      );
      return;
    }

    final url = _URLTE.text.trim();
    if (url.isEmpty) {
      myToast(
        context: context,
        text: 'Please enter API URL',
        statusCode: 'F',
        duartion: 3,
      );
      return;
    }

    try {
      setState(() {
        _postRespLoading = true;
      });

      myLog('Sending voice recording to API...');

      final result = await sendVoiceToAPI(url: url, audioFilePath: _audioPath!);

      setState(() {
        response = result;
        _postRespLoading = false;
      });

      myToast(
        context: context,
        text: 'Voice sent successfully!',
        statusCode: 'S',
        duartion: 2,
      );
    } catch (e) {
      setState(() {
        _postRespLoading = false;
      });

      myToast(
        context: context,
        text: 'Error sending voice: ${e.toString()}',
        statusCode: 'F',
        duartion: 3,
      );
    }
  }

  void _startTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isRecording) {
        setState(() {
          _recordDuration = Duration(seconds: _recordDuration.inSeconds + 1);
        });
      } else {
        timer.cancel();
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void initState() {
    _postRespLoading = false;
    _URLTE = TextEditingController();
    myLog(_URLTE.text);
    _URLTE.text = '';
    _attachmentsList = [AttachmentTemplate(id: '', docDesc: '')];
    InputTextTE = TextEditingController();
    _detailsTE = TextEditingController();
    response = '';

    // Initialize audio components
    _audioPlayer = AudioPlayer();

    // Initialize the recorder and player
    _initializeAudio();

    initCalls().then((value) {});
    super.initState();
  }

  Future<void> _initializeAudio() async {
    try {
      myLog('Initializing audio components...');

      // Set up player position listening
      _audioPlayer.positionStream.listen((position) {
        setState(() {
          _playPosition = position;
        });
      });

      // Set up player state listening
      _audioPlayer.playerStateStream.listen((state) {
        setState(() {
          _isPlaying = state.playing;
        });
      });

      myLog('Audio components initialized successfully');
    } catch (e) {
      myLog('Error initializing audio: $e');
      myToast(
        context: context,
        text: 'Error initializing audio: ${e.toString()}',
        statusCode: 'F',
        duartion: 3,
      );
    }
  }

  // Add method to check audio capabilities
  Future<void> _checkAudioSupport() async {
    try {
      final isRecording = _isRecording;
      myLog('Recorder recording status: $isRecording');

      final isPlaying = _audioPlayer.playing;
      myLog('Player playing status: $isPlaying');

      // Check player state
      final playerState = _audioPlayer.playerState;
      myLog('Player state: $playerState');

      if (_audioPath != null) {
        final file = File(_audioPath!);
        final exists = await file.exists();
        final size = exists ? await file.length() : 0;
        myLog('Audio file exists: $exists, size: $size bytes');
        myLog('Audio file path: $_audioPath');

        // Try to read file content to verify it's not corrupted
        if (exists && size > 0) {
          try {
            final bytes = await file.readAsBytes();
            myLog('Successfully read ${bytes.length} bytes from audio file');

            // Additional file validation
            if (bytes.length < 44) {
              myLog('Warning: Audio file seems too small to be valid WAV');
            }
          } catch (e) {
            myLog('Error reading audio file: $e');
          }
        }

        myToast(
          context: context,
          text: 'Audio file: ${exists ? "Found ($size bytes)" : "Not found"}',
          statusCode: exists ? 'S' : 'F',
          duartion: 3,
        );
      } else {
        myToast(
          context: context,
          text: 'No audio path set',
          statusCode: 'F',
          duartion: 3,
        );
      }
    } catch (e) {
      myLog('Error checking audio support: $e');
    }
  }

  Widget myPage() {
    return Column(
      children: [
        myTextField(label: 'API URL', textController: _URLTE, linesNo: 3),
        SizedBox(height: 5),
        myTextField(label: 'Input Text', textController: InputTextTE),
        SizedBox(height: 10),

        // Audio Recording Section
        Container(
          padding: EdgeInsets.all(16),
          margin: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Audio Recording',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),

              // Recording Controls
              Row(
                children: [
                  // Record/Stop Button
                  ElevatedButton.icon(
                    onPressed: _isRecording ? _stopRecording : _startRecording,
                    icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                    label: Text(_isRecording ? 'Stop' : 'Record'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isRecording ? Colors.red : Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  SizedBox(width: 10),

                  // Play/Pause Button
                  if (_audioPath != null)
                    ElevatedButton.icon(
                      onPressed: _playRecording,
                      icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                      label: Text(_isPlaying ? 'Pause' : 'Play'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                ],
              ),

              SizedBox(height: 10),

              // Debug button
              ElevatedButton.icon(
                onPressed: _checkAudioSupport,
                icon: Icon(Icons.bug_report),
                label: Text('Debug Audio'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),

              SizedBox(height: 10),

              // Send Voice to API button
              if (_audioPath != null)
                ElevatedButton.icon(
                  onPressed: _postRespLoading ? null : _sendVoiceToAPI,
                  icon: Icon(Icons.send),
                  label: Text(
                    _postRespLoading ? 'Sending...' : 'Send Voice to API',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                ),

              SizedBox(height: 10),

              // Recording Duration/Status
              if (_isRecording)
                Row(
                  children: [
                    Icon(
                      Icons.fiber_manual_record,
                      color: Colors.red,
                      size: 12,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Recording: ${_formatDuration(_recordDuration)}',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

              // Playback Progress
              if (_audioPath != null && !_isRecording)
                Column(
                  children: [
                    Text(
                      'Recorded: ${_formatDuration(_recordDuration)}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    if (_isPlaying)
                      Text(
                        'Playing: ${_formatDuration(_playPosition)}',
                        style: TextStyle(color: Colors.green),
                      ),
                  ],
                ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: myWhiteColor,
            boxShadow: [
              BoxShadow(
                color: blueColor.withOpacity(0.2),
                spreadRadius: 0.1,
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                myLable(text: 'Add Image', isbold: true),
                myAttachmentsBlock(attachmentsList: _attachmentsList),
              ],
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: myButton(
            buttonColor: mySuccessColor,
            buttonType: 'simple',
            text: 'Post',
            onpressed: () async {
              if (_URLTE.text.isEmpty) {
                myToast(
                  duartion: 5,
                  context: context,
                  text: 'Please enter API URL',
                  statusCode: 'F',
                );
                return;
              }
              if (InputTextTE.text.isEmpty) {
                myToast(
                  duartion: 5,
                  context: context,
                  text: 'Please enter Input Text',
                  statusCode: 'F',
                );
                return;
              }

              setState(() {
                _postRespLoading = true;
              });

              response = await postAPIData(
                url: _URLTE.text,
                inputText: InputTextTE.text,
              );
              setState(() {
                _postRespLoading = false;
                _detailsTE.text = response;
              });
            },
            elevation: 0,
          ),
        ),
        _postRespLoading
            ? myLoading()
            : myTextField(
                label: 'API Response:',
                textController: _detailsTE,
                linesNo: 10,
              ),
      ],
    );
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _recorderController?.stop();
    _audioPlayer.dispose();
    _URLTE.dispose();
    InputTextTE.dispose();
    _detailsTE.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(padding: const EdgeInsets.all(8.0), child: myPage()),
        ),
      ),
    );
  }
}
