import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Example10TrafficScreen extends StatefulWidget {
  const Example10TrafficScreen({super.key});

  @override
  State<Example10TrafficScreen> createState() => _Example10TrafficScreenState();
}

class _Example10TrafficScreenState extends State<Example10TrafficScreen> {
  late GoogleMapController _mapController;
  bool _showTraffic = false;
  bool _showBicycling = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: LatLng(37.7749, -122.4194), zoom: 12),
            trafficEnabled: _showTraffic,
            onMapCreated: (controller) => _mapController = controller,
          ),
          Align(
            alignment: Alignment.topLeft, // You can adjust the alignment as needed
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text('Traffic'),
                    value: _showTraffic,
                    onChanged: (value) {
                      setState(() => _showTraffic = value);
                    },
                  ),
                  SwitchListTile(
                    title: Text('Bicycling'),
                    value: _showBicycling,
                    onChanged: (value) {
                      setState(() {
                        _showBicycling = value;
                        _mapController.setMapStyle(_showBicycling
                            ? '[{"featureType": "all", "stylers": [{"visibility": "on"}]}]' // Show biking routes
                            : null); // Revert to default
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
