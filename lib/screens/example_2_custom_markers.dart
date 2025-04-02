import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Example2CustomMarkersScreen extends StatefulWidget {
  const Example2CustomMarkersScreen({super.key});

  @override
  State<Example2CustomMarkersScreen> createState() => _Example2CustomMarkersScreenState();
}

class _Example2CustomMarkersScreenState extends State<Example2CustomMarkersScreen> {
  Set<Marker> markers = {
    Marker(
      markerId: MarkerId('marker1'),
      position: LatLng(37.7749, -122.4194),
      infoWindow: InfoWindow(title: 'San Francisco'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    ),
  };

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(target: LatLng(37.7749, -122.4194), zoom: 12),
      markers: markers,
    );
  }
}
