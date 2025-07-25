import 'dart:typed_data';
import 'package:camera/camera.dart';

Future<Uint8List?> convertCameraImageToRGBA(CameraImage image) async {
  switch (image.format.group) {
    case ImageFormatGroup.bgra8888:
      return _convertBGRA8888ToRGBA(image);

    case ImageFormatGroup.yuv420:
      return _convertYUV420ToRGBA(image);

    default:
      return null;
  }
}

Uint8List _convertBGRA8888ToRGBA(CameraImage image) {
  final plane = image.planes[0];
  final inputBytes = plane.bytes;
  final pixelCount = image.width * image.height;
  final outputBytes = Uint8List(pixelCount * 4); // RGBA = 4 bytes per pixel

  for (int i = 0; i < pixelCount; i++) {
    final b = inputBytes[i * 4];
    final g = inputBytes[i * 4 + 1];
    final r = inputBytes[i * 4 + 2];
    final a = inputBytes[i * 4 + 3];

    // Convert BGRA → RGBA
    outputBytes[i * 4] = r;
    outputBytes[i * 4 + 1] = g;
    outputBytes[i * 4 + 2] = b;
    outputBytes[i * 4 + 3] = a;
  }

  return outputBytes;
}

Uint8List _convertYUV420ToRGBA(CameraImage image) {
  final width = image.width;
  final height = image.height;

  final yPlane = image.planes[0];
  final uPlane = image.planes[1];
  final vPlane = image.planes[2];

  final yRowStride = yPlane.bytesPerRow;
  final uvRowStride = uPlane.bytesPerRow;
  final uvPixelStride = uPlane.bytesPerPixel!;

  final yBytes = yPlane.bytes;
  final uBytes = uPlane.bytes;
  final vBytes = vPlane.bytes;

  final outputBytes = Uint8List(width * height * 4);

  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      final uvX = x ~/ 2;
      final uvY = y ~/ 2;

      final yIndex = y * yRowStride + x;
      final uvIndex = uvY * uvRowStride + uvX * uvPixelStride;

      final Y = yBytes[yIndex].toDouble();
      final U = uBytes[uvIndex].toDouble() - 128;
      final V = vBytes[uvIndex].toDouble() - 128;

      // YUV → RGB conversion
      double R = Y + 1.403 * V;
      double G = Y - 0.344 * U - 0.714 * V;
      double B = Y + 1.770 * U;

      int r = R.clamp(0, 255).toInt();
      int g = G.clamp(0, 255).toInt();
      int b = B.clamp(0, 255).toInt();

      final index = (y * width + x) * 4;
      outputBytes[index] = r;
      outputBytes[index + 1] = g;
      outputBytes[index + 2] = b;
      outputBytes[index + 3] = 255; // full alpha
    }
  }

  return outputBytes;
}
