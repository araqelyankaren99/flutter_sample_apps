import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Direction {
  const Direction({
    required this.bounds,
    required this.polylinePoints,
    required this.totalDistance,
    required this.totalDuration,
  });

  factory Direction.fromMap(Map<String, dynamic> map) {
    /// Check if route is not available
    if ((map['routes'] as List).isNotEmpty) {
      /// Get route information

      final data = Map<String, dynamic>.from(map['routes'][0]);

      /// Bounds
      final northeast = data['bounds']['northeast'];
      final southwest = data['bounds']['southwest'];
      final bounds = LatLngBounds(
        northeast: LatLng(northeast['lat'], northeast['lng']),
        southwest: LatLng(southwest['lat'], southwest['lng']),
      );

      /// Distance & Duration
      var distance = '';
      var duration = '';
      if ((data['legs'] as List).isNotEmpty) {
        final leg = data['legs'][0];
        distance = leg['distance']['text'];
        duration = leg['duration']['text'];
      }

      return Direction(
        bounds: bounds,
        polylinePoints: PolylinePoints()
            .decodePolyline(data['overview_polyline']['points']),
        totalDistance: distance,
        totalDuration: duration,
      );
    }
    return Direction(
        bounds: LatLngBounds(
            southwest: const LatLng(0.0, 0.0),
            northeast: const LatLng(0.0, 0.0)),
        polylinePoints: [],
        totalDistance: '',
        totalDuration: '');
  }
  final LatLngBounds bounds;
  final List<PointLatLng> polylinePoints;
  final String totalDistance;
  final String totalDuration;
}
