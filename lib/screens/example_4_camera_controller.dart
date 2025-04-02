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

  void moveToLocationBound() {
    _controller?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(37.0, -123.0),
          northeast: LatLng(38.0, -121.0),
        ),
        0,
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      zoomGesturesEnabled: true,
      scrollGesturesEnabled: true,
      rotateGesturesEnabled: false,
      initialCameraPosition: CameraPosition(target: LatLng(37.7749, -122.4194), zoom: 12),
      onMapCreated: (controller) => _controller = controller,
      trafficEnabled: true,
      buildingsEnabled: true,
      indoorViewEnabled: true,
      onTap:(_) => _moveToLocation(),
    );
  }
}
