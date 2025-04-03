import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Example17LatLngBoundsScreen extends StatefulWidget {
  const Example17LatLngBoundsScreen({super.key});

  @override
  State<Example17LatLngBoundsScreen> createState() => _Example17LatLngBoundsState();
}

class _Example17LatLngBoundsState extends State<Example17LatLngBoundsScreen> {
  late GoogleMapController _mapController;
  final LatLngBounds _bounds = LatLngBounds(
    southwest: LatLng(37.704, -122.525),
    northeast: LatLng(37.812, -122.348),
  );

  // Function to calculate the center of LatLngBounds
  LatLng getBoundsCenter(LatLngBounds bounds) {
    double lat = (bounds.southwest.latitude + bounds.northeast.latitude) / 2;
    double lng = (bounds.southwest.longitude + bounds.northeast.longitude) / 2;
    return LatLng(lat, lng);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Map Bounds Example')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(37.7749, -122.4194), // San Francisco
          zoom: 12,
        ),
        onMapCreated: (controller) {
          _mapController = controller;
          _mapController.moveCamera(
            CameraUpdate.newLatLngBounds(_bounds, 50), // Set camera bounds
          );
        },
        onCameraMove: (position) {
          if (!_bounds.contains(position.target)) {
            LatLng center = getBoundsCenter(_bounds); // Calculate bounds center
            _mapController.moveCamera(
              CameraUpdate.newLatLng(center),
            ); // Keep the camera within bounds
          }
        },
      ),
    );
  }
}