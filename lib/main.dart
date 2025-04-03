import 'package:flutter/material.dart';
import 'package:flutter_sample_apps/screens/example_10_traffic.dart';
import 'package:flutter_sample_apps/screens/example_11_markers_animation.dart';
import 'package:flutter_sample_apps/screens/example_12_camera_movement.dart';
import 'package:flutter_sample_apps/screens/example_13_geolocator.dart';
import 'package:flutter_sample_apps/screens/example_14_measure_distance.dart';
import 'package:flutter_sample_apps/screens/example_15_real_time_location_tracking.dart';
import 'package:flutter_sample_apps/screens/example_16_street_view.dart';
import 'package:flutter_sample_apps/screens/example_1_map_rendering.dart';
import 'package:flutter_sample_apps/screens/example_2_custom_markers.dart';
import 'package:flutter_sample_apps/screens/example_3_polylines_polygons.dart';
import 'package:flutter_sample_apps/screens/example_4_camera_controller.dart';
import 'package:flutter_sample_apps/screens/example_5_geocoding.dart';
import 'package:flutter_sample_apps/screens/example_6_directions_routing.dart';
import 'package:flutter_sample_apps/screens/example_7_add_current_location.dart';
import 'package:flutter_sample_apps/screens/example_8_add_styling.dart';
import 'package:flutter_sample_apps/screens/example_9_clustering.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: ListView(
            children: const [
              _Example1RenderingButton(),
              _Example2CustomMarkersButton(),
              _Example3PolylinesPolygonsButton(),
              _Example4CameraControllerButton(),
              _Example5GeocodingButton(),
              _Example6DirectionsRoutingButton(),
              _Example7AddCurrentLocationButton(),
              _Example8AddStylingButton(),
              _Example9ClusteringButton(),
              _Example10TrafficButton(),
              _Example11MarkersAnimationButton(),
              _Example12CameraMovementButton(),
              _Example13GeolocatorButton(),
              _Example14MeasureDistanceButton(),
              _Example15RealTimeLocationTrackingButton(),
              _Example16StreetViewButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Example1RenderingButton extends StatelessWidget {
  const _Example1RenderingButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: () => _onTap(context), child: Text('Map Rendering'));
  }

  void _onTap(BuildContext context){
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => Example1MapRenderingScreen()));
  }
}

class _Example2CustomMarkersButton extends StatelessWidget {
  const _Example2CustomMarkersButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: () => _onTap(context), child: Text('Custom Markers'));
  }

  void _onTap(BuildContext context){
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => Example2CustomMarkersScreen()));
  }
}

class _Example3PolylinesPolygonsButton extends StatelessWidget {
  const _Example3PolylinesPolygonsButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: () => _onTap(context), child: Text('Polylines & Polygons'));
  }

  void _onTap(BuildContext context){
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => Example3PolylinesPolygonsScreen()));
  }
}

class _Example4CameraControllerButton extends StatelessWidget {
  const _Example4CameraControllerButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: () => _onTap(context), child: Text('Camera Control'));
  }

  void _onTap(BuildContext context){
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => Example4CameraControllerScreen()));
  }
}

class _Example5GeocodingButton extends StatelessWidget {
  const _Example5GeocodingButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: () => _onTap(context), child: Text('Geocoding'));
  }

  void _onTap(BuildContext context){
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => Example5GeocodingScreen()));
  }
}

class _Example6DirectionsRoutingButton extends StatelessWidget {
  const _Example6DirectionsRoutingButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: () => _onTap(context), child: Text('Directions & Routing'));
  }

  void _onTap(BuildContext context){
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => Example6DirectionsRoutingScreen()));
  }
}

class _Example7AddCurrentLocationButton extends StatelessWidget {
  const _Example7AddCurrentLocationButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: () => _onTap(context), child: Text('Current Location'));
  }

  void _onTap(BuildContext context){
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => Example7AddCurrentLocationScreen()));
  }
}

class _Example8AddStylingButton extends StatelessWidget {
  const _Example8AddStylingButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: () => _onTap(context), child: Text('Map Styling'));
  }

  void _onTap(BuildContext context){
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => Example8AddStylingScreen()));
  }
}

class _Example9ClusteringButton extends StatelessWidget {
  const _Example9ClusteringButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: () => _onTap(context), child: Text('Clustering'));
  }

  void _onTap(BuildContext context){
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => Example9ClusteringScreen()));
  }
}

class _Example10TrafficButton extends StatelessWidget {
  const _Example10TrafficButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: () => _onTap(context), child: Text('Traffic'));
  }

  void _onTap(BuildContext context){
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => Example10TrafficScreen()));
  }
}

class _Example11MarkersAnimationButton extends StatelessWidget {
  const _Example11MarkersAnimationButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: () => _onTap(context), child: Text('Markers animation'));
  }

  void _onTap(BuildContext context){
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => Example11MarkersAnimationScreen()));
  }
}

class _Example12CameraMovementButton extends StatelessWidget {
  const _Example12CameraMovementButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: () => _onTap(context), child: Text('Animate camera'));
  }

  void _onTap(BuildContext context){
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => Example12CameraMovementScreen()));
  }
}

class _Example13GeolocatorButton extends StatelessWidget {
  const _Example13GeolocatorButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: () => _onTap(context), child: Text('Geolocator'));
  }

  void _onTap(BuildContext context){
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => Example13GeolocatorScreen()));
  }
}

class _Example14MeasureDistanceButton extends StatelessWidget {
  const _Example14MeasureDistanceButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: () => _onTap(context), child: Text('Measure Distance'));
  }

  void _onTap(BuildContext context){
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => Example14MeasureDistanceScreen()));
  }
}

class _Example15RealTimeLocationTrackingButton extends StatelessWidget {
  const _Example15RealTimeLocationTrackingButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: () => _onTap(context), child: Text('Real-Time Location Tracking'));
  }

  void _onTap(BuildContext context){
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => Example15RealTimeLocationTrackingScreen()));
  }
}

class _Example16StreetViewButton extends StatelessWidget {
  const _Example16StreetViewButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: () => _onTap(context), child: Text('Street View'));
  }

  void _onTap(BuildContext context){
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => Example16StreetViewScreen()));
  }
}