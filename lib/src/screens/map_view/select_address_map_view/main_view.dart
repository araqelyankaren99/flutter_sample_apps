import 'package:flutter_sample_apps/src/constants.dart' as constants;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sample_apps/src/middlewares/connectivity/connectivity.dart';
import 'package:flutter_sample_apps/src/middlewares/notifiers/location.dart';
import 'package:flutter_sample_apps/src/screens/map_view/select_address_map_view/bloc/main_bloc.dart';
import 'package:flutter_sample_apps/src/shared/app_bar_widget.dart';
import 'package:flutter_sample_apps/src/shared/fab_button.dart';
import 'package:flutter_sample_apps/src/shared/loading_widget.dart';
import 'package:flutter_sample_apps/src/style.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class MainView extends StatefulWidget {
  const MainView({Key? key, required this.fromDestination}) : super(key: key);
  final bool fromDestination;
  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  bool _disableDoneBtn = false;
  bool _disableCancelBtn = false;
  bool _disableCurrentLocationBtn = false;
  late GoogleMapController _controller;
  MainBloc get _mainBloc => BlocProvider.of<MainBloc>(context);

  double get _pinIconSize => 30;
  double get _screenWidth => MediaQuery.of(context).size.width;
  double get _screenHeight =>
      MediaQuery.of(context).size.height +
      MediaQuery.of(context).padding.top -
      MediaQuery.of(context).padding.bottom;

  @override
  Widget build(BuildContext context) {
    return _render();
  }

  Widget _render() {
    return Scaffold(
        body: BlocListener<MainBloc, MainState>(
            listener: _listener, child: _renderScreen()),
        floatingActionButton: FabButton(
          onTap: () => _getCurrentLocation(false),
          buttonType: FabButtonType.location,
        ));
  }

  Widget _renderScreen() {
    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          _renderMap(),
          _renderPin(),
          _renderNavBar(),
        ],
      ),
    );
  }

  Widget _renderMap() {
    return Consumer<LocationNotifier>(builder: (context, location, child) {
      return _renderGoogleMap(location);
    });
  }

  Widget _renderGoogleMap(LocationNotifier location) {
    return LoadingWidget(
        isLoading: location.currentLocation == const LatLng(0.0, 0.0),
        child: GoogleMap(
          initialCameraPosition:
              CameraPosition(target: location.currentLocation, zoom: 16.0),
          onMapCreated: _mapCreated,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
        ));
  }

  Widget _renderPin() {
    return Positioned(
      top: _screenHeight / 2 - _pinIconSize,
      left: _screenWidth / 2 - (_pinIconSize / 2),
      child: SizedBox(
          height: _pinIconSize,
          width: _pinIconSize,
          child: SvgPicture.asset(
            'assets/images/pin.svg',
          )),
    );
  }

  Widget _renderNavBar() {
    return SafeArea(
      child: AppBarWidget(
          backgroundColor: whiteColor,
          titleText: widget.fromDestination ? 'Destination' : 'From',
          titleStyle: appBarTitleStyle,
          prefixWidget: Padding(
            padding: EdgeInsets.symmetric(
                vertical: 17 * constants.rh(context),
                horizontal: 17 * constants.rw(context)),
            child: InkWell(
                onTap: () => _onCancel(),
                child: const Text('Cancel', style: appBarNavBtnStyle)),
          ),
          suffixWidget: Padding(
            padding: EdgeInsets.symmetric(
                vertical: 17 * constants.rh(context),
                horizontal: 17 * constants.rw(context)),
            child: InkWell(
                onTap: () => _onDone(),
                child: const Text('Done', style: appBarNavBtnStyle)),
          )),
    );
  }

  /// On map created init map controller and get current location
  void _mapCreated(controller) {
    setState(() {
      _controller = controller;
    });
    _getCurrentLocation(true);
  }

  /// Send event for get user current location
  void _getCurrentLocation(bool getLocationFromShared) {
    if (!_disableCurrentLocationBtn) {
      _mainBloc.add(GetCurrentLocationEvent(
          getLocationFromShared: getLocationFromShared));
      _disableCurrentLocationBtn = true;
    }
  }

  /// Back to MapView screen and disable button
  void _onCancel() {
    if (!_disableCancelBtn) {
      Navigator.pop(context, true);
      _disableCancelBtn = true;
    }
  }

  /// Get selected point, back to MapView screen and disable button
  void _onDone() {
    if (!_disableDoneBtn) {
      _handleDoneClick();
      _disableDoneBtn = true;
    }
  }

  /// After click by screen center coordinate get lat and lng
  Future<void> _handleDoneClick() async {
    final screenCoordinate = ScreenCoordinate(
        x: (_screenWidth / 2).round(), y: (_screenHeight / 2).round());
    final point = await _controller.getLatLng(screenCoordinate);
    Connection().check().then((value) {
      value
          ? _mainBloc.add(GetStreetEvent(
              lat: point.latitude,
              lng: point.longitude,
              isDestination: widget.fromDestination))
          : Navigator.pop(context, false);
    });
  }

  Future<void> _listener(context, state) async {
    if (state is GetCurrentLocationTakenState) {
      _listenGetCurrentLocationTakenState(state);
      _disableCurrentLocationBtn = false;
    }

    if (state is GetStreetState && _disableDoneBtn) {
      _listenGetStreetState(state);
    }
  }

  void _listenGetCurrentLocationTakenState(GetCurrentLocationTakenState state) {
    setState(() {
      _animateCamera(state);
    });
  }

  void _animateCamera(GetCurrentLocationTakenState state) {
    _controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(
          state.currentLocation.latitude, state.currentLocation.longitude),
      zoom: 16.0,
    )));
  }

  void _listenGetStreetState(GetStreetState state) {
    Navigator.pop(context, true);
    _disableDoneBtn = false;
  }
}
