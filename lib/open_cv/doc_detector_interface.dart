import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

//import 'package:DT/additions/string_extension.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class Coordinate extends Struct {
  @Double()
  external double x;

  @Double()
  external double y;
}

class NativeDetectionResult extends Struct {
  external Pointer<Coordinate> topLeft;
  external Pointer<Coordinate> topRight;
  external Pointer<Coordinate> bottomLeft;
  external Pointer<Coordinate> bottomRight;
}

class EdgeDetectionResult {
  EdgeDetectionResult({
    required this.topLeft,
    required this.topRight,
    required this.bottomLeft,
    required this.bottomRight,
  });

  Offset topLeft;
  Offset topRight;
  Offset bottomLeft;
  Offset bottomRight;

  @override
  String toString() => 'EdgeDetectionResult(topLeft : $topLeft ; topRight : $topRight ; bottomLeft : $bottomLeft ; bottomRight : $bottomRight)';
}

class ProcessImageArguments {
  const ProcessImageArguments(this.inputPath, this.outputPath);

  final String inputPath;
  final String outputPath;
}

class DetectDocumentEdgesInput {
  DetectDocumentEdgesInput(this.imageArguments, this.sendPort);

  ProcessImageArguments imageArguments;
  SendPort sendPort;
}

// C function signatures
typedef _CVersionFunc = Pointer<Utf8> Function();

typedef _CProcessImageFunc = Void Function(
    Pointer<Utf8>,
    Pointer<Utf8>,
    );

typedef _CDetectDocumentEdgesFunc = Pointer<NativeDetectionResult> Function(
    Pointer<Utf8>,
    Pointer<Utf8>,
    );

// typedef _CDetectDocumentEdgesExFunc = Pointer<NativeDetectionResult> Function(
//     Int32,
//     Int32,
//     Int32,
//     Pointer<Uint8>,
//     Pointer<Utf8>,
//     );
// typedef _CDetectDocumentEdgesExFunc = Pointer<NativeDetectionResult> Function(
//     int,
//     int,
//     int,
//     Pointer<Uint8>,
//     Pointer<Utf8>,
//     );

// Dart function signatures
typedef _VersionFunc = Pointer<Utf8> Function();
typedef _ProcessImageFunc = void Function(Pointer<Utf8>, Pointer<Utf8>);
typedef _DetectDocumentEdgesFunc = Pointer<NativeDetectionResult> Function(Pointer<Utf8>, Pointer<Utf8>);
// typedef _DetectDocumentEdgesExFunc = Pointer<NativeDetectionResult> Function(int, int, int, Pointer<Uint8>, Pointer<Utf8>);


/// Bind C functions to Dart
class DocDetectorInterface {

  factory DocDetectorInterface() {
    _instance ??= DocDetectorInterface._internal();
    return _instance!;
  }

  DocDetectorInterface._internal() {
    _nativeLib = Platform.isAndroid ?
    DynamicLibrary.open('libnative_opencv.so') : DynamicLibrary.process();
    // Looking for the functions
    _getVersion = _nativeLib.lookup<NativeFunction<_CVersionFunc>>('version')
        .asFunction();

    _processImage = _nativeLib
        .lookup<NativeFunction<_CProcessImageFunc>>('process_image')
        .asFunction();

    _detectDocument = _nativeLib
        .lookup<NativeFunction<_CDetectDocumentEdgesFunc>>(
        'detect_document_edges',)
        .asFunction();

    // _detectDocument = _nativeLib
    //     .lookup<NativeFunction<_CDetectDocumentEdgesFunc>>('detect_document_edges_ex')
    //     .asFunction();
  }
  static DocDetectorInterface? _instance;

  late _VersionFunc _getVersion;
  late _ProcessImageFunc _processImage;
  late _DetectDocumentEdgesFunc _detectDocument;
  // late _DetectDocumentEdgesExFunc _detectDocumentEx;

  late DynamicLibrary _nativeLib;

  String opencvVersion() {
    return _getVersion().toDartString();
  }

  void processImage(ProcessImageArguments args) {
    _processImage(
        args.inputPath.toNativeUtf8(), args.outputPath.toNativeUtf8(),);
  }

  EdgeDetectionResult detectDocumentEdges(ProcessImageArguments args) {
    final detectionResult = _detectDocument(
        args.inputPath.toNativeUtf8(), args.outputPath.toNativeUtf8(),)
        .ref;
    return EdgeDetectionResult(
        topLeft: Offset(
            detectionResult.topLeft.ref.x, detectionResult.topLeft.ref.y,),
        topRight: Offset(
            detectionResult.topRight.ref.x, detectionResult.topRight.ref.y,),
        bottomLeft: Offset(
            detectionResult.bottomLeft.ref.x, detectionResult.bottomLeft.ref.y,),
        bottomRight: Offset(detectionResult.bottomRight.ref.x,
            detectionResult.bottomRight.ref.y,),);
  }

