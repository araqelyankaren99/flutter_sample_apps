import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class Example16StreetViewScreen extends StatefulWidget {
  const Example16StreetViewScreen({super.key});

  @override
  State<Example16StreetViewScreen> createState() => _Example16StreetViewScreenState();
}

class _Example16StreetViewScreenState extends State<Example16StreetViewScreen> {
  late GoogleMapController _mapController;

  // Function to open Google Street View
  void _openStreetView() async {
    final url =
        'https://www.google.com/maps/@37.7749,-122.4194,3a,75y,180h,90t/data=!3m6!1e1!3m4!1szPpFe1eIq6y8GJzyXgOwzQ!2e0!7i13312!8i6656';
    if (await canLaunch(url)) {
      await launch(url); // Open the URL in the browser
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(37.7749, -122.4194),
                  zoom: 14,
                ),
                onMapCreated: (controller) {
                  _mapController = controller;
                },
              ),
            ),
            ElevatedButton(
              onPressed: _openStreetView,
              child: Text('View in Street View'),
            ),
          ],
        ),
      ),
    );
  }
}
