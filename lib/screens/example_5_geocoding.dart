import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class Example5GeocodingScreen extends StatefulWidget {
  const Example5GeocodingScreen({super.key});

  @override
  State<Example5GeocodingScreen> createState() => _Example5GeocodingScreenState();
}

class _Example5GeocodingScreenState extends State<Example5GeocodingScreen> {
  GoogleMapController? _mapController;
  final LatLng _initialPosition = LatLng(37.7749, -122.4194); // Default to San Francisco
  final Set<Marker> _markers = {};

  Future<void> _goToAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        Location location = locations.first;

        LatLng targetLatLng = LatLng(location.latitude, location.longitude);

        _mapController?.animateCamera(CameraUpdate.newLatLngZoom(targetLatLng, 14));

        setState(() {
          _markers.clear();
          _markers.add(
            Marker(
              markerId: MarkerId(address),
              position: targetLatLng,
              infoWindow: InfoWindow(title: address),
            ),
          );
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error: $e");
      }
    }
  }

  Future<String> getAddressFromLatLng(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return '${place.name}, ${place.locality}, ${place.country}';
      }
    } catch (e) {
      print('Error: $e');
    }
    return 'Unknown Location';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Search Address on Map")),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Enter Address (e.g., New York)",
                suffixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) => _goToAddress(value),
            ),
          ),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(target: _initialPosition, zoom: 12),
              markers: _markers,
              onMapCreated: (controller) => _mapController = controller,
            ),
          ),
        ],
      ),
    );
  }
}
