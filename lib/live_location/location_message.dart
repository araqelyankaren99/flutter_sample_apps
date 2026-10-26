import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';

/// A single location update exchanged over the socket.
class LocationMessage {
  const LocationMessage({
    required this.latitude,
    required this.longitude,
    required this.heading,
    required this.timestamp,
  });

  static const String type = 'location';

  final double latitude;
  final double longitude;
  final double heading;
  final DateTime timestamp;

  LatLng get latLng => LatLng(latitude, longitude);

  String encode() => jsonEncode({
        'type': type,
        'lat': latitude,
        'lng': longitude,
        'heading': heading,
        'timestamp': timestamp.millisecondsSinceEpoch,
      });

  /// Returns null when [raw] is not a location message.
  static LocationMessage? tryParse(dynamic raw) {
    if (raw is! String) {
      return null;
    }
    try {
      final json = jsonDecode(raw);
      if (json case {'type': type, 'lat': num lat, 'lng': num lng}) {
        final heading = json['heading'];
        final timestamp = json['timestamp'];
        return LocationMessage(
          latitude: lat.toDouble(),
          longitude: lng.toDouble(),
          heading: heading is num ? heading.toDouble() : 0,
          timestamp: timestamp is int
              ? DateTime.fromMillisecondsSinceEpoch(timestamp)
              : DateTime.now(),
        );
      }
    } on FormatException {
      return null;
    }
    return null;
  }
}
