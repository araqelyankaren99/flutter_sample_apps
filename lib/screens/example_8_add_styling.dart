import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Example8AddStylingScreen extends StatefulWidget {
  const Example8AddStylingScreen({super.key});

  @override
  State<Example8AddStylingScreen> createState() => _Example8AddStylingScreenState();
}

class _Example8AddStylingScreenState extends State<Example8AddStylingScreen> {
  final String _mapStyle = '''
[
  // Global geometry settings
  {
    "elementType": "geometry",
    "stylers": [
      { "color": "#242f3e" } // Background color for land
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      { "color": "#746855" } // Color of text labels
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      { "color": "#242f3e" } // Text stroke color
    ]
  },

  // Roads styling
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      { "color": "#38414e" } // Road color
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry.stroke",
    "stylers": [
      { "color": "#212a37" } // Road border color
    ]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.fill",
    "stylers": [
      { "color": "#9ca5b3" } // Road label text color
    ]
  },

  // Highways
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      { "color": "#746855" } // Highway road color
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.stroke",
    "stylers": [
      { "color": "#1f2835" } // Highway border color
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      { "color": "#f3d19c" } // Highway text color
    ]
  },

  // Water styling
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      { "color": "#17263c" } // Water color
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      { "color": "#515c6d" } // Water label text color
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.stroke",
    "stylers": [
      { "color": "#17263c" } // Water label stroke color
    ]
  },

  // Parks and natural areas
  {
    "featureType": "landscape.natural",
    "elementType": "geometry",
    "stylers": [
      { "color": "#233d2c" } // Natural landscape color
    ]
  },

  // Transit (Bus, Rail, etc.)
  {
    "featureType": "transit",
    "elementType": "geometry",
    "stylers": [
      { "color": "#2f3948" } // Transit route color
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "geometry",
    "stylers": [
      { "color": "#3a4762" } // Transit station color
    ]
  },

  // Points of Interest (POI)
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [
      { "color": "#283d6a" } // General POI color
    ]
  },
  {
    "featureType": "poi.business",
    "elementType": "geometry",
    "stylers": [
      { "visibility": "off" } // Hide businesses
    ]
  },

  // Hide specific map features
  {
    "featureType": "administrative",
    "elementType": "labels.text.fill",
    "stylers": [
      { "color": "#8b8787" } // Color of administrative labels (city, state names)
    ]
  },
  {
    "featureType": "administrative.land_parcel",
    "stylers": [
      { "visibility": "off" } // Hide land parcel borders
    ]
  },
  {
    "featureType": "administrative.locality",
    "elementType": "labels.text.fill",
    "stylers": [
      { "color": "#c4c4c4" } // Color of city/town labels
    ]
  },

  // Adjust brightness and contrast
  {
    "elementType": "geometry",
    "stylers": [
      { "lightness": -10 }, // Decrease brightness
      { "saturation": -50 }, // Reduce color intensity
      { "gamma": 1.5 } // Increase contrast
    ]
  }
]
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Map Styling Example')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: LatLng(37.7749, -122.4194), zoom: 12),
        style: _mapStyle,
      ),
    );
  }
}
