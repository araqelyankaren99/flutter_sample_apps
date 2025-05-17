import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

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
      'EdgeDetectionResult(topLeft: $topLeft, topRight: $topRight, bottomLeft: $bottomLeft, bottomRight: $bottomRight)';
}

class MyObjectDetector {
  Interpreter? _interpreter;
  static const String _modelPath = 'assets/models/ssd_mobilenet.tflite';
  static const double confidenceThreshold = 0.5;
  static const int edgeThreshold = 100;

  // Initialize the TensorFlow Lite interpreter
  Future<void> initialize() async {
    try {
      _interpreter = await loadModel();
      log('Model initialized successfully');
    } catch (e) {
      log('Failed to initialize model: $e');
      throw Exception('Failed to initialize model: $e');
    }
  }

  Future<Interpreter> loadModel() async {
    log('Loading interpreter options...');
    final interpreterOptions = InterpreterOptions();

    // Use XNNPACK Delegate for Android
    if (Platform.isAndroid) {
      interpreterOptions.addDelegate(XNNPackDelegate());
    }

    // Use Metal Delegate for iOS with fallback to CPU
    if (Platform.isIOS) {
      try {
        interpreterOptions.addDelegate(GpuDelegate());
      } catch (e) {
        log('Failed to initialize GpuDelegate, falling back to CPU: $e');
      }
    }

    log('Loading interpreter from $_modelPath...');
    try {
      final interpreter = await Interpreter.fromAsset(_modelPath, options: interpreterOptions);
      // Verify input and output tensor types
      final inputTensor = interpreter.getInputTensor(0);
      final outputTensor = interpreter.getOutputTensor(0);
      log('Input tensor type: ${inputTensor.type}');
      log('Output tensor type: ${outputTensor.type}');
      return interpreter;
    } catch (e) {
      log('Failed to load model: $e');
      throw Exception('Failed to load model: $e');
    }
  }

  // Detect objects, detect edges, crop image, correct skew, and return corner points
  Future<EdgeDetectionResult> detectAndCropImage(String inputPath, String outputPath) async {
    // Load and preprocess image
    final imageFile = File(inputPath);
    if (!imageFile.existsSync()) {
      throw Exception('Input image not found at $inputPath');
    }
    final inputImage = img.decodeImage(imageFile.readAsBytesSync());
    if (inputImage == null) {
      throw Exception('Failed to decode image at $inputPath');
    }
    final resizedImage = img.copyResize(inputImage, width: 300, height: 300); // Model expects 300x300

    // Prepare input tensor
    final input = _preprocessImage(resizedImage);

    // Initialize output tensors dynamically
    _interpreter ??= await loadModel();
    final outputShapes = _interpreter!.getOutputTensor(0).shape; // [1, numDetections, 4]
    final numDetectionsMax = outputShapes[1];
    final output = {
      0: List<dynamic>.filled(1 * numDetectionsMax * 4, 0.0).reshape([1, numDetectionsMax, 4]), // Bounding boxes
      1: List<dynamic>.filled(1 * numDetectionsMax, 0.0).reshape([1, numDetectionsMax]), // Class scores
      2: List<dynamic>.filled(1 * numDetectionsMax, 0.0).reshape([1, numDetectionsMax]), // Class IDs
      3: List<dynamic>.filled(1, 0.0).reshape([1]), // Number of detections
    };

    // Run inference
    try {
      _interpreter!.runForMultipleInputs([input], output);
    } catch (e) {
      log('Inference failed: $e');
      throw Exception('Inference failed: $e');
    }

    // Process output with type conversion
    final boxes = (output[0] as List)
        .map((batch) => (batch as List)
        .map((box) => (box as List).map((val) => (val as num).toDouble()).toList())
        .toList())
        .toList();
    final scores = (output[1] as List).map((batch) => (batch as List).map((val) => (val as num).toDouble()).toList()).toList();
    final numDetections = (output[3] as List)[0].toInt();

    // Find the best detection
    double maxScore = 0.0;
    List<double>? bestBox;
    for (int i = 0; i < numDetections && i < numDetectionsMax; i++) {
      if (scores[0][i] > maxScore && scores[0][i] > confidenceThreshold) {
        maxScore = scores[0][i];
        bestBox = boxes[0][i]; // [ymin, xmin, ymax, xmax]
      }
    }

    if (bestBox == null) {
      throw Exception('No object detected with confidence > $confidenceThreshold');
    }

    // Scale bounding box to original image size
    final originalWidth = inputImage.width;
    final originalHeight = inputImage.height;
    final box = [
      bestBox[1] * originalWidth, // left (xmin)
      bestBox[0] * originalHeight, // top (ymin)
      bestBox[3] * originalWidth, // right (xmax)
      bestBox[2] * originalHeight, // bottom (ymax)
    ];

    // Edge detection within bounding box
    final edgePoints = _detectEdges(inputImage, box);

    // Refine bounding box based on edges
    final refinedBox = _refineBoundingBox(box, edgePoints, originalWidth, originalHeight);

    // Validate and crop image
    final cropX = refinedBox[0].toInt();
    final cropY = refinedBox[1].toInt();
    final cropWidth = (refinedBox[2] - refinedBox[0]).toInt();
    final cropHeight = (refinedBox[3] - refinedBox[1]).toInt();
    if (cropWidth <= 0 || cropHeight <= 0) {
      throw Exception('Invalid crop dimensions: width=$cropWidth, height=$cropHeight');
    }
    final croppedImage = img.copyCrop(
      inputImage,
      x: cropX,
      y: cropY,
      width: cropWidth,
      height: cropHeight,
    );

    // Estimate skew angle, prioritizing bottom edge
    final skewAngle = _estimateSkewAngle(edgePoints, cropWidth, cropHeight,cropX,cropY);
    log('Estimated skew angle: $skewAngle degrees');

    // Rotate the cropped image
    final correctedImage = img.copyRotate(
      croppedImage,
      angle: -skewAngle, // Negative to rotate clockwise if needed
      interpolation: img.Interpolation.cubic, // Smooth rotation
    );

    // Save corrected image with explicit RGB handling
    final outputFile = File(outputPath);
    try {
      await outputFile.parent.create(recursive: true);
      // Ensure RGBA format is handled correctly
      final rgbImage = img.Image(
        width: correctedImage.width,
        height: correctedImage.height,
        numChannels: 3, // Force RGB
      );
      for (var y = 0; y < correctedImage.height; y++) {
        for (var x = 0; x < correctedImage.width; x++) {
          final pixel = correctedImage.getPixel(x, y);
          rgbImage.setPixelRgb(x, y, pixel.r, pixel.g, pixel.b);
        }
      }
      await outputFile.writeAsBytes(img.encodePng(rgbImage));
      log('Corrected image saved to $outputPath');
    } catch (e) {
      log('Failed to save corrected image: $e');
      throw Exception('Failed to save corrected image: $e');
    }

    // Compute new corner points for the corrected image
    final correctedWidth = correctedImage.width.toDouble();
    final correctedHeight = correctedImage.height.toDouble();
    // Apply rotation matrix to original corners for precision
    final centerX = cropX + cropWidth / 2;
    final centerY = cropY + cropHeight / 2;
    final radians = -skewAngle * math.pi / 180;
    final cosTheta = math.cos(radians);
    final sinTheta = math.sin(radians);

    List<Offset> rotatePoint(double x, double y) {
      final dx = x - centerX;
      final dy = y - centerY;
      final newX = centerX + (dx * cosTheta - dy * sinTheta);
      final newY = centerY + (dx * sinTheta + dy * cosTheta);
      return [Offset(newX, newY)];
    }

    final originalCorners = [
      Offset(refinedBox[0], refinedBox[1]), // topLeft
      Offset(refinedBox[2], refinedBox[1]), // topRight
      Offset(refinedBox[0], refinedBox[3]), // bottomLeft
      Offset(refinedBox[2], refinedBox[3]), // bottomRight
    ];
    final correctedCorners = originalCorners
        .asMap()
        .map((i, corner) => MapEntry(i, rotatePoint(corner.dx, corner.dy)[0]))
        .values
        .toList();

    // Return corner points as EdgeDetectionResult
    return EdgeDetectionResult(
      topLeft: correctedCorners[0],
      topRight: correctedCorners[1],
      bottomLeft: correctedCorners[2],
      bottomRight: correctedCorners[3],
    );
  }

  // Preprocess image for model input (uint8)
  List<List<List<List<int>>>> _preprocessImage(img.Image image) {
    final input = List.generate(1, (_) => List.generate(300, (_) => List.generate(300, (_) => List.filled(3, 0))));
    for (var y = 0; y < 300; y++) {
      for (var x = 0; x < 300; x++) {
        final pixel = image.getPixel(x, y);
        input[0][y][x][0] = pixel.r.toInt(); // uint8 (0-255)
        input[0][y][x][1] = pixel.g.toInt(); // uint8 (0-255)
        input[0][y][x][2] = pixel.b.toInt(); // uint8 (0-255)
      }
    }
    return input;
  }

  // Detect edges within bounding box using Sobel filter
  List<List<int>> _detectEdges(img.Image image, List<double> box) {
    final cropX = box[0].toInt().clamp(0, image.width - 1);
    final cropY = box[1].toInt().clamp(0, image.height - 1);
    final cropWidth = (box[2] - box[0]).toInt().clamp(1, image.width - cropX);
    final cropHeight = (box[3] - box[1]).toInt().clamp(1, image.height - cropY);

    try {
      final cropped = img.copyCrop(
        image,
        x: cropX,
        y: cropY,
        width: cropWidth,
        height: cropHeight,
      );
      // Light Gaussian blur to reduce noise
      final blurred = img.gaussianBlur(cropped, radius: 1);
      final gray = img.grayscale(blurred);
      final sobel = img.sobel(gray);
      final edgePoints = <List<int>>[];
      for (var y = 0; y < sobel.height; y++) {
        for (var x = 0; x < sobel.width; x++) {
          final pixel = sobel.getPixel(x, y);
          if (pixel.r > edgeThreshold) {
            edgePoints.add([x + cropX, y + cropY]);
          }
        }
      }
      log('Detected ${edgePoints.length} edge points');
      return edgePoints;
    } catch (e) {
      log('Edge detection failed: $e');
      return [];
    }
  }

  // Refine bounding box based on edge points
  List<double> _refineBoundingBox(List<double> box, List<List<int>> edgePoints, int width, int height) {
    if (edgePoints.isEmpty) {
      log('No edge points detected, using original box');
      return box;
    }
    final xCoords = edgePoints.map((p) => p[0]).toList();
    final yCoords = edgePoints.map((p) => p[1]).toList();
    final left = xCoords.reduce((a, b) => a < b ? a : b).toDouble().clamp(0.0, width - 1.0);
    final top = yCoords.reduce((a, b) => a < b ? a : b).toDouble().clamp(0.0, height - 1.0);
    final right = xCoords.reduce((a, b) => a > b ? a : b).toDouble().clamp(left + 1.0, width.toDouble());
    final bottom = yCoords.reduce((a, b) => a > b ? a : b).toDouble().clamp(top + 1.0, height.toDouble());
    return [left, top, right, bottom];
  }

  // Estimate skew angle using Hough Transform for bottom edge
  double _estimateSkewAngle(List<List<int>> edgePoints, int cropWidth, int cropHeight, int cropX, int cropY) {
    if (edgePoints.length < 4) {
      log('Insufficient edge points for skew estimation: ${edgePoints.length}');
      return 0.0;
    }

    // Filter edge points within the cropped region to reduce noise
    final filteredPoints = edgePoints.where((p) {
      final x = p[0];
      final y = p[1];
      return x >= cropX && x < cropX + cropWidth && y >= cropY && y < cropY + cropHeight;
    }).toList();

    log('Filtered ${filteredPoints.length} edge points within crop region');

    if (filteredPoints.length < 4) {
      log('Insufficient filtered edge points: ${filteredPoints.length}');
      return 0.0;
    }

    // Try linear regression on bottom edge points (bottom 30% of the cropped image)
    final bottomEdgePoints = filteredPoints.where((p) => p[1] >= cropY + cropHeight * 0.7).toList();
    log('Found ${bottomEdgePoints.length} bottom edge points (bottom 30%)');

    double bestAngle = 0.0;

    if (bottomEdgePoints.length >= 4) {
      // Sort points by x-coordinate for outlier rejection
      final sortedPoints = bottomEdgePoints..sort((a, b) => a[0].compareTo(b[0]));
      final lowerIdx = bottomEdgePoints.length ~/ 10; // ~10th percentile
      final upperIdx = bottomEdgePoints.length - lowerIdx - 1; // ~90th percentile

      if (lowerIdx < upperIdx) {
        final selectedPoints = sortedPoints.sublist(lowerIdx, upperIdx + 1);
        double sumX = 0.0, sumY = 0.0, sumXY = 0.0, sumXX = 0.0;
        final n = selectedPoints.length;
        for (var point in selectedPoints) {
          final x = point[0].toDouble();
          final y = point[1].toDouble();
          sumX += x;
          sumY += y;
          sumXY += x * y;
          sumXX += x * x;
        }
        final denominator = n * sumXX - sumX * sumX;
        if (denominator.abs() > 1e-6) {
          final slope = (n * sumXY - sumX * sumY) / denominator;
          bestAngle = math.atan(slope) * 180 / math.pi;
          log('Bottom edge angle: $bestAngle degrees (from $n points)');
          if (bestAngle.abs() <= 45.0) {
            return bestAngle.clamp(-45.0, 45.0);
          }
          log('Bottom edge angle too extreme: $bestAngle, falling back');
        } else {
          log('Cannot compute bottom edge slope, falling back to top edge');
        }
      } else {
        log('Insufficient points after outlier rejection, falling back to top edge');
      }
    } else {
      log('Insufficient bottom edge points, falling back to top edge');
    }

    // Fallback to top edge linear regression (top 30% of the cropped image)
    final topEdgePoints = filteredPoints.where((p) => p[1] < cropY + cropHeight * 0.3).toList();
    log('Found ${topEdgePoints.length} top edge points (top 30%)');

    if (topEdgePoints.length < 4) {
      log('Insufficient top edge points: ${topEdgePoints.length}, assuming no skew');
      return 0.0;
    }

    // Sort points by x-coordinate for outlier rejection
    final sortedPoints = topEdgePoints..sort((a, b) => a[0].compareTo(b[0]));
    final lowerIdx = topEdgePoints.length ~/ 10; // ~10th percentile
    final upperIdx = topEdgePoints.length - lowerIdx - 1; // ~90th percentile

    if (lowerIdx >= upperIdx) {
      log('Insufficient top edge points after outlier rejection, assuming no skew');
      return 0.0;
    }

    final selectedPoints = sortedPoints.sublist(lowerIdx, upperIdx + 1);
    double sumX = 0.0, sumY = 0.0, sumXY = 0.0, sumXX = 0.0;
    final n = selectedPoints.length;
    for (var point in selectedPoints) {
      final x = point[0].toDouble();
      final y = point[1].toDouble();
      sumX += x;
      sumY += y;
      sumXY += x * y;
      sumXX += x * x;
    }
    final denominator = n * sumXX - sumX * sumX;
    if (denominator.abs() < 1e-6) {
      log('Cannot compute top edge slope, assuming no skew');
      return 0.0;
    }
    final slope = (n * sumXY - sumX * sumY) / denominator;
    bestAngle = math.atan(slope) * 180 / math.pi;
    log('Top edge angle: $bestAngle degrees (from $n points)');

    return bestAngle.clamp(-45.0, 45.0);
  }

  // Clean up
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    log('Interpreter disposed');
  }
}