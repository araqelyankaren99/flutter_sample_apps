import 'dart:async';
import 'dart:convert';
import 'package:flutter_sample_apps/src/constants.dart' as constants;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart' as location_package;

class LocationsRepository {
  LocationsRepository();

  /// Get device current location
  Future<LatLng> getCurrentLocation() async {
    final location = location_package.Location();
    StreamSubscription<location_package.LocationData>? stream;
    bool _serviceEnabled;
    location_package.PermissionStatus _permissionGranted;
    location_package.LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return const LatLng(
            0.0, 0.0);
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == location_package.PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != location_package.PermissionStatus.granted) {
        return const LatLng(
            0.0, 0.0);
      }
    }

    stream ??= location.onLocationChanged.listen((newLocationData) {});
    stream.cancel();

    return Future.delayed(const Duration(milliseconds: 300), () async {
      _locationData = await location.getLocation();
      return LatLng(_locationData.latitude ?? 0.0,
          _locationData.longitude ?? 0.0);
    });
  }

  /// Get street by coordinates
  Future<String> getStreetFromLatLng(LatLng location) async {
    // ${constants.geocodingApiBaseUrl}
    final url = 'key=${constants.apiKey}&language=en&latlng=${location.latitude},${location.longitude}';
    var _formattedAddress = '';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = await jsonDecode(response.body);
        if (data['status'] != 'ZERO_RESULTS') {
          _formattedAddress = data['results'][0]['formatted_address'];
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    return _formattedAddress;
  }

  /// Get coordinates by placename
  Future<LatLng> getDetails(String placeId) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=${constants.apiKey}';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final location = json['result']?['geometry']?['location'];
      if (location != null) {
        final lat = location['lat'] ?? 0.0;
        final lng = location['lng'] ?? 0.0;
        return LatLng(lat, lng);
      }
    }
    return const LatLng(0.0, 0.0);
  }
}
