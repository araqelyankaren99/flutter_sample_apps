import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'package:camera/camera.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

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
  String toString() =>
      'EdgeDetectionResult(topLeft : $topLeft ; topRight : $topRight ; bottomLeft : $bottomLeft ; bottomRight : $bottomRight)';
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

typedef _CProcessImageFunc = Void Function(
    Pointer<Utf8>,
    Pointer<Utf8>,
    );

typedef _CDetectDocumentEdgesFunc = Pointer<NativeDetectionResult> Function(
    Pointer<Utf8>,
    Pointer<Utf8>,
    );

typedef _CDetectDocumentEdgesExCppStreamingFunc = Pointer<NativeDetectionResult> Function(
    Int32,
    Int32,
    Int32,
    Pointer<Uint8>,
    Pointer<Utf8>,
    );

typedef _DartDetectDocumentEdgesStreamingExFunc = Pointer<NativeDetectionResult> Function(
    int,
    int,
    int,
    Pointer<Uint8>,
    Pointer<Utf8>,
    );

// Dart function signatures
typedef _ProcessImageFunc = void Function(Pointer<Utf8>, Pointer<Utf8>);
typedef _DetectDocumentEdgesFunc = Pointer<NativeDetectionResult> Function(
    Pointer<Utf8>,
    Pointer<Utf8>,
    );

/// Bind C functions to Dart
class DocDetectorInterface {
  factory DocDetectorInterface() {
    _instance ??= DocDetectorInterface._internal();
    return _instance!;
  }

  DocDetectorInterface._internal() {
    _nativeLib = Platform.isAndroid
        ? DynamicLibrary.open('libnative_opencv.so')
        : DynamicLibrary.process();

    _processImage = _nativeLib
        .lookup<NativeFunction<_CProcessImageFunc>>('process_image')
        .asFunction();

    _detectDocument = _nativeLib
        .lookup<NativeFunction<_CDetectDocumentEdgesFunc>>(
      'detect_document_edges',
    )
        .asFunction();

    _detectDocumentStreaming = _nativeLib
        .lookup<NativeFunction<_CDetectDocumentEdgesExCppStreamingFunc>>(
      'detect_document_edges_ex',
    )
        .asFunction();
  }
  static DocDetectorInterface? _instance;

  late _ProcessImageFunc _processImage;
  late _DetectDocumentEdgesFunc _detectDocument;
  late _DartDetectDocumentEdgesStreamingExFunc _detectDocumentStreaming;

  late DynamicLibrary _nativeLib;

  void processImage(ProcessImageArguments args) {
    _processImage(
      args.inputPath.toNativeUtf8(),
      args.outputPath.toNativeUtf8(),
    );
  }

  EdgeDetectionResult detectDocumentEdges(ProcessImageArguments args) {
    final detectionResult = _detectDocument(
      args.inputPath.toNativeUtf8(),
      args.outputPath.toNativeUtf8(),
    ).ref;
    return EdgeDetectionResult(
      topLeft: Offset(
        detectionResult.topLeft.ref.x,
        detectionResult.topLeft.ref.y,
      ),
      topRight: Offset(
        detectionResult.topRight.ref.x,
        detectionResult.topRight.ref.y,
      ),
      bottomLeft: Offset(
        detectionResult.bottomLeft.ref.x,
        detectionResult.bottomLeft.ref.y,
      ),
      bottomRight: Offset(
        detectionResult.bottomRight.ref.x,
        detectionResult.bottomRight.ref.y,
      ),
    );
  }

  Future<EdgeDetectionResult> detectDocumentEdgesTest(
      String inputFilePath,
      String outputFilePath,
      ) async {
    final detectionResult = EdgeDetectionResult(
      topLeft: Offset.zero,
      topRight: const Offset(10, 00),
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
    }

    final response = await resultPort.first;

    if (response == null) {
      return detectionResult;
    } else if (response is List) {
      return detectionResult;
    } else {
      return response;
    }
  }

  static Future<void> startEdgeDetectionIsolate(
      DetectDocumentEdgesInput edgeDetectionInput,
      ) async {
    final result =
    DocDetectorInterface().detectDocumentEdges(edgeDetectionInput.imageArguments);
    edgeDetectionInput.sendPort.send(result);
  }

  bool isGettingDocPoints = false;
  Future detectDocumentEdgesEx(
      int width,
      int height,
      int bytesPerPixel,
      Uint8List bytes,
      Pointer<Utf8> outputPath,
      ) async {
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

    compute(getDocumentEdgesIsolate, params).then((value) {
      isGettingDocPoints = false;
      final detectionResult = value;
      return EdgeDetectionResult(
        topLeft: Offset(
          detectionResult.topLeft.ref.x,
          detectionResult.topLeft.ref.y,
        ),
        topRight: Offset(
          detectionResult.topRight.ref.x,
          detectionResult.topRight.ref.y,
        ),
        bottomLeft: Offset(
          detectionResult.bottomLeft.ref.x,
          detectionResult.bottomLeft.ref.y,
        ),
        bottomRight: Offset(
          detectionResult.bottomRight.ref.x,
          detectionResult.bottomRight.ref.y,
        ),
      );
    });
  }

  Future<EdgeDetectionResult> processLiveStreamImage({
    required CameraImage cameraImage,
    required String outputPathStr,
  }) async {
    final width = cameraImage.width;
    final height = cameraImage.height;

    final rgbBytes = convertCameraImageToRGBA8888(cameraImage);
    final int bytesPerPixel = 4;

    final result = await Isolate.run(() => _processImageInIsolate({
      'width': width,
      'height': height,
      'bytesPerPixel': bytesPerPixel,
      'rgbBytes': rgbBytes,
      'outputPathStr': outputPathStr,
    }));

    return result;
  }
}

