import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sample_apps/open_cv/doc_detector_interface.dart';
import 'package:path_provider/path_provider.dart';

import 'main.dart';

class CameraProcessingScreen extends StatefulWidget {
  const CameraProcessingScreen({super.key});

  @override
  State<CameraProcessingScreen> createState() => _CameraProcessingScreenState();
}

class _CameraProcessingScreenState extends State<CameraProcessingScreen> {
  CameraController? _cameraController;
  late String _appTempDirectoryPath;
  bool _isProcessing = false;
  final _edgeDetectionInterface = DocDetectorInterface();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.stopImageStream();
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    final directory = await getTemporaryDirectory();
    _appTempDirectoryPath = directory.path;

    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _cameraController = CameraController(
      cameras.first,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _cameraController?.initialize();
    await _cameraController?.lockCaptureOrientation(DeviceOrientation.portraitUp);
    await _cameraController?.setFlashMode(FlashMode.off);
    setState(() {});
    _cameraController?.startImageStream(_onImageStream);
  }

  Future<void> _onImageStream(CameraImage cameraImage) async {
    if (_isProcessing) {
      return;
    }
    await Future.delayed(Duration.zero);
    _isProcessing = true;

    try {
     final outputFilePath = '$_appTempDirectoryPath/temp.jpeg';
     final edgeDetectionResult = await _edgeDetectionInterface.processLiveStreamImage(
          cameraImage: cameraImage,
        outputPathStr: outputFilePath,
      );

      final top = edgeDetectionResult.topLeft.dy;
      final left = edgeDetectionResult.bottomRight.dx;

      if (top == 0.0 && left == 1.0) {
        return;
      }
      if (!mounted) {
        return;
      }
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => ResultScreen(croppedFilePath: outputFilePath),
        ),
          (_) => false,
      );
    } catch (e, st) {
      print("Error in _onImageStream: $e\n$st");
    } finally {
      await Future.delayed(Duration.zero);
      _isProcessing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _cameraController == null
          ? _loaderWidget()
          : !_cameraController!.value.isInitialized
          ? _loaderWidget()
          : CameraPreview(_cameraController!),
    );
  }

  Widget _loaderWidget() {
    return SizedBox.expand(
      child: ColoredBox(
        color: Colors.white.withAlpha((0.5 * 255).toInt()),
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

