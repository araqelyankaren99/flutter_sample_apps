import 'package:camera/camera.dart';
import 'package:flutter_sample_apps/open_cv/doc_detector_interface.dart';
import 'package:flutter_sample_apps/utils/util.dart';

Future<EdgeDetectionResult?> processImage(CameraImage cameraImage , String outputFilePath) async {
  final bytes = convertCameraImageToUint8List(cameraImage);
  final width = cameraImage.width;
  final height = cameraImage.height;
  final edgeDetectionResult = await DocDetectorInterface().processLiveStreamImage(
    bytes: bytes,
    outputPathStr: outputFilePath,
    imageHeight: height,
    imageWidth: width,
  );

  final top = edgeDetectionResult.topLeft.dy;
  final left = edgeDetectionResult.bottomRight.dx;

  if (top == 0.0 && left == 1.0) {
    return null;
  }
  return edgeDetectionResult;
}