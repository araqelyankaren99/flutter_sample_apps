import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Example1MapRenderingScreen extends StatefulWidget {
  const Example1MapRenderingScreen({super.key});

  @override
  State<Example1MapRenderingScreen> createState() => _Example1MapRenderingScreenState();
}

class _Example1MapRenderingScreenState extends State<Example1MapRenderingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(37.7749, -122.4194), // San Francisco
          zoom: 12,
        ),
        mapType: MapType.normal, // MapType.satellite, MapType.terrain, etc.
      ),
    );
  }
}
