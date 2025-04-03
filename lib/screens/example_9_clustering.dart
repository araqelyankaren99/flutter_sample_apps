import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_cluster_manager_2/google_maps_cluster_manager_2.dart' as cluster_manager;

class Example9ClusteringScreen extends StatefulWidget {
  const Example9ClusteringScreen({super.key});

  @override
  State<Example9ClusteringScreen> createState() => _Example9ClusteringScreenState();
}

class _Example9ClusteringScreenState extends State<Example9ClusteringScreen> {
  late GoogleMapController _mapController;
  late cluster_manager.ClusterManager<Place> _clusterManager;

  final List<Place> _places = [
    Place(LatLng(37.7749, -122.4194), "San Francisco"),
    Place(LatLng(37.3382, -121.8863), "San Jose"), // Close to San Francisco
    Place(LatLng(38.5816, -121.4944), "Sacramento"), // Close to San Francisco

    Place(LatLng(34.0522, -118.2437), "Los Angeles"),
    Place(LatLng(33.9850, -118.4695), "Long Beach"), // Close to Los Angeles
    Place(LatLng(34.0522, -118.2437), "Santa Monica"), // Close to Los Angeles

    Place(LatLng(36.1699, -115.1398), "Las Vegas"),
    Place(LatLng(35.9893, -115.1784), "Henderson"), // Close to Las Vegas
    Place(LatLng(36.1215, -115.1739), "Paradise"), // Close to Las Vegas

    Place(LatLng(40.7128, -74.0060), "New York"),
    Place(LatLng(40.7306, -73.9352), "Brooklyn"), // Close to New York
    Place(LatLng(40.7891, -73.1349), "Queens"), // Close to New York

    Place(LatLng(47.6062, -122.3321), "Seattle"),
    Place(LatLng(47.6769, -122.1217), "Bellevue"), // Close to Seattle
    Place(LatLng(47.2487, -122.4399), "Redmond"), // Close to Seattle
  ];

  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _clusterManager = cluster_manager.ClusterManager<Place>(
      _places,
      _updateMarkers,
      markerBuilder: _markerBuilder,
    );
  }

  // Marker builder with additional debugging to ensure all markers are created.
  Future<Marker> Function(dynamic) get _markerBuilder =>
          (cluster) async {
        final clusterPlace = cluster as cluster_manager.Cluster<Place>;

        // Print to check how clusters are being created
        print('Cluster ID: ${clusterPlace.getId()}, Location: ${clusterPlace.location}, Is Multiple: ${clusterPlace.isMultiple}');

        return Marker(
          markerId: MarkerId(clusterPlace.getId()),
          position: clusterPlace.location,
          infoWindow: clusterPlace.isMultiple
              ? InfoWindow(title: "${clusterPlace.count} places")
              : InfoWindow(title: clusterPlace.items.first.name),
        );
      };

  void _updateMarkers(Set<Marker> markers) {
    setState(() {
      _markers = markers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Marker Clustering")),
      body: GoogleMap(
        initialCameraPosition:
        const CameraPosition(target: LatLng(37.7749, -122.4194), zoom: 5),
        markers: _markers,
        onCameraMove: _clusterManager.onCameraMove,
        onMapCreated: (controller) {
          _mapController = controller;
          _clusterManager.setMapId(controller.mapId);
        },
      ),
    );
  }
}

class Place with cluster_manager.ClusterItem {
  final LatLng location;
  final String name;

  Place(this.location, this.name);
}
