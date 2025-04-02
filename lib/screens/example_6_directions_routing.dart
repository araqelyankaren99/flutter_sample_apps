import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sample_apps/constants.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:permission_handler/permission_handler.dart';

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
