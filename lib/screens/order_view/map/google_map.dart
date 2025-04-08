import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter_sample_apps/models/direction.dart';
import 'package:flutter_sample_apps/screens/order_view/bloc/order_view_bloc.dart';
import 'package:flutter_sample_apps/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapWidget extends StatefulWidget {
  const GoogleMapWidget({
    required this.initialCameraPosition,
    this.zoom = 16.0,
  });

  final double zoom;
  final LatLng initialCameraPosition;
  @override
  _GoogleMapWidgetState createState() => _GoogleMapWidgetState();
}

class _GoogleMapWidgetState extends State<GoogleMapWidget> {
  GoogleMapController? _controller;
  Direction? _directionInfo;
  final Completer<GoogleMapController> _controllerCompleter = Completer();
  List<Circle> _circles = [];
  List<Marker> _markers = [];

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrderViewBloc, OrderViewState>(
        listener: _listener,
        child: BlocBuilder<OrderViewBloc, OrderViewState>(
            builder: (context, state) {
          return GoogleMap(
            buildingsEnabled: false,
            compassEnabled: false,
            circles: Set.from(_circles),
            markers: Set.from(_markers),
            initialCameraPosition: CameraPosition(
                target: widget.initialCameraPosition, zoom: widget.zoom,),
            onMapCreated: _mapCreated,
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
            polylines: _renderPolylines(),
          );
        },),);
  }

  Future<void> _listener(context, state) async {
    if (state is DrawnRouteState) {
      _drawRoute(state.direction);
      await _setMarkers(state.origin, state.destination);
      setState(() {});
    }
    if (state is TrackedLocationState) {
      final markerData = await _getBytesFromCanvas(40, 40);
      final imageMarkerData =
          await _getBytesFromAsset('assets/images/car_icon.png', 100);
      _updateMarkerAndCircle(
          LatLng(state.locationData.latitude ?? 0.0,
              state.locationData.longitude ?? 0.0,),
          markerData,
          imageMarkerData,);
      setState(() {});
    }
  }

  /// Create resizeable point marker
  Future<Uint8List> _getBytesFromCanvas(int width, int height) async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final paint = Paint()..color = azureRadianceColor;
    const radius = Radius.circular(20.0);
    canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(0.0, 0.0, width.toDouble(), height.toDouble()),
          topLeft: radius,
          topRight: radius,
          bottomLeft: radius,
          bottomRight: radius,
        ),
        paint,);
    final img = await pictureRecorder.endRecording().toImage(width, height);
    var data = await img.toByteData(format: ui.ImageByteFormat.png);
    if (data != null) {
      return data.buffer.asUint8List();
    } else {
      data = await rootBundle.load('assets/images/location_point.png');
      return data.buffer.asUint8List();
    }
  }

  /// Create resizeable image
  Future<Uint8List> _getBytesFromAsset(String path, int width) async {
    final data = await rootBundle.load(path);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width,);
    final fi = await codec.getNextFrame();
    var imageData = await fi.image.toByteData(format: ui.ImageByteFormat.png);
    if (imageData != null) {
      return imageData.buffer.asUint8List();
    } else {
      imageData = await rootBundle.load('assets/images/car_icon.png');
      return data.buffer.asUint8List();
    }
  }

  /// Set markers to GoogleMap
  Future<void> _setMarkers(LatLng origin, LatLng destination) async {
    final marker = await _getBytesFromCanvas(40, 40);
    _resetMarker();
    _addMarker(origin, 'from', marker);
    _addMarker(destination, 'to', marker);
  }

  /// If 'from' and 'destination' selected get amount and to zoom between two coordinates
  Future<void> _drawRoute(Direction? directions) async {
    if (directions != null) {
      final bound = directions.bounds;
      final cameraUpdate = CameraUpdate.newLatLngBounds(bound, 50);
      _controller?.animateCamera(cameraUpdate).then((void v) {
        check(cameraUpdate, _controller!);
      });
      _directionInfo = directions;
    }
  }

  /// Remove marker from map
  void _resetMarker({String markerId = ''}) {
    if (markerId.isNotEmpty) {
      _markers.removeWhere((element) => element.markerId.value == markerId);
      _circles.removeWhere((element) => element.circleId.value == markerId);
    } else {
      _markers = [];
      _circles = [];
    }
  }

  /// Add marker to markers list
  void _addMarker(LatLng latLng, String id, Uint8List markerData,
      {bool withCircle = true,
      Color circleColor = azureRadianceColor,
      double zIndex = 3,
      Offset offset = const Offset(0.5, 0.5),}) {
    if (latLng.latitude != 0.0 && latLng.longitude != 0.0) {
      _markers.add(Marker(
          markerId: MarkerId(id),
          position: latLng,
          zIndex: zIndex,
          flat: true,
          anchor: offset,
          icon: BitmapDescriptor.fromBytes(markerData),),);
      if (withCircle) {
        _circles.add(Circle(
            circleId: CircleId(id),
            radius: 50,
            zIndex: 3,
            strokeWidth: 1,
            strokeColor: circleColor.withAlpha(60),
            center: latLng,
            fillColor: circleColor.withAlpha(60),),);
      }
    }
  }

  /// Update marker position on map
  void _updateMarkerAndCircle(
      LatLng newLocationData, Uint8List markerData, Uint8List imageMarker,) {
    final latitude = newLocationData.latitude;
    final longitude = newLocationData.longitude;

    _resetMarker(markerId: 'updatedLocation');
    _addMarker(LatLng(latitude, longitude), 'updatedLocation', markerData,
        circleColor: blackColor,);
    _addMarker(LatLng(latitude, longitude), 'updatedLocationIcon', imageMarker,
        withCircle: false, zIndex: 100, offset: const Offset(0.5, 1.0),);
  }

  /// Zoom between two Google map coordinates
  Future<void> check(CameraUpdate cameraUpdate,
      GoogleMapController googleMapController,) async {
    googleMapController.animateCamera(cameraUpdate);
    _controller?.animateCamera(cameraUpdate);
    final latLngBounds1 = await googleMapController.getVisibleRegion();
    final latLngBounds2 = await googleMapController.getVisibleRegion();
    if (latLngBounds1.southwest.latitude == -90 ||
        latLngBounds2.southwest.latitude == -90) {
      check(cameraUpdate, googleMapController);
    }
  }

  /// Init controller and get current location
  void _mapCreated(GoogleMapController controller) {
    _controllerCompleter.complete(controller);
    _controller = controller;
  }

  /// Drawing Lines Between Points In Google Maps
  Set<Polyline> _renderPolylines() {
    return {
      if (_directionInfo != null)
        Polyline(
          polylineId: const PolylineId('overview_polyline'),
          color: azureRadianceColor,
          width: 5,
          points: _directionInfo!.polylinePoints
              .map((e) => LatLng(e.latitude, e.longitude))
              .toList(),
        ),
    };
  }
}
