import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Example4CameraControllerScreen extends StatefulWidget {
  const Example4CameraControllerScreen({super.key});

  @override
  State<Example4CameraControllerScreen> createState() => _Example4CameraControllerScreenState();
}

class _Example4CameraControllerScreenState extends State<Example4CameraControllerScreen> {
  GoogleMapController? _controller;

  void _moveToLocation() {
    _controller?.animateCamera(CameraUpdate.newLatLngZoom(LatLng(40.7128, -74.0060), 15));
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(target: LatLng(37.7749, -122.4194), zoom: 12),
      onMapCreated: (controller) => _controller = controller,
      onTap:(_) => _moveToLocation(),
    );
  }
}
