import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
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
  String toString() =>
      'EdgeDetectionResult(topLeft : $topLeft ; topRight : $topRight ; bottomLeft : $bottomLeft ; bottomRight : $bottomRight)';
}


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

    _detectDocumentStreaming = _nativeLib
        .lookup<NativeFunction<_CDetectDocumentEdgesExCppStreamingFunc>>(
      'detect_document_edges_ex',
    )
        .asFunction();
  }
  static DocDetectorInterface? _instance;
  late _DartDetectDocumentEdgesStreamingExFunc _detectDocumentStreaming;
  late DynamicLibrary _nativeLib;


  Future<EdgeDetectionResult> processLiveStreamImage({
    required Uint8List bytes,
    required String outputPathStr,
    required int imageWidth,
    required int imageHeight,
    required
  }) async {
    final int bytesPerPixel = 4;

    final result = await Isolate.run(() => _processImageInIsolate({
      'width': imageWidth,
      'height': imageHeight,
      'bytesPerPixel': bytesPerPixel,
      'rgbBytes': bytes,
      'outputPathStr': outputPathStr,
    }));

    return result;
  }
}

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
