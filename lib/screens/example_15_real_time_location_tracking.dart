import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class Example15RealTimeLocationTrackingScreen extends StatefulWidget {
  const Example15RealTimeLocationTrackingScreen({super.key});

  @override
  State<Example15RealTimeLocationTrackingScreen> createState() => _Example15RealTimeLocationTrackingScreenState();
}

class _Example15RealTimeLocationTrackingScreenState extends State<Example15RealTimeLocationTrackingScreen> {
  late GoogleMapController _mapController;
  late Location _location;
  late LatLng _currentLocation;

  @override
  void initState() {
    super.initState();
    _location = Location();
    _currentLocation = LatLng(37.7749, -122.4194); // Default location
    _trackUserLocation();
  }

  // Track user location in real-time
  void _trackUserLocation() {
    _location.onLocationChanged.listen((LocationData currentLocation) {
      setState(() {
        _currentLocation = LatLng(currentLocation.latitude!, currentLocation.longitude!);
      });

      // Move the camera to the updated location
      _mapController.animateCamera(CameraUpdate.newLatLng(_currentLocation));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Real-Time Location Tracking')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _currentLocation,
          zoom: 14,
        ),
        onMapCreated: (controller) {
          _mapController = controller;
        },
        myLocationEnabled: true, // Show the user's location on the map
        myLocationButtonEnabled: true, // Show the "Locate me" button
        markers: {
          Marker(
            markerId: MarkerId('user_location'),
            position: _currentLocation,
          ),
        },
      ),
    );
  }
}