  Future<EdgeDetectionResult> detectDocumentEdgesTest(String inputFilePath, String outputFilePath) async {

    final detectionResult = EdgeDetectionResult(
        topLeft: Offset.zero,
        topRight: const Offset(10, 00),
        bottomLeft: const Offset(0, 10),
        bottomRight: const Offset(10, 10),
    );

    if (inputFilePath.isEmpty) {
      return detectionResult;
    }

    // imageCache.clear();
    //
    // Directory tempDir = await getTemporaryDirectory();
    // String tempFilePath = tempDir.path + "temp.jpeg";

    // Creating a port for communication with isolate and arguments for entry point
    final resultPort = ReceivePort();
    final imageArgs = ProcessImageArguments(inputFilePath, outputFilePath);
    final args = DetectDocumentEdgesInput(imageArgs, resultPort.sendPort);

    try {
      // Spawning an isolate
      await Isolate.spawn<DetectDocumentEdgesInput>(
        startEdgeDetectionIsolate,
        args,
        onError: resultPort.sendPort,
        onExit: resultPort.sendPort,
      );
    } on Object {
      // check if sending the entrypoint to the new isolate failed.
      // If it did, the result port won’t get any message, and needs to be closed
      resultPort.close();
    }

    final response = await resultPort.first;

    //var completer = new Completer<EdgeDetectionResult>();
    if (response == null) {
      // this means the isolate exited without sending any results
      // TODO throw error
      return detectionResult;
    } else if (response is List) {
      // if the response is a list, this means an uncaught error occurred
      // final errorAsString = response[0];
      // final stackTraceAsString = response[1];
      // TODO throw error
      return detectionResult;
    } else {
      return response;
    }

    // // Making a variable to store a subscription in
    // StreamSubscription sub;
    // sub = port.listen((result) async {
    //   // Cancel a subscription after message received called
    //   await sub.cancel();
    //   //detectionResult = result;
    //   return result;
    // });
    // return detectionResult;
  }

  static Future<void> startEdgeDetectionIsolate(
      DetectDocumentEdgesInput edgeDetectionInput,) async {
    final result =
    DocDetectorInterface().detectDocumentEdges(edgeDetectionInput.imageArguments);
    edgeDetectionInput.sendPort.send(result);
  }

  bool isGettingDocPoints = false;
  Future detectDocumentEdgesEx(int width, int height,
      int bytesPerPixel, Uint8List bytes,
      Pointer<Utf8> outputPath,) async {

    if (isGettingDocPoints) {
      return;
    }

    isGettingDocPoints = true;

    final params = {
      'width': width,
      'height': height,
      'bytesPerPixel': bytesPerPixel,
      'bytes': bytes,
      'outputFilePath': outputPath.toString(),
    };

    compute(getDocumentEdgesIsolate, params)
        .then((value) {

      isGettingDocPoints = false;
      final detectionResult = value;
      return EdgeDetectionResult(
          topLeft: Offset(
              detectionResult.topLeft.ref.x, detectionResult.topLeft.ref.y,),
          topRight: Offset(
              detectionResult.topRight.ref.x, detectionResult.topRight.ref.y,),
          bottomLeft: Offset(
              detectionResult.bottomLeft.ref.x,
              detectionResult.bottomLeft.ref.y,),
          bottomRight: Offset(detectionResult.bottomRight.ref.x,
              detectionResult.bottomRight.ref.y,),);
    });

    /*/
    //Int32 strWidth = args.width;
    NativeDetectionResult detectionResult = _detectDocumentEx(
        width, height, bytesPerPixel, bytes, outputPath.toNativeUtf8())
        .ref;
    return EdgeDetectionResult(
        topLeft: Offset(
            detectionResult.topLeft.ref.x, detectionResult.topLeft.ref.y),
        topRight: Offset(
            detectionResult.topRight.ref.x, detectionResult.topRight.ref.y),
        bottomLeft: Offset(
            detectionResult.bottomLeft.ref.x, detectionResult.bottomLeft.ref.y),
        bottomRight: Offset(detectionResult.bottomRight.ref.x,
            detectionResult.bottomRight.ref.y));
  }
  */
  }
}

Future<NativeDetectionResult> getDocumentEdgesIsolate(Map params) async {
  final nativeLib = Platform.isAndroid ? DynamicLibrary.open('libnative_opencv.so')
      : DynamicLibrary.process();

  var getDocumentPoints = nativeLib
      .lookup<
      NativeFunction<
      NativeDetectionResult Function(
              Int32 width,
              Int32 height,
              Int32 bytesPerPixel,
              Pointer<Uint8> imgBytes,
              Pointer<Utf8> outputFilePath,)>>('detect_document_edges_ex')
      .asFunction<
      NativeDetectionResult Function(int width, int height, int bytesPerPixel,
          Pointer<Uint8> imgBytes, Pointer<Utf8> outputFilePath,)>();

  int width = params['width'];
  int height = params['height'];
  int bytesPerPixel = params['bytesPerPixel'];
  Uint8List bytes = params['bytes'];
  String outputFilePath = params['outputFilePath'];


  final buffer = calloc<Uint8>(bytes.length);
  buffer.asTypedList(bytes.length).setAll(0, bytes);

  final detResult = getDocumentPoints(width, height, bytesPerPixel, buffer, outputFilePath.toNativeUtf8());

  calloc.free(buffer);
  return detResult;
}

class NativeOpencv {
  NativeOpencv._();
  static const MethodChannel _channel =
      const MethodChannel('native_opencv');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
