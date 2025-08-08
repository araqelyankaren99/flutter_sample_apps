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

typedef _CDetectDocumentEdgesExCppStreamingFunc =
    Pointer<NativeDetectionResult> Function(
      Int32,
      Int32,
      Int32,
      Pointer<Uint8>,
      Pointer<Utf8>,
    );

typedef _DartDetectDocumentEdgesStreamingExFunc =
    Pointer<NativeDetectionResult> Function(
      int,
      int,
      int,
      Pointer<Uint8>,
      Pointer<Utf8>,
    );

/// Bind C functions to Dart
class DocDetectorInterface {
  factory DocDetectorInterface() {
    _instance ??= DocDetectorInterface._internal();
    return _instance!;
  }

  DocDetectorInterface._internal();

  static DocDetectorInterface? _instance;

  Future<EdgeDetectionResult> processLiveStreamImage({
    required Uint8List bytes,
    required String outputPathStr,
    required int imageWidth,
    required int imageHeight,
  }) async {
    final int bytesPerPixel = 4;

    final result = await Isolate.run(
      () => _processImageInIsolate(
        width: imageWidth,
        height: imageHeight,
        bytesPerPixel: bytesPerPixel,
        rgbBytes: bytes,
        outputPathStr : outputPathStr,
      ),
    );

    return result;
  }
}

Future<EdgeDetectionResult> _processImageInIsolate({
  required int width,
  required int height,
  required int bytesPerPixel,
  required Uint8List rgbBytes,
  required String outputPathStr,
}) async {

  final nativeLib =
      Platform.isAndroid
          ? DynamicLibrary.open('libnative_opencv.so')
          : DynamicLibrary.process();

  final detectDocumentStreaming = nativeLib.lookupFunction<
    _CDetectDocumentEdgesExCppStreamingFunc,
    _DartDetectDocumentEdgesStreamingExFunc
  >('detect_document_edges_streaming');

  final Pointer<Uint8> imgPointer = malloc.allocate<Uint8>(rgbBytes.length);
  try {
    imgPointer.asTypedList(rgbBytes.length).setAll(0, rgbBytes);

    final Pointer<Utf8> outputPathPtr = outputPathStr.toNativeUtf8();
    try {
      final Pointer<NativeDetectionResult> nativeResult =
          detectDocumentStreaming(
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
