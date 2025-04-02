import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Example3PolylinesPolygonsScreen extends StatefulWidget {
  const Example3PolylinesPolygonsScreen({super.key});

  @override
  State<Example3PolylinesPolygonsScreen> createState() => _Example3PolylinesPolygonsScreenState();
}

class _Example3PolylinesPolygonsScreenState extends State<Example3PolylinesPolygonsScreen> {
  Set<Polyline> polylines = {
    Polyline(
      polylineId: PolylineId('route1'),
      points: [
        LatLng(37.7749, -122.4194),
        LatLng(37.8044, -122.2711),
      ],
      color: Colors.blue,
      width: 5,
    ),
  };

  Set<Polygon> polygons = {
    Polygon(
      polygonId: PolygonId('area1'),
      points: [
        LatLng(37.7749, -122.4194),
        LatLng(37.7849, -122.4094),
        LatLng(37.7949, -122.4194),
      ],
      strokeColor: Colors.red,
      fillColor: Colors.red.withOpacity(0.3),
    ),
  };

  Set<Circle> circles = {
    Circle(
      circleId: CircleId('circle1'),
      center: LatLng(37.7749, -122.4194),
      radius: 1000, // in meters
      strokeColor: Colors.green,
      fillColor: Colors.green.withOpacity(0.2),
    ),
  };


  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(target: LatLng(37.7749, -122.4194), zoom: 12),
      polylines: polylines,
      polygons: polygons,
      circles: circles,
    );
  }
}
