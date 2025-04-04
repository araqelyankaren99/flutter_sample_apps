import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationNotifier with ChangeNotifier {
  LocationNotifier(this._currentLocation);

  LatLng get currentLocation => _currentLocation;

  set currentLocation(LatLng currentLocation) {
    final prevCurrentLocation = _currentLocation;
    _currentLocation = currentLocation;

    if (prevCurrentLocation.latitude != currentLocation.latitude ||
        prevCurrentLocation.longitude != currentLocation.longitude) {
      notifyListeners();
    }
  }

  LatLng _currentLocation = const LatLng(0.0, 0.0);
}


