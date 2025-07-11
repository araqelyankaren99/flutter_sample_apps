import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class Example18LiveTrackingScreen extends StatefulWidget {
  const Example18LiveTrackingScreen({super.key});

  @override
  State<Example18LiveTrackingScreen> createState() =>
      _Example18LiveTrackingScreenState();
}

class _Example18LiveTrackingScreenState
    extends State<Example18LiveTrackingScreen> {
  late GoogleMapController _mapController;
  LatLng _currentLocation = LatLng(37.7749, -122.4194);
  late Location _location;
  late Marker _marker = Marker(
    markerId: MarkerId('currentLocationMarker'),
    position: _currentLocation,
    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
  );
  String _speed = '0';
  StreamSubscription<LocationData>? _locationSubscription;
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  late LocationData _locationData;

  @override
  void initState() {
    super.initState();
   _onInit();
  }

  Future<void> _onInit() async {
    _location = Location();
    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    _trackUserLocation();
  }

  void _trackUserLocation() {
    _locationSubscription = _location.onLocationChanged.listen(_onLocationChange);
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  void _onLocationChange(LocationData currentLocation) {
    final speed = currentLocation.speed;
    if(speed != null){
      final speedToKm = (speed * 3.6).toInt();
      _speed = speedToKm > 0 ? speedToKm.toString() : '0';
      setState(() {});
    }
    final latitude = currentLocation.latitude;
    final longitude = currentLocation.longitude;
    if (latitude != null && longitude != null) {
      final latLng = LatLng(latitude, longitude);
      _currentLocation = latLng;
      setState(() {});
    }

    _marker = _marker.copyWith(positionParam: _currentLocation);
    _mapController.animateCamera(CameraUpdate.newLatLng(_currentLocation));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: (){},child: Text(_speed)),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _currentLocation,
          zoom: 14,
        ),
        markers: {_marker},
        onMapCreated: (controller) {
          _mapController = controller;
        },
      ),
    );
  }
}
