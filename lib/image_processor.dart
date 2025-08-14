import 'package:camera/camera.dart';
import 'package:flutter_sample_apps/open_cv/doc_detector_interface.dart';
import 'package:flutter_sample_apps/utils/util.dart';

Future<EdgeDetectionResult?> processImage(CameraImage cameraImage , String outputFilePath) async {
  final bytes = convertCameraImageToUint8List(cameraImage);
  final width = cameraImage.width;
  final height = cameraImage.height;
  final edgeDetectionResult = await OpenCvEdgeDetector().processLiveStreamImage(
    bytes: bytes,
    outputPathStr: outputFilePath,
    imageHeight: height,
    imageWidth: width,
  );

  return edgeDetectionResult;
}