import 'package:flutter/material.dart';
import 'package:location/location.dart';

class CurrentLocationNotifier with ChangeNotifier {
  CurrentLocationNotifier();

  LocationData? _currentLocation;
  LocationData? get locationData => _currentLocation;

  String get speed => _currentLocation?.speed == null ? '-1' : (_currentLocation!.speed! * 3.6).toString();

  set locationData(LocationData? currentLocationData) {
     final prevCurrentLocation = _currentLocation;

    _currentLocation = currentLocationData;

    if (prevCurrentLocation?.latitude != currentLocationData?.latitude ||
        prevCurrentLocation?.longitude != currentLocationData?.longitude) {
      notifyListeners();
    }
  }
}
