import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sample_apps/constants.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

class Example6DirectionsRoutingScreen extends StatefulWidget {
  const Example6DirectionsRoutingScreen({super.key});

  @override
  State<Example6DirectionsRoutingScreen> createState() => _Example6DirectionsRoutingScreenState();
}

class _Example6DirectionsRoutingScreenState extends State<Example6DirectionsRoutingScreen> {
  final LatLng _origin = LatLng(37.7749, -122.4194); // San Francisco
  final LatLng _destination = LatLng(34.0522, -118.2437); // Los Angeles
  final Set<Polyline> _polylines = {};
  List<LatLng> polylineCoordinates = [];

  @override
  void initState() {
    super.initState();
    _getPolyline(); // Fetch polyline when screen loads
  }

  Future<void> requestLocationPermission() async {
    var status = await Permission.locationWhenInUse.request();
    if (status.isGranted) {
      print("Permission granted");
    } else if (status.isDenied) {
      print("Permission denied");
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  Future<void> _getPolyline() async {
    await requestLocationPermission();
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      request: PolylineRequest(
          origin: PointLatLng(_origin.latitude,_origin.longitude),
          destination: PointLatLng(_destination.latitude,_destination.longitude),
          mode: TravelMode.driving,
      ),
      googleApiKey: apiKey,
    );

    if (result.points.isNotEmpty) {
      polylineCoordinates.clear();
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }

      setState(() {
        _polylines.add(
          Polyline(
            polylineId: PolylineId("route"),
            color: Colors.blue,
            points: polylineCoordinates,
            width: 5,
          ),
        );
      });
    } else {
      if (kDebugMode) {
        print("Error: ${result.errorMessage}");
      }
    }
  }

  Future<void> _getDirections() async {
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${_origin.latitude},${_origin.longitude}&destination=${_destination.latitude},${_destination.longitude}&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    final data = json.decode(response.body);

    if (data['routes'].isNotEmpty) {
      final String polyline = data['routes'][0]['overview_polyline']['points'];
      final List<LatLng> points = _decodePolyline(polyline);

      setState(() {
        _polylines.add(
          Polyline(
            polylineId: PolylineId('route'),
            points: points,
            color: Colors.blue,
            width: 5,
          ),
        );
      });
    }
  }

  List<LatLng> _decodePolyline(String polyline) {
    List<LatLng> points = [];
    int index = 0;
    int len = polyline.length;
    int lat = 0;
    int lng = 0;

    // Ensure that the polyline string is not empty.
    if (polyline.isEmpty) {
      return points;
    }

    while (index < len) {
      int shift = 0;
      int result = 0;

      // Decode latitude
      do {
        int b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (polyline.codeUnitAt(index - 1) >= 0x20);

      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      // Decode longitude
      shift = 0;
      result = 0;

      do {
        int b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (polyline.codeUnitAt(index - 1) >= 0x20);

      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      // Convert the lat and lng to real coordinates (scaled by 1E5)
      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: _origin, zoom: 6),
        markers: {
          Marker(markerId: MarkerId("origin"), position: _origin),
          Marker(markerId: MarkerId("destination"), position: _destination),
        },
        polylines: _polylines,
      ),
    );
  }
}
