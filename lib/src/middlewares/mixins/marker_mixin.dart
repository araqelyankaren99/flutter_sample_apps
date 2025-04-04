import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sample_apps/src/models/order.dart';
import 'package:flutter_sample_apps/src/style.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

mixin MarkerMixin<T extends StatefulWidget> on State<T> {
  final ValueNotifier<List<Marker>> markers = ValueNotifier([]);
  List<Circle> circles = [];

  /// Update marker position on map
  Future<void> updateMarkerAndCircle(LatLng newLocationData,
      {Uint8List? imageMarker}) async {
    final markerData = await _getBytesFromCanvas(40, 40);

    final latitude = newLocationData.latitude;
    final longitude = newLocationData.longitude;
    resetMarker(markerId: 'updatedLocation');
    addMarker(LatLng(latitude, longitude), 'updatedLocation', markerData,
        circleColor: blackColor);

    if (imageMarker != null) {
      addMarker(LatLng(latitude, longitude), 'updatedLocationIcon', imageMarker,
          withCircle: false, zIndex: 100, offset: const Offset(0.5, 1.0));
    }
  }

  /// Set markers to GoogleMap
  Future<void> setMarkers(Order order) async {
    final marker = await _getBytesFromCanvas(40, 40);
    resetMarker();
    addMarker(
        LatLng(order.fromLat ?? 0.0, order.fromLng ?? 0.0), 'from', marker);
    addMarker(LatLng(order.toLat ?? 0.0, order.toLng ?? 0.0), 'to', marker);
  }

  /// Remove marker from map
  void resetMarker({String markerId = ''}) {
    if (markerId.isNotEmpty) {
      markers.value
          .removeWhere((element) => element.markerId.value == markerId);
      circles.removeWhere((element) => element.circleId.value == markerId);
    } else {
      markers.value = [];
      circles = [];
    }
  }

  /// Add marker to markers list
  void addMarker(LatLng latLng, String id, Uint8List markerData,
      {bool withCircle = true,
      Color circleColor = azureRadianceColor,
      double zIndex = 3,
      Offset offset = const Offset(0.5, 0.5)}) {
    if (latLng.latitude != 0.0 && latLng.longitude != 0.0) {
      markers.value = List.from(markers.value)
        ..add(Marker(
            markerId: MarkerId(id),
            position: latLng,
            zIndex: zIndex,
            flat: true,
            anchor: offset,
            icon: BitmapDescriptor.fromBytes(markerData)));
      if (withCircle) {
        circles.add(Circle(
            circleId: CircleId(id),
            radius: 50,
            zIndex: 3,
            strokeWidth: 1,
            strokeColor: circleColor.withAlpha(60),
            center: latLng,
            fillColor: circleColor.withAlpha(60)));
      }
    }
  }

  void disposeMarkers() {
    markers.dispose();
  }
}

extension _MarkerExtension on MarkerMixin {
  /// Create resizeable point marker
  Future<Uint8List> _getBytesFromCanvas(int width, int height) async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final paint = Paint()..color = azureRadianceColor;
    const radius = Radius.circular(20.0);
    canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(0.0, 0.0, width.toDouble(), height.toDouble()),
          topLeft: radius,
          topRight: radius,
          bottomLeft: radius,
          bottomRight: radius,
        ),
        paint);
    final img = await pictureRecorder.endRecording().toImage(width, height);
    var data = await img.toByteData(format: ui.ImageByteFormat.png);
    if (data != null) {
      return data.buffer.asUint8List();
    } else {
      data = await rootBundle.load('assets/images/location_point.png');
      return data.buffer.asUint8List();
    }
  }
}
