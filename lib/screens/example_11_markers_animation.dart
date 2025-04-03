import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Example11MarkersAnimationScreen extends StatefulWidget {
  const Example11MarkersAnimationScreen({super.key});

  @override
  State<Example11MarkersAnimationScreen> createState() => _Example11MarkersAnimationScreenState();
}

class _Example11MarkersAnimationScreenState extends State<Example11MarkersAnimationScreen> {
  late GoogleMapController _mapController;
  Marker _marker = Marker(
    markerId: MarkerId('moving_marker'),
    position: LatLng(37.7749, -122.4194),
  );

  LatLng _currentPosition = LatLng(37.7749, -122.4194);
  LatLng _targetPosition = LatLng(37.7849, -122.4294);

  @override
  void initState() {
    super.initState();
    _startMovingMarker();
  }

  void _startMovingMarker() {
    Timer.periodic(Duration(milliseconds: 100), (timer) {
      double lat = _currentPosition.latitude +
          (_targetPosition.latitude - _currentPosition.latitude) * 0.1;
      double lng = _currentPosition.longitude +
          (_targetPosition.longitude - _currentPosition.longitude) * 0.1;

      setState(() {
        _currentPosition = LatLng(lat, lng);
        _marker = _marker.copyWith(positionParam: _currentPosition);
      });

      if ((lat - _targetPosition.latitude).abs() < 0.0001 &&
          (lng - _targetPosition.longitude).abs() < 0.0001) {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Marker Animation Example')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: LatLng(37.7749, -122.4194), zoom: 15),
        markers: {_marker},
        onMapCreated: (controller) => _mapController = controller,
      ),
    );
  }
}
