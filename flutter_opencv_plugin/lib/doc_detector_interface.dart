import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

base class Coordinate extends Struct {
  @Double()
  external double x;

  @Double()
  external double y;
}

base class NativeDetectionResult extends Struct {
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
  String toString() => 'EdgeDetectionResult(topLeft: $topLeft; topRight: $topRight; bottomLeft: $bottomLeft; bottomRight: $bottomRight)';
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
typedef _CProcessImageFunc = Void Function(Pointer<Utf8>, Pointer<Utf8>);
typedef _CDetectDocumentEdgesFunc = Pointer<NativeDetectionResult> Function(Pointer<Utf8>, Pointer<Utf8>);

// Dart function signatures
typedef _VersionFunc = Pointer<Utf8> Function();
typedef _ProcessImageFunc = void Function(Pointer<Utf8>, Pointer<Utf8>);
typedef _DetectDocumentEdgesFunc = Pointer<NativeDetectionResult> Function(Pointer<Utf8>, Pointer<Utf8>);

const _androidDynamicLibraryName = 'libflutter_opencv_plugin.so';
class DocDetectorInterface {
  factory DocDetectorInterface() {
    _instance ??= DocDetectorInterface._internal();
    return _instance!;
  }

  DocDetectorInterface._internal() {
    _nativeLib = Platform.isAndroid
        ? DynamicLibrary.open(_androidDynamicLibraryName) // Correct library name
        : DynamicLibrary.process();
    _getVersion = _nativeLib.lookup<NativeFunction<_CVersionFunc>>('version').asFunction();
    _processImage = _nativeLib.lookup<NativeFunction<_CProcessImageFunc>>('process_image').asFunction();
    _detectDocument = _nativeLib.lookup<NativeFunction<_CDetectDocumentEdgesFunc>>('detect_document_edges').asFunction();
  }

  static DocDetectorInterface? _instance;

  late _VersionFunc _getVersion;
  late _ProcessImageFunc _processImage;
  late _DetectDocumentEdgesFunc _detectDocument;
  late DynamicLibrary _nativeLib;

  String opencvVersion() {
    return _getVersion().toDartString();
  }

  void processImage(ProcessImageArguments args) {
    _processImage(args.inputPath.toNativeUtf8(), args.outputPath.toNativeUtf8());
  }

  EdgeDetectionResult detectDocumentEdges(ProcessImageArguments args) {
    final detectionResult = _detectDocument(args.inputPath.toNativeUtf8(), args.outputPath.toNativeUtf8()).ref;
    return EdgeDetectionResult(
      topLeft: Offset(detectionResult.topLeft.ref.x, detectionResult.topLeft.ref.y),
      topRight: Offset(detectionResult.topRight.ref.x, detectionResult.topRight.ref.y),
      bottomLeft: Offset(detectionResult.bottomLeft.ref.x, detectionResult.bottomLeft.ref.y),
      bottomRight: Offset(detectionResult.bottomRight.ref.x, detectionResult.bottomRight.ref.y),
    );
  }

  Future<EdgeDetectionResult> detectDocumentEdgesTest(String inputFilePath, String outputFilePath) async {
    final detectionResult = EdgeDetectionResult(
      topLeft: Offset.zero,
      topRight: const Offset(10, 0),
      bottomLeft: const Offset(0, 10),
      bottomRight: const Offset(10, 10),
    );

    if (inputFilePath.isEmpty) {
      return detectionResult;
    }

    final resultPort = ReceivePort();
    final imageArgs = ProcessImageArguments(inputFilePath, outputFilePath);
    final args = DetectDocumentEdgesInput(imageArgs, resultPort.sendPort);

    try {
      await Isolate.spawn<DetectDocumentEdgesInput>(
        startEdgeDetectionIsolate,
        args,
        onError: resultPort.sendPort,
        onExit: resultPort.sendPort,
      );
    } on Object {
      resultPort.close();
      return detectionResult;
    }

    final response = await resultPort.first;

    if (response == null || response is List) {
      return detectionResult;
    } else {
      return response;
    }
  }

  static Future<void> startEdgeDetectionIsolate(DetectDocumentEdgesInput edgeDetectionInput) async {
    final result = DocDetectorInterface().detectDocumentEdges(edgeDetectionInput.imageArguments);
    edgeDetectionInput.sendPort.send(result);
  }

  bool isGettingDocPoints = false;

  Future<EdgeDetectionResult> detectDocumentEdgesEx(int width, int height, int bytesPerPixel, Uint8List bytes, String outputPath) async {
    if (isGettingDocPoints) {
      return EdgeDetectionResult(
        topLeft: Offset.zero,
        topRight: Offset.zero,
        bottomLeft: Offset.zero,
        bottomRight: Offset.zero,
      );
    }

    isGettingDocPoints = true;

    final params = {
      'width': width,
      'height': height,
      'bytesPerPixel': bytesPerPixel,
      'bytes': bytes,
      'outputFilePath': outputPath,
    };

    final detectionResult = await compute(getDocumentEdgesIsolate, params);
    isGettingDocPoints = false;

    return EdgeDetectionResult(
      topLeft: Offset(detectionResult.topLeft.ref.x, detectionResult.topLeft.ref.y),
      topRight: Offset(detectionResult.topRight.ref.x, detectionResult.topRight.ref.y),
      bottomLeft: Offset(detectionResult.bottomLeft.ref.x, detectionResult.bottomLeft.ref.y),
      bottomRight: Offset(detectionResult.bottomRight.ref.x, detectionResult.bottomRight.ref.y),
    );
  }
}

Future<NativeDetectionResult> getDocumentEdgesIsolate(Map params) async {
  final nativeLib = Platform.isAndroid
      ? DynamicLibrary.open(_androidDynamicLibraryName) // Correct library name
      : DynamicLibrary.process();

  final getDocumentPoints = nativeLib.lookup<
      NativeFunction<
          Pointer<NativeDetectionResult> Function(
              Int32,
              Int32,
              Int32,
              Pointer<Uint8>,
              Pointer<Utf8>,
              )>>('detect_document_edges_ex').asFunction<
      Pointer<NativeDetectionResult> Function(
          int,
          int,
          int,
          Pointer<Uint8>,
          Pointer<Utf8>,
          )>();

  int width = params['width'];
  int height = params['height'];
  int bytesPerPixel = params['bytesPerPixel'];
  Uint8List bytes = params['bytes'];
  String outputFilePath = params['outputFilePath'];

  final buffer = calloc<Uint8>(bytes.length);
  buffer.asTypedList(bytes.length).setAll(0, bytes);

  final detResult = getDocumentPoints(width, height, bytesPerPixel, buffer, outputFilePath.toNativeUtf8());

  calloc.free(buffer);
  return detResult.ref;
}