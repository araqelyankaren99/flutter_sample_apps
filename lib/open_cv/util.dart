import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:opencv_dart/opencv_dart.dart' as cv;
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'dart:ffi';
import 'package:ffi/ffi.dart';

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

class DocumentEdgeDetector1 {
  // Preload OpenCV library to ensure symbols are available
  void preloadOpenCV() {
    try {
      final libName = Platform.isWindows
          ? 'opencv_world410.dll'
          : Platform.isMacOS
          ? 'libopencv_core.dylib'
          : 'libopencv.so';
      DynamicLibrary.open(libName);
      log('OpenCV library loaded successfully');
    } catch (e) {
      log('Failed to preload OpenCV: $e');
      rethrow;
    }
  }

  // Detect document edges, apply perspective transform, and return corner points
  Future<EdgeDetectionResult> detectAndCropImage(String inputPath, String outputPath) async {
    log('Starting detectAndCropImage with input: $inputPath, output: $outputPath');
    log('Checking input file existence...');
    final imageFile = File(inputPath);
    if (!imageFile.existsSync()) {
      log('Input file does not exist');
      throw Exception('Input image not found at $inputPath');
    }
    log('Input file exists, loading image...');
    preloadOpenCV(); // Preload OpenCV library
    try {
      final inputImage = cv.imread(inputPath, flags: cv.IMREAD_COLOR);
      log('Image loaded: ${inputImage.width}x${inputImage.height}');
      if (inputImage.isEmpty) {
        log('Loaded image is empty');
        throw Exception('Failed to load image at $inputPath');
      }

      // Convert to grayscale
      final gray = cv.cvtColor(inputImage, cv.COLOR_BGR2GRAY);
      log('Converted to grayscale');

      // Apply Gaussian blur
      final blurred = cv.gaussianBlur(gray, (11, 11), 0);
      log('Applied Gaussian blur');

      // Detect edges using Canny
      final edges = cv.canny(blurred, 10, 30, apertureSize: 3);
      log('Applied Canny edge detection');

      // Dilate edges to close gaps
      final kernel = cv.getStructuringElement(cv.MORPH_ELLIPSE, (8, 8));
      final dilated = cv.dilate(edges, kernel, iterations: 1);
      log('Dilated edges');

      // Find contours
      final (contours, hierarchy) = cv.findContours(dilated, cv.RETR_LIST, cv.CHAIN_APPROX_SIMPLE);
      log('Found ${contours.length} contours');

      // Find the largest quadrilateral
      List<cv.Point> bestSquare = [];
      double maxArea = 0;
      for (final contour in contours) {
        final approx = cv.approxPolyDP(contour, cv.arcLength(contour, true) * 0.02, true);
        if (approx.length == 4 && cv.isContourConvex(approx)) {
          final area = cv.contourArea(approx);
          if (area > 1000 && area > maxArea) {
            final maxCosine = _getMaxCosine(approx.toList());
            if (maxCosine < 0.3) {
              maxArea = area;
              bestSquare = approx.toList(); // Convert to List<cv.Point> for bestSquare
            }
          }
        }
      }

      // Fallback to default corners if no square found
      final originalWidth = inputImage.width.toDouble();
      final originalHeight = inputImage.height.toDouble();
      List<cv.Point> corners;
      if (maxArea == 0) {
        log('No valid quadrilateral found, using default corners');
        corners = _defaultCorners(originalWidth, originalHeight);
      } else {
        corners = _orderPoints(bestSquare);
        log('Selected quadrilateral corners: $corners');
      }

      // Debug: Draw corners on input image
      final debugImage = inputImage.clone();
      for (final corner in corners) {
        cv.circle(debugImage, cv.Point(corner.x, corner.y), 5, cv.Scalar(0, 255, 0, 0), thickness: 3);
      }
      final debugPath = outputPath.replaceAll('.png', '_debug_corners.png');
      cv.imwrite(debugPath, debugImage);
      log('Debug corners saved to $debugPath');

      // Convert corners to Point2f for perspective transform calculations
      final srcPoints = corners.map((p) => cv.Point2f(p.x.toDouble(), p.y.toDouble())).toList();
      final dstPoints = _calculateDestinationCorners(srcPoints);
      log('Source points: $srcPoints');
      log('Destination points: $dstPoints');

      // Convert to VecPoint for getPerspectiveTransform (workaround for library issue)
      // Note: getPerspectiveTransform should accept VecPoint2f per OpenCV C++ API.
      // Check for opencv_dart updates or report issue if VecPoint2f is not supported.
      final srcVec = cv.VecPoint.fromList(
        srcPoints.map((p) => cv.Point(p.x.toInt(), p.y.toInt())).toList(),
      );
      final dstVec = cv.VecPoint.fromList(
        dstPoints.map((p) => cv.Point(p.x.toInt(), p.y.toInt())).toList(),
      );
      log('Source points (VecPoint): $srcVec');
      log('Destination points (VecPoint): $dstVec');
      final matrix = cv.getPerspectiveTransform(srcVec, dstVec);
      log('Transform matrix: $matrix');
      final outputSize = (dstPoints[2].x.toInt(), dstPoints[2].y.toInt());
      log('Output size: $outputSize');
      final transformedImage = cv.warpPerspective(inputImage, matrix, outputSize, flags: cv.INTER_LINEAR);
      log('Applied perspective transform: ${transformedImage.width}x${transformedImage.height}');

      // Save transformed image
      final outputFile = File(outputPath);
      try {
        await outputFile.parent.create(recursive: true);
        cv.imwrite(outputPath, transformedImage);
        log('Transformed image saved to $outputPath');
      } catch (e) {
        log('Failed to save transformed image: $e');
        throw Exception('Failed to save transformed image: $e');
      }

      // Return normalized coordinates
      return EdgeDetectionResult(
        topLeft: Offset(corners[0].x / originalWidth, corners[0].y / originalHeight),
        topRight: Offset(corners[1].x / originalWidth, corners[1].y / originalHeight),
        bottomLeft: Offset(corners[3].x / originalWidth, corners[3].y / originalHeight),
        bottomRight: Offset(corners[2].x / originalWidth, corners[2].y / originalHeight),
      );
    } catch (e) {
      log('Error in detectAndCropImage: $e');
      rethrow;
    }
  }

  // Calculate maximum cosine angle to filter quadrilaterals
  double _getMaxCosine(List<cv.Point> points) {
    double maxCosine = 0;
    for (int j = 2; j < 5; j++) {
      final cosine = _getCosineAngleBetweenVectors(
        points[j % 4],
        points[j - 2],
        points[j - 1],
      ).abs();
      maxCosine = math.max(maxCosine, cosine);
    }
    return maxCosine;
  }

  // Calculate cosine of angle between vectors
  double _getCosineAngleBetweenVectors(cv.Point pt1, cv.Point pt2, cv.Point pt0) {
    final dx1 = pt1.x - pt0.x;
    final dy1 = pt1.y - pt0.y;
    final dx2 = pt2.x - pt0.x;
    final dy2 = pt2.y - pt0.y;
    return (dx1 * dx2 + dy1 * dy2) /
        math.sqrt((dx1 * dx1 + dy1 * dy1) * (dx2 * dx2 + dy2 * dy2) + 1e-10);
  }

  // Order points (top-left, top-right, bottom-right, bottom-left)
  List<cv.Point> _orderPoints(List<cv.Point> points) {
    final sums = points.map((p) => p.x + p.y).toList();
    final diffs = points.map((p) => p.y - p.x).toList();
    log('Point ordering - Sums: $sums, Diffs: $diffs');

    final rect = List<cv.Point>.filled(4, cv.Point(0, 0));
    // Top-left: smallest sum
    final minSumIdx = sums.indexWhere((s) => s == sums.reduce(math.min));
    rect[0] = points[minSumIdx];
    // Bottom-right: largest sum
    final maxSumIdx = sums.indexWhere((s) => s == sums.reduce(math.max));
    rect[2] = points[maxSumIdx];
    // Top-right: smallest difference
    final minDiffIdx = diffs.indexWhere((d) => d == diffs.reduce(math.min));
    rect[1] = points[minDiffIdx];
    // Bottom-left: largest difference
    final maxDiffIdx = diffs.indexWhere((d) => d == diffs.reduce(math.max));
    rect[3] = points[maxDiffIdx];

    return rect;
  }

  // Default corners for fallback
  List<cv.Point> _defaultCorners(double width, double height) {
    const margin = 0.05; // 5% margin
    return [
      cv.Point((width * margin).toInt(), (height * margin).toInt()),
      cv.Point((width * (1 - margin)).toInt(), (height * margin).toInt()),
      cv.Point((width * (1 - margin)).toInt(), (height * (1 - margin)).toInt()),
      cv.Point((width * margin).toInt(), (height * (1 - margin)).toInt()),
    ];
  }

  // Calculate destination corners for perspective transform
  List<cv.Point2f> _calculateDestinationCorners(List<cv.Point2f> pts) {
    final tl = pts[0];
    final tr = pts[1];
    final br = pts[2];
    final bl = pts[3];

    final widthA = math.sqrt(math.pow(br.x - bl.x, 2) + math.pow(br.y - bl.y, 2));
    final widthB = math.sqrt(math.pow(tr.x - tl.x, 2) + math.pow(tr.y - tl.y, 2));
    final maxWidth = math.max(widthA, widthB).toInt();

    final heightA = math.sqrt(math.pow(tr.x - br.x, 2) + math.pow(tr.y - br.y, 2));
    final heightB = math.sqrt(math.pow(tl.x - bl.x, 2) + math.pow(tl.y - bl.y, 2));
    final maxHeight = math.max(heightA, heightB).toInt();

    return [
      cv.Point2f(0, 0),
      cv.Point2f(maxWidth.toDouble(), 0),
      cv.Point2f(maxWidth.toDouble(), maxHeight.toDouble()),
      cv.Point2f(0, maxHeight.toDouble()),
    ];
  }
}