import 'package:flutter_sample_apps/constants.dart' as constants;
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as location;

class LocationsRepository {
  LocationsRepository();

  Future<location.LocationData> getCurrentLocation() async {
    return location.Location().getLocation();
  }

  // Future<String> getStreetFromLatLng(double lat, double lng) async {
  //   try {
  //     final placemarks = await geocoding.placemarkFromCoordinates(lat, lng);
  //     final street = placemarks[0].street.toString();
  //     return street;
  //   } on PlatformException {
  //     return '';
  //   }
  // }

  // Future<LatLng> getDetils(String placeId) async {
  //   final googlePlace = GooglePlace(constants.apiKey);
  //   final result = await googlePlace.details.get(placeId);
  //   if (result != null && result.result != null) {
  //     return LatLng(result.result!.geometry!.location!.lat!,
  //         result.result!.geometry!.location!.lng!,);
  //   }
  //   return const LatLng(0.0, 0.0);
  // }
}
