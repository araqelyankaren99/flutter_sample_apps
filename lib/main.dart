import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fgbg/flutter_fgbg.dart';
import 'package:flutter_sample_apps/open_cv/doc_detector_interface.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as image;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const AppLifecycleDisplayFGBG(),
    );
  }
}

class _CameraWidget extends StatefulWidget {
  const _CameraWidget();

  @override
  State<_CameraWidget> createState() => _CameraWidgetState();
}

class _CameraWidgetState extends State<_CameraWidget> {
  CameraController? _controller;
  late String _appTempDirectoryPath;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }
  Future<void> _initializeCamera() async {
    final directory = await getTemporaryDirectory();
    _appTempDirectoryPath = directory.path;
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      return;
    }
    _controller = CameraController(
      cameras.first,
      ResolutionPreset.max,
      enableAudio: false,
    );

    await _controller?.initialize();
    await _controller?.lockCaptureOrientation(DeviceOrientation.portraitUp);
    _controller?.setFlashMode(FlashMode.off);
    setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _detectEdgesEx() async {
      if (_controller?.value.isInitialized == true && _controller?.value.isTakingPicture == false){
        final captureImageFile = await _controller?.takePicture();
        if (captureImageFile == null) {
          return;
        }
        final captureImageFilePath = captureImageFile.path;
        if (!mounted || captureImageFilePath.isEmpty) {
          return;
        }

        imageCache.clear();

        final tempFilePath = '$_appTempDirectoryPath/temp.jpeg';
        final edgeDetectionResult = await DocDetectorInterface()
            .detectDocumentEdgesTest(captureImageFilePath, tempFilePath);
        final top = edgeDetectionResult.topLeft.dy;
        final left = edgeDetectionResult.bottomRight.dx;

        if (top == 0.0 && left == 1.0) {
          return;
        }
        if(!mounted){
          return;
        }
        final result = await ImageService().rotateCameraImage(sourceImage : XFile(tempFilePath),angle : 270);
        final resultPath = result.path;
        if(!mounted){
          return;
        }
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) =>
              ResultScreen(croppedFilePath: resultPath)),
        );
      }
    }

  Widget _cameraWidget() {
    if (_controller == null) {
      return const SizedBox.shrink();
    }

    return SizedBox.expand(
      child: Center(
          child: CameraPreview(_controller!),
      ),
    );
  }

  Widget _loaderWidget() {
    return SizedBox.expand(
      child: ColoredBox(
        color: Colors.white.withAlpha((0.5 * 255).toInt()),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _controller == null
          ? _loaderWidget()
          : _controller?.value.isInitialized == false
          ? _loaderWidget()
          : Stack(
        children: [
          _cameraWidget(),
          Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 25),
                child: ElevatedButton(onPressed: _detectEdgesEx, child: Icon(Icons.camera_alt)),
              )),
        ],
      ),
    );
  }
}

class ResultScreen extends StatelessWidget {
  const ResultScreen({
    super.key, this.croppedFilePath,
    this.borderRadius = 10,
    this.borderColor = const Color(0xFF34B6FF),
    this.width = 3,
  });

  final String? croppedFilePath;
  final double borderRadius;
  final Color borderColor;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: croppedFilePath == null
          ? const SizedBox.shrink()
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: Stack(
                children: [
                  Image.file(
                    File(croppedFilePath!),
                    fit: BoxFit.contain,
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(borderRadius),
                        border: Border.all(
                          color: borderColor,
                          width: width,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ),
    );
  }
}

class ImageService {
  const ImageService();

  ///Converting
  Future<String> convertFileToJpeg(File file) async{
    final bytes = file.readAsBytesSync();
    final base64 = base64Encode(bytes);
    final base64String = 'data:image/jpeg;base64,$base64';
    return base64String;
  }

  Future<XFile> convertImageToXFile(
      String path,
      image.Image pickedImage,
      ) async {
    final resultPort = ReceivePort();
    final args =
    _ImageToXFileConvertorInput(path, pickedImage, resultPort.sendPort);

    try {
      await Isolate.spawn<_ImageToXFileConvertorInput>(
        _convertImageToXFileIsolate,
        args,
        onError: resultPort.sendPort,
        onExit: resultPort.sendPort,
      );
    } on Object {
      resultPort.close();
      throw Exception();
    }
    final response = await resultPort.first;
    return response;
  }

  Future<image.Image> convertXFileToImage(XFile xFile) async {
    final resultPort = ReceivePort();
    final args = _XFileToImageConvertorInput(xFile, resultPort.sendPort);

    try {
      await Isolate.spawn<_XFileToImageConvertorInput>(
        _convertXFileToImageIsolate,
        args,
        onError: resultPort.sendPort,
        onExit: resultPort.sendPort,
      );
    } on Object {
      resultPort.close();
      throw Exception();
    }
    final response = await resultPort.first;
    return response;
  }

  ///Rotating
  image.Image rotateImage(
      image.Image sourceImage, {
        required int angle,
      }) {
    final rotatedImage = image.copyRotate(sourceImage, angle: angle);
    return rotatedImage;
  }

  Future<XFile> rotateCameraImage({
    required XFile sourceImage,
    required int angle,
  }) async {
    final image = await convertXFileToImage(sourceImage);
    final rotatedImage = rotateImage(image, angle: angle);
    final result = await convertImageToXFile(sourceImage.path, rotatedImage);
    return result;
  }

  Future<void> _convertImageToXFileIsolate(
      _ImageToXFileConvertorInput imageToXFileConvertorInput,
      ) async {
    try {
      final uInt8List = image.encodeJpg(imageToXFileConvertorInput.img);
      final tempFile =
      await File(imageToXFileConvertorInput.path).writeAsBytes(uInt8List);
      final res = XFile(tempFile.path);
      imageToXFileConvertorInput.sendPort.send(res);
    } on Exception catch (_) {
      throw Exception('Convert image to xFile failed');
    }
  }

  Future<void> _convertXFileToImageIsolate(
      _XFileToImageConvertorInput xFileToImageConvertorInput,
      ) async {
    final path = xFileToImageConvertorInput.xFile.path;
    var bytes = await File(path).readAsBytes();
    final result = image.decodeImage(bytes);
    if (result == null) {
      throw Exception('Convert xFile to image failed');
    }
    xFileToImageConvertorInput.sendPort.send(result);
  }
}

class _XFileToImageConvertorInput {
  const _XFileToImageConvertorInput(this.xFile, this.sendPort);

  final XFile xFile;
  final SendPort sendPort;
}

class _ImageToXFileConvertorInput {
  const _ImageToXFileConvertorInput(this.path, this.img, this.sendPort);

  final String path;
  final image.Image img;
  final SendPort sendPort;
}


class AppLifecycleDisplayFGBG extends StatefulWidget {
  const AppLifecycleDisplayFGBG({super.key});

  @override
  State<AppLifecycleDisplayFGBG> createState() => _AppLifecycleDisplayFGBGState();
}

class _AppLifecycleDisplayFGBGState extends State<AppLifecycleDisplayFGBG> {
  FGBGType _fgbgType = FGBGType.foreground;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FGBGNotifier(
          onEvent: (FGBGType fgBg){
            print(fgBg);
            Future.delayed(Duration(seconds: 1),(){
              setState(() {
                _fgbgType = fgBg;
              });
            });
          },
          child: Text('FG BG Type = $_fgbgType'),
        ),
      ),
    );
  }
}

class AppLifecycleDisplay extends StatefulWidget {
  const AppLifecycleDisplay({super.key});

  @override
  State<AppLifecycleDisplay> createState() => _AppLifecycleDisplayState();
}

class _AppLifecycleDisplayState extends State<AppLifecycleDisplay> {
  late final AppLifecycleListener _listener;
  final ScrollController _scrollController = ScrollController();
  final List<String> _states = <String>[];
  late AppLifecycleState? _state;

  @override
  void initState() {
    super.initState();
    _state = SchedulerBinding.instance.lifecycleState;
    _listener = AppLifecycleListener(
      onShow: () => _handleTransition('show'),
      onResume: () => _handleTransition('resume'),
      onHide: () => _handleTransition('hide'),
      onInactive: () => _handleTransition('inactive'),
      onPause: () => _handleTransition('pause'),
      onDetach: () => _handleTransition('detach'),
      onRestart: () => _handleTransition('restart'),
      onStateChange: _handleStateChange,
    );
    if (_state != null) {
      _states.add(_state!.name);
    }
  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }

  void _handleTransition(String name) {
    print('name = $name');
    setState(() {
      _states.add(name);
    });
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  void _handleStateChange(AppLifecycleState state) {
    setState(() {
      _state = state;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('App LifeCycle State'),
          elevation: 0,
        ),
        body: Center(
          child: SizedBox(
            width: 300,
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: <Widget>[
                  Text('Current State: ${_state ?? 'Not initialized yet'}'),
                  const SizedBox(height: 30),
                  Text('State History:\n  ${_states.join('\n  ')}'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
