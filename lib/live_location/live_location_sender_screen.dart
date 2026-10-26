import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../socket/socket.dart';
import 'location_message.dart';

class LiveLocationSenderScreen extends StatefulWidget {
  const LiveLocationSenderScreen({super.key});

  @override
  State<LiveLocationSenderScreen> createState() => _LiveLocationSenderScreenState();
}

class _LiveLocationSenderScreenState extends State<LiveLocationSenderScreen> {
  static const _markerId = MarkerId('sender');
  static const _locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 5,
  );

  GoogleMapController? _mapController;
  StreamSubscription<Position>? _positionSubscription;
  LocationMessage? _lastLocation;
  bool _lastSendSucceeded = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startTracking();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _startTracking() async {
    await SocketService.instance.connect();

    final permissionError = await _checkPermission();
    if (!mounted) {
      return;
    }
    if (permissionError != null) {
      setState(() => _error = permissionError);
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(locationSettings: _locationSettings);
      if (!mounted) {
        return;
      }
      _onPosition(position);
    } on Object catch (e) {
      if (mounted) {
        setState(() => _error = 'Could not get current location: $e');
      }
      return;
    }

    _positionSubscription = Geolocator.getPositionStream(locationSettings: _locationSettings).listen(
      _onPosition,
      onError: (Object e) => debugPrint('Location stream error: $e'),
    );
  }

  /// Returns an error message, or null when location can be used.
  Future<String?> _checkPermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return 'Location services are disabled.';
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return switch (permission) {
      LocationPermission.denied => 'Location permission denied.',
      LocationPermission.deniedForever => 'Location permission permanently denied. Enable it in Settings.',
      _ => null,
    };
  }

  void _onPosition(Position position) {
    final location = LocationMessage(
      latitude: position.latitude,
      longitude: position.longitude,
      heading: position.heading,
      timestamp: position.timestamp,
    );

    final sent = SocketService.instance.send(location.encode());
    setState(() {
      _lastLocation = location;
      _lastSendSucceeded = sent;
    });
    _mapController?.animateCamera(CameraUpdate.newLatLng(location.latLng));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Share live location')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final error = _error;
    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(error, textAlign: TextAlign.center),
        ),
      );
    }

    final location = _lastLocation;
    if (location == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(target: location.latLng, zoom: 17),
          onMapCreated: (controller) => _mapController = controller,
          myLocationButtonEnabled: false,
          markers: {
            Marker(
              markerId: _markerId,
              position: location.latLng,
              rotation: location.heading,
              anchor: const Offset(0.5, 0.5),
              flat: true,
            ),
          },
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 24,
          child: _StatusCard(location: location, sent: _lastSendSucceeded),
        ),
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.location, required this.sent});

  final LocationMessage location;
  final bool sent;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          sent ? Icons.cloud_done : Icons.cloud_off,
          color: sent ? Colors.green : Colors.red,
        ),
        title: Text(sent ? 'Sharing location' : 'Socket not connected'),
        subtitle: Text(
          '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}',
        ),
      ),
    );
  }
}
