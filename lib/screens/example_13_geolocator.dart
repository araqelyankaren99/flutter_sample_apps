import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class Example13GeolocatorScreen extends StatefulWidget {
  const Example13GeolocatorScreen({super.key});

  @override
  State<Example13GeolocatorScreen> createState() => _Example13GeolocatorScreenState();
}

class _Example13GeolocatorScreenState extends State<Example13GeolocatorScreen> {
  late GoogleMapController _mapController;
  late LatLng _currentPosition = LatLng(0.0, 0.0);
  String _address = "Fetching address...";

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // Get current location of the user
  void _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });
    _getAddressFromLatLng(position.latitude, position.longitude);
  }

  // Get address from latitude and longitude
  void _getAddressFromLatLng(double latitude, double longitude) async {
    List<Placemark> placemarks = await GeocodingPlatform.instance
        ?.placemarkFromCoordinates(latitude, longitude) ?? [];
    setState(() {
      _address = placemarks.first.street ?? 'Address not found';
    });
    _mapController.animateCamera(CameraUpdate.newLatLng(_currentPosition));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Geolocation Example')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _currentPosition,
          zoom: 14,
        ),
        onMapCreated: (controller) {
          _mapController = controller;
        },
        markers: {
          Marker(
            markerId: MarkerId('current_location'),
            position: _currentPosition,
            infoWindow: InfoWindow(title: _address),
          ),
        },
      ),
    );
  }
}