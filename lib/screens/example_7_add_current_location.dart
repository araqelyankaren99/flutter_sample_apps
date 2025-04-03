import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class Example7AddCurrentLocationScreen extends StatefulWidget {
  const Example7AddCurrentLocationScreen({super.key});

  @override
  State<Example7AddCurrentLocationScreen> createState() => _Example7AddCurrentLocationScreenState();
}

class _Example7AddCurrentLocationScreenState extends State<Example7AddCurrentLocationScreen> {
  late GoogleMapController _mapController;
  Location _location = Location();
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  final ValueNotifier<String> _speedNotifier = ValueNotifier('');
  
  @override
  void initState() {
    super.initState();
    _location.onLocationChanged.listen(_onLocationChange);
  }
  
  @override
  void dispose() {
    super.dispose();
    _speedNotifier.dispose();
    _mapController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(target: LatLng(0, 0), zoom: 2), // Default position
              myLocationEnabled: true, // Show current location button
              myLocationButtonEnabled: true, // Enable location button
              onMapCreated: (controller) async {
                _mapController = controller;
                _serviceEnabled = await _location.serviceEnabled();
                if (!_serviceEnabled) {
                  _serviceEnabled = await _location.requestService();
                  if (!_serviceEnabled) {
                    return;
                  }
                }
            
                _permissionGranted = await _location.hasPermission();
                if (_permissionGranted == PermissionStatus.denied) {
                  _permissionGranted = await _location.requestPermission();
                  if (_permissionGranted != PermissionStatus.granted) {
                    return;
                  }
                }
                // Get the current location
                var currentLocation = await _location.getLocation();
            
                // Move the camera to the user's location
                _mapController.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      target: LatLng(currentLocation.latitude!, currentLocation.longitude!),
                      zoom: 15,
                    ),
                  ),
                );
              },
            ),
            ValueListenableBuilder(valueListenable: _speedNotifier, builder: (context,value,child){
              return Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 10,top: 10),
                  child: CircleAvatar(child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(value.toString()),
                  ),
                  ),
                ),
              );
            })
          ],
        ),
      ),
    );
  }

  void _onLocationChange(LocationData locationData) {
    final speed = locationData.speed;
    if(speed == null){
      return;
    }
    if(speed < 0.0){
      return;
    }
    _speedNotifier.value = speed.toInt().toString();
  }
}
