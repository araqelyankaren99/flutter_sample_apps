import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong2/latlong.dart' as latLng;

class Example14MeasureDistanceScreen extends StatefulWidget {
  const Example14MeasureDistanceScreen({super.key});

  @override
  State<Example14MeasureDistanceScreen> createState() => _Example14MeasureDistanceScreenState();
}

class _Example14MeasureDistanceScreenState extends State<Example14MeasureDistanceScreen> {
  late GoogleMapController _mapController;
  LatLng _startPoint = LatLng(37.7749, -122.4194); // San Francisco
  LatLng _endPoint = LatLng(37.7849, -122.4094); // Nearby location
  String _distance = 'Distance: 0 meters';

  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _calculateDistance();
    _addPolyline();
  }

  // Calculate distance using the latlong package
  void _calculateDistance() {
    var distance = latLng.Distance();
    var distanceInMeters = distance.call(
      latLng.LatLng(_startPoint.latitude, _startPoint.longitude),
      latLng.LatLng(_endPoint.latitude, _endPoint.longitude),
    );
    setState(() {
      _distance = 'Distance: ${distanceInMeters.toStringAsFixed(2)} meters';
    });
  }

  // Add polyline to show path between points
  void _addPolyline() {
    _polylines.add(Polyline(
      polylineId: PolylineId('path'),
      points: [_startPoint, _endPoint],
      color: Colors.blue,
      width: 5,
    ));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _startPoint,
                  zoom: 14,
                ),
                onMapCreated: (controller) {
                  _mapController = controller;
                },
                polylines: _polylines,
              ),
            ),
            SizedBox(height: 20),
            Text(_distance, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
