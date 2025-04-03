import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Example12CameraMovementScreen extends StatefulWidget {
  const Example12CameraMovementScreen({super.key});

  @override
  State<Example12CameraMovementScreen> createState() => _Example12CameraMovementScreenState();
}

class _Example12CameraMovementScreenState extends State<Example12CameraMovementScreen> {
  late GoogleMapController _mapController;

  void _moveCamera() {
    _mapController.moveCamera(CameraUpdate.newLatLng(LatLng(37.7749, -122.4194))); // San Francisco
  }

  // Animate camera with zoom and tilt
  void _animateCamera() {
    _mapController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: LatLng(37.7749, -122.4194), // San Francisco
        zoom: 14,
        tilt: 30,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Camera Movements Example')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(37.7749, -122.4194), // San Francisco
          zoom: 10,
        ),
        onMapCreated: (controller) {
          _mapController = controller;
        },
        onCameraMove: (CameraPosition position) {
          // You can track camera movements if needed
          print('Camera moved to: $position');
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _moveCamera,
            heroTag: null,
            child: Icon(Icons.location_searching),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _animateCamera,
            heroTag: null,
            child: Icon(Icons.animation),
          ),
        ],
      ),
    );
  }
}
