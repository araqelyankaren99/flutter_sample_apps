import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'helper/audio_classification_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';

class AudioClassificationApp extends StatefulWidget {
  const AudioClassificationApp({super.key});

  @override
  State<AudioClassificationApp> createState() => _AudioClassificationAppState();
}

class _AudioClassificationAppState extends State<AudioClassificationApp> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final AudioClassificationHelper _helper = AudioClassificationHelper();

  String _resultText = 'Press the mic to classify';
  bool _isRecording = false;
  late String _filePath;

  @override
  void initState() {
    super.initState();
    _initEverything();
  }

  Future<void> _initEverything() async {
    final tempDir = await getTemporaryDirectory();
    _filePath = '${tempDir.path}/recorded.wav';

    await _recorder.openRecorder();
    await _helper.initHelper();
  }

  Future<void> _recordAndClassify() async {
    setState(() {
      _isRecording = true;
      _resultText = 'Recording...';
    });

    await _recorder.startRecorder(
      toFile: _filePath,
      codec: Codec.pcm16WAV,
      sampleRate: 16000,
      numChannels: 1,
    );

    // Wait ~1 sec (YAMNet expects ~0.96 sec)
    await Future.delayed(Duration(milliseconds: 1000));

    await _recorder.stopRecorder();
    setState(() => _isRecording = false);

    final fileBytes = await File(_filePath).readAsBytes();

    // Extract Int16 PCM from WAV and convert
    final audioData = _extractWavData(fileBytes);
    final floatData = _convertToFloat32List(audioData);

    final result = await _helper.inference(floatData);
    final top = result.entries;

    setState(() {
      _resultText = top.toString();
    });
  }

  /// Skip the WAV header (first 44 bytes) and return PCM Int16 samples
  Int16List _extractWavData(Uint8List wavBytes) {
    final audioBytes = wavBytes.sublist(44); // Skip WAV header
    return Int16List.view(audioBytes.buffer);
  }

  Float32List _convertToFloat32List(Int16List int16Data) {
    final float32List = Float32List(int16Data.length);
    for (int i = 0; i < int16Data.length; i++) {
      float32List[i] = int16Data[i] / 32768.0;
    }
    return float32List;
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _helper.closeInterpreter();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Audio Classification')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(_resultText, textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _isRecording ? null : _recordAndClassify,
          child: Icon(Icons.mic),
        ),
    );
  }
}