Future<NativeDetectionResult> getDocumentEdgesIsolate(Map params) async {
  final nativeLib = Platform.isAndroid
      ? DynamicLibrary.open('libnative_opencv.so')
      : DynamicLibrary.process();

  var getDocumentPoints = nativeLib
      .lookup<
      NativeFunction<
          NativeDetectionResult Function(
              Int32,
              Int32,
              Int32,
              Pointer<Uint8>,
              Pointer<Utf8>,
              )>>('detect_document_edges_ex')
      .asFunction<
      NativeDetectionResult Function(
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

  final detResult = getDocumentPoints(
    width,
    height,
    bytesPerPixel,
    buffer,
    outputFilePath.toNativeUtf8(),
  );

  calloc.free(buffer);
  return detResult;
}

Uint8List convertCameraImageToRGBA8888(CameraImage cameraImage) {
  switch (cameraImage.format.group) {
    case ImageFormatGroup.bgra8888:
      return _convertBGRA8888ToRGBA8888(cameraImage);
    case ImageFormatGroup.yuv420:
    // Adjust swapUV param to true if colors are incorrect on your Android device
      return _convertYUV420ToRGBA8888(cameraImage, swapUV: false);
    default:
      throw Exception("Unsupported image format: ${cameraImage.format.group}");
  }
}

Uint8List _convertYUV420ToRGBA8888(CameraImage image, {bool swapUV = false}) {
  final width = image.width;
  final height = image.height;

  final yPlane = image.planes[0];
  final uPlane = image.planes[1];
  final vPlane = image.planes[2];

  final uvRowStride = uPlane.bytesPerRow;
  final uvPixelStride = uPlane.bytesPerPixel!;

  final rgba = Uint8List(width * height * 4);

  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      final yIndex = y * yPlane.bytesPerRow + x;
      final uvIndex = (y ~/ 2) * uvRowStride + (x ~/ 2) * uvPixelStride;

      final Y = yPlane.bytes[yIndex];
      final U = swapUV ? vPlane.bytes[uvIndex] : uPlane.bytes[uvIndex];
      final V = swapUV ? uPlane.bytes[uvIndex] : vPlane.bytes[uvIndex];

      final c = Y - 16;
      final d = U - 128;
      final e = V - 128;

      int r = clamp((298 * c + 409 * e + 128) >> 8);
      int g = clamp((298 * c - 100 * d - 208 * e + 128) >> 8);
      int b = clamp((298 * c + 516 * d + 128) >> 8);

      final index = (y * width + x) * 4;
      rgba[index] = r;
      rgba[index + 1] = g;
      rgba[index + 2] = b;
      rgba[index + 3] = 255;
    }
  }
  return rgba;
}

Uint8List _convertBGRA8888ToRGBA8888(CameraImage cameraImage) {
  final plane = cameraImage.planes[0];
  final bytes = plane.bytes;

  final length = bytes.lengthInBytes;
  final rgbaBytes = Uint8List(length);

  for (int i = 0; i < length; i += 4) {
    final b = bytes[i];
    final g = bytes[i + 1];
    final r = bytes[i + 2];
    final a = bytes[i + 3];

    rgbaBytes[i] = r;
    rgbaBytes[i + 1] = g;
    rgbaBytes[i + 2] = b;
    rgbaBytes[i + 3] = a;
  }

  return rgbaBytes;
}

int clamp(int val) => val < 0 ? 0 : (val > 255 ? 255 : val);

Future<EdgeDetectionResult> _processImageInIsolate(Map<String, dynamic> args) async {
  final int width = args['width'];
  final int height = args['height'];
  final int bytesPerPixel = args['bytesPerPixel'];
  final Uint8List rgbBytes = args['rgbBytes'];
  final String outputPathStr = args['outputPathStr'];

  final nativeLib = Platform.isAndroid
      ? DynamicLibrary.open('libnative_opencv.so')
      : DynamicLibrary.process();

  final detectDocumentStreaming = nativeLib.lookupFunction<
      Pointer<NativeDetectionResult> Function(
          Int32, Int32, Int32, Pointer<Uint8>, Pointer<Utf8>),
      Pointer<NativeDetectionResult> Function(
          int, int, int, Pointer<Uint8>, Pointer<Utf8>)>('detect_document_edges_ex');

  final Pointer<Uint8> imgPointer = malloc.allocate<Uint8>(rgbBytes.length);
  try {
    imgPointer.asTypedList(rgbBytes.length).setAll(0, rgbBytes);

    final Pointer<Utf8> outputPathPtr = outputPathStr.toNativeUtf8();
    try {
      final Pointer<NativeDetectionResult> nativeResult = detectDocumentStreaming(
        width,
        height,
        bytesPerPixel,
        imgPointer,
        outputPathPtr,
      );

      final result = nativeResult.ref;

      return EdgeDetectionResult(
        topLeft: Offset(result.topLeft.ref.x, result.topLeft.ref.y),
        topRight: Offset(result.topRight.ref.x, result.topRight.ref.y),
        bottomLeft: Offset(result.bottomLeft.ref.x, result.bottomLeft.ref.y),
        bottomRight: Offset(result.bottomRight.ref.x, result.bottomRight.ref.y),
      );
    } finally {
      malloc.free(outputPathPtr);
    }
  } finally {
    malloc.free(imgPointer);
  }
}
