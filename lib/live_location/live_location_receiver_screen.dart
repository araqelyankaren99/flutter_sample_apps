import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../socket/socket.dart';
import 'location_message.dart';

class LiveLocationReceiverScreen extends StatefulWidget {
  const LiveLocationReceiverScreen({super.key});

  @override
  State<LiveLocationReceiverScreen> createState() => _LiveLocationReceiverScreenState();
}

class _LiveLocationReceiverScreenState extends State<LiveLocationReceiverScreen>
    with SingleTickerProviderStateMixin {
  static const _markerId = MarkerId('receiver');
  static const _initialCamera = CameraPosition(target: LatLng(0, 0), zoom: 2);
  static const _trackingZoom = 17.0;

  late final AnimationController _markerAnimation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  )..addListener(_onMarkerAnimationTick);

  GoogleMapController? _mapController;
  LatLng? _animationStart;
  LatLng? _animationEnd;
  LatLng? _markerPosition;
  double _markerRotation = 0;
  DateTime? _lastUpdate;

  @override
  void initState() {
    super.initState();
    SocketService.instance.addListener(_onSocketMessage);
    SocketService.instance.connect();
  }

  @override
  void dispose() {
    SocketService.instance.removeListener(_onSocketMessage);
    _markerAnimation.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _onSocketMessage(dynamic message) {
    final location = LocationMessage.tryParse(message);
    if (location == null || !mounted) {
      return;
    }

    final current = _markerPosition;
    setState(() {
      _markerRotation = location.heading;
      _lastUpdate = location.timestamp;
    });

    if (current == null) {
      // First update: place the marker and zoom in on it.
      setState(() => _markerPosition = location.latLng);
      _mapController?.moveCamera(CameraUpdate.newLatLngZoom(location.latLng, _trackingZoom));
      return;
    }

    _animationStart = current;
    _animationEnd = location.latLng;
    _markerAnimation.forward(from: 0);
    _mapController?.animateCamera(CameraUpdate.newLatLng(location.latLng));
  }

  void _onMarkerAnimationTick() {
    final start = _animationStart;
    final end = _animationEnd;
    if (start == null || end == null) {
      return;
    }
    final t = Curves.easeInOut.transform(_markerAnimation.value);
    setState(() {
      _markerPosition = LatLng(
        start.latitude + (end.latitude - start.latitude) * t,
        start.longitude + (end.longitude - start.longitude) * t,
      );
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    final position = _markerPosition;
    if (position != null) {
      controller.moveCamera(CameraUpdate.newLatLngZoom(position, _trackingZoom));
    }
  }

  @override
  Widget build(BuildContext context) {
    final position = _markerPosition;
    return Scaffold(
      appBar: AppBar(title: const Text('Track live location')),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialCamera,
            onMapCreated: _onMapCreated,
            myLocationButtonEnabled: false,
            markers: {
              if (position != null)
                Marker(
                  markerId: _markerId,
                  position: position,
                  rotation: _markerRotation,
                  anchor: const Offset(0.5, 0.5),
                  flat: true,
                ),
            },
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Card(
              child: ListTile(
                leading: position == null
                    ? const SizedBox.square(
                        dimension: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location, color: Colors.blue),
                title: Text(position == null ? 'Waiting for location…' : 'Tracking live location'),
                subtitle: _lastUpdate == null
                    ? null
                    : Text('Last update: ${TimeOfDay.fromDateTime(_lastUpdate!).format(context)}'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
