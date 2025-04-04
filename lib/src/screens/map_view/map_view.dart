import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_sample_apps/src/constants.dart' as constants;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sample_apps/src/middlewares/connectivity/connectivity_widget.dart';
import 'package:flutter_sample_apps/src/middlewares/extensions/string.dart';
import 'package:flutter_sample_apps/src/middlewares/mixins/connection_mixin.dart';
import 'package:flutter_sample_apps/src/middlewares/mixins/marker_mixin.dart';
import 'package:flutter_sample_apps/src/middlewares/notifiers/current_location.dart';
import 'package:flutter_sample_apps/src/middlewares/notifiers/location.dart';
import 'package:flutter_sample_apps/src/middlewares/notifiers/payment_methods.dart';
import 'package:flutter_sample_apps/src/middlewares/notifiers/request_state.dart';
import 'package:flutter_sample_apps/src/models/direction.dart';
import 'package:flutter_sample_apps/src/models/order.dart';
import 'package:flutter_sample_apps/src/screens/map_view/select_address_map_view/bloc/main_bloc.dart';
import 'package:flutter_sample_apps/src/screens/map_view/shared/bottom_sheet_size.dart';
import 'package:flutter_sample_apps/src/screens/map_view/shared/pin_widget.dart';
import 'package:flutter_sample_apps/src/screens/map_view/transparent_screen.dart';
import 'package:flutter_sample_apps/src/screens/profile/profile_drawer/profile_drawer.dart';
import 'package:flutter_sample_apps/src/shared/alert_widget.dart';
import 'package:flutter_sample_apps/src/shared/app_bar_widget.dart';
import 'package:flutter_sample_apps/src/shared/btm_sheet_type_extension.dart';
import 'package:flutter_sample_apps/src/shared/fab_button.dart';
import 'package:flutter_sample_apps/src/shared/loading_widget.dart';
import 'package:flutter_sample_apps/src/shared/scrollable_bottom_sheet.dart';
import 'package:flutter_sample_apps/src/style.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class MapView extends StatefulWidget {
  const MapView({required this.order});

  final Order? order;

  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> with MarkerMixin, ConnectionMixin {
  GoogleMapController? _controller;
  final Completer<GoogleMapController> _controllerCompleter = Completer();
  final GlobalKey<ScaffoldState> _mapViewKey = GlobalKey<ScaffoldState>();
  final PageController _pageController = PageController();
  final ValueNotifier<int> _currentPageNotifier = ValueNotifier(0);
  LatLng point = const LatLng(0.0, 0.0);

  bool get _addressesSelected =>
      _mainBloc.order.from.isNotEmpty && _mainBloc.order.destination.isNotEmpty;

  double get _errorMessageTextHeight => "Location can't be null"
      .heightOfText(context, getStyle(fontSize: 12, color: Colors.red));

  double get _btnTextHeight =>
      'Request a driver'.heightOfText(context, getStyle(color: Colors.white));

  final ValueNotifier<LatLng> _trackedLocation = ValueNotifier(
      const LatLng(0.0, 0.0));
  final ValueNotifier<bool> _pinShowNotifier = ValueNotifier(true);
  Direction? _directionInfo;
  late MainBloc _mainBloc;

  Order get order => _mainBloc.order;

  double get amount => _mainBloc.order.amount;

  OrderStatus get orderStatus => _mainBloc.orderStatus;
  bool moved = false;

  BottomSheetType get bottomSheetType => _mainBloc.bottomSheetType;

  OrderStatusType get orderStatusType => _mainBloc.orderStatusType;

  double get fromLat => order.fromLat ?? 0.0;

  double get fromLng => order.fromLng ?? 0.0;

  String get fromStreet => order.from;

  double get zoom => 16.0;

  double get toLat => order.toLat ?? 0.0;

  double get toLng => order.toLng ?? 0.0;

  String get toStreet => order.destination;
  bool _isVisibleTripRoute = true;
  bool _isVisibleTitle = true;
  bool _safeAreaTop = false;
  bool _disableCancelBtn = false;
  bool _showLoading = true;

  @override
  void initState() {
    super.initState();
    connectionListener();
  }

  @override
  void dispose() {
    _disposeValueNotifiers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CurrentLocationNotifier>(
      create: (context) => CurrentLocationNotifier(),
      child: ChangeNotifierProvider(
        create: (_) => PaymentMethodsNotifier(),
        child: LoadingWidget(
          isLoading: _showLoading,
          child: PopScope(
            onPopInvoked: (_) => true,
            child: Scaffold(
              resizeToAvoidBottomInset: true,
              key: _mapViewKey,
              body: Stack(
                children: [
                  _renderBody(),
                  _renderPageView(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _listener(context, state) async {
    if (state is GetCurrentLocationTakenState) {
      setState(() => _showLoading = false);
    }
    if (state is PermissionDeniedState) {
      AlertWidget().showMessage(context, state.message);
    }
    if (state is ServerSideErrorState) {
      AlertWidget().showMessage(context, 'Something went wrong');
    }
    if (state is NotValidStreetState) {
      _resetPolylineAndGetLocation();
    }
    if (state is DrawnRouteState) {
      _pinShowNotifier.value = false;
      _drawRoute(state.direction);
      await setMarkers(order);
    }
    if (state is ViewTripState) {
      _mainBloc.showCurrentLoctaion = true;
      _changeSafeAreaTopState();
      _disableCancelBtn = !_disableCancelBtn;

      _isVisibleTitle = !_isVisibleTitle;
      _drawRoute(state.direction);
      await setMarkers(order);
    }
    if (state is ViewTripCloseState) {
      _changeSafeAreaTopState();

      _isVisibleTitle = !_isVisibleTitle;
      _isVisibleTripRoute = !_isVisibleTripRoute;

      _drawRoute(state.direction);
      await setMarkers(order);
    }
    if (state is RatedState) {
      AlertWidget().acceptAction(context, 'Thank you for rating');
    }
    if (state is RouteNotFoundState) {
      AlertWidget().cancelAction(context, 'Route Not Found');
      resetMarker();
      order.resetOrderData();
      _mainBloc.add(const GetCurrentLocationEvent(getLocationFromShared: true));

      _pinShowNotifier.value = true;
    }
    if (state is OrderStatusChangedState) {
      if (state.requestState == OrderStatus.canceled) {
        if (state.canceledForPay == true) {
          AlertWidget().cancelAction(context, 'Canceled');
        }
      }
      Provider.of<RequestState>(context, listen: false).orderStatus =
          state.requestState;
      if (state.requestState == OrderStatus.canceled) {
        if (!state.canceledWithError) {
          AlertWidget().cancelAction(
              _mapViewKey.currentContext ?? context, 'Order Canceled');
        }

        _resetPolylineAndGetLocation();
      }
      if (state.requestState == OrderStatus.onRoad) {
        _mainBloc.add(TrackUserLocationEvent());
      }
      if (state.requestState == OrderStatus.fromFinished) {
        _resetPolylineAndGetLocation();
        _pinShowNotifier.value = true;
      }

      if (state.requestState != OrderStatus.onRoad &&
          state.requestState != OrderStatus.canceled) {
        resetMarker(markerId: 'updatedLocation');
        resetMarker(markerId: 'updatedLocationIcon');
      }
    }
    if (state is TrackedLocationState) {
      final lat = state.locationData.latitude;
      final lng = state.locationData.longitude;
      if (lat != null && lng != null) {
        if (_trackedLocation.value.latitude != lat ||
            _trackedLocation.value.longitude != lng) {
          _trackedLocation.value = LatLng(lat, lng);
        }
      }
      final imageMarkerData =
          await _getBytesFromAsset('assets/images/car_icon.png', 100);
      updateMarkerAndCircle(_trackedLocation.value,
          imageMarker: imageMarkerData);
    }
    if (state is GetCurrentLocationTakenState) {
      Provider.of<LocationNotifier>(context, listen: false).currentLocation =
          state.currentLocation;
      if (state.haveStatus == true) {
        _animateCamera(state.currentLocation);
      }
      if (!_isNotEditable()) {
        if (_controller != null) {
          _animateCamera(state.currentLocation);
        }
        if (markers.value.isNotEmpty) {
          _pinShowNotifier.value = false;
        }
        if (_mainBloc.order.from.isNotEmpty &&
            _mainBloc.order.destination.isEmpty) {
          _mainBloc.showCurrentLoctaion = false;
        }

        if (_mainBloc.order.from.isNotEmpty &&
            _mainBloc.order.destination.isNotEmpty) {
          _mainBloc.add(SelectedToStreetEvent());
        }
      }
    }
    if (state is GetStreetState ||
        state is SelectedToStreetState ||
        state is SelectedFromStreetState) {
      if (order.from.isNotEmpty && order.destination.isNotEmpty) {
        _mainBloc.add(DrawRouteEvent());
      } else {
        if (order.from.isEmpty &&
            order.destination.isNotEmpty &&
            order.state != OrderStatus.fromFinished) {
          _mainBloc.add(const GetCurrentLocationEvent());
        }
        if (order.from.isNotEmpty &&
            order.destination.isEmpty &&
            (order.state != OrderStatus.fromFinished &&
                order.state != OrderStatus.none)) {
          _animateCamera(LatLng(order.fromLat ?? 0.0, order.fromLng ?? 0.0));
        }
      }
      if (order.state != OrderStatus.none) {
        resetMarker();
        _directionInfo = null;
      }
    }
    if (state is GetStreetState) {
      if (order.destination.isEmpty &&
          order.from.isNotEmpty &&
          (order.state != OrderStatus.fromFinished &&
              order.state != OrderStatus.none)) {
        _animateCamera(LatLng(order.fromLat ?? 0.0, order.fromLng ?? 0.0));
      }
      if ((order.from.isEmpty && order.destination.isEmpty) ||
          (order.from.isNotEmpty && order.destination.isEmpty)) {
        _pinShowNotifier.value = true;
      } else {
        _pinShowNotifier.value = false;
      }
    }
    if (state is OrderStatusChangedState) {
      if (state.requestState == OrderStatus.canceled ||
          state.requestState == OrderStatus.none) {
        resetMarker(markerId: 'updatedLocation');
        resetMarker(markerId: 'updatedLocationIcon');
      }
    }
  }

  Widget _renderBody() {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => LocationNotifier(const LatLng(0.0, 0.0)),
          ),
          ChangeNotifierProvider(
            create: (_) =>
                RequestState(_mainBloc.order.state ?? OrderStatus.none),
          ),
        ],
        child: BlocProvider<MainBloc>(
            create: (context) {
              _mainBloc = MainBloc()
                ..add(InitFCMEvent())
                ..add(GetBaseFareEvent());
              initMapView();
              return _mainBloc;
            },
            child: BlocListener<MainBloc, MainState>(
                listener: _listener, child: _renderScreenByLocation())));
  }

  Widget _renderBar() {
    return Stack(children: [
      if (_isVisibleTitle) _renderNavBar() else _renderTripBar(),
      _renderBottomSheet()
    ]);
  }

  Widget _renderSpeedWidget() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(7.5),
        child: Align(
          alignment: Alignment.topRight,
          child: CircleAvatar(
            backgroundColor: Colors.black,
            child: Consumer<CurrentLocationNotifier>(
              builder: (context, currentLocationNotifier, child) {
                return Text(
                  currentLocationNotifier.speed,
                  style: const TextStyle(color: Colors.white),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _renderScreen(OrderStatus status) {
    return SafeArea(
      top: _safeAreaTop,
      bottom: false,
      child: Stack(
        children: [
          ValueListenableBuilder<List<Marker>>(
            valueListenable: markers,
            builder: (context, markers, child) {
              return ValueListenableBuilder<LatLng>(
                valueListenable: _trackedLocation,
                builder: (context, trackedLocation, child) {
                  return Stack(
                    children: [
                      _renderGoogleMap(trackedLocation),
                      PinWidget(pinShowNotifier: _pinShowNotifier),
                      SafeArea(child: _renderBar()),
                      _renderSpeedWidget(),
                      const ConnectivityWidget(),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _renderPageView() {
    return IgnorePointer(
      ignoring: _currentPageNotifier.value == 0,
      child: PageView(
        allowImplicitScrolling: true,
        reverse: true,
        onPageChanged: _onPageChange,
        physics: const ClampingScrollPhysics(),
        controller: _pageController,
        children: [
          TransparentScreen(),
          ProfileDrawer(
            callBackFunction: _profileDrawerCallbackFuntion,
          ),
        ],
      ),
    );
  }

  Widget _renderScreenByLocation() {
    return Consumer<RequestState>(builder: (context, state, child) {
      _mainBloc
        ..orderStatus = state.orderStatus
        ..bottomSheetType = state.orderStatus.getBottomSheetType()
        ..orderStatusType = state.orderStatus.getOrderStatusType();
      return _renderScreenByState(state);
    });
  }

  Widget _renderScreenByState(RequestState state) {
    return LoadingWidget(
        isLoading:
            state is CreatingRequestState || state is CancelingRequestState,
        backgroundColor: blackHazeColor,
        child: _renderScreen(state.orderStatus));
  }

  Widget _renderGoogleMap(LatLng trackedLocation) {
    return Consumer<LocationNotifier>(builder: (context, _, child) {
      return GoogleMap(
        circles: Set.from(circles),
        markers: Set.from(markers.value),
        initialCameraPosition: CameraPosition(
          target: LatLng(trackedLocation.latitude, trackedLocation.longitude),
          zoom: zoom,
        ),
        onMapCreated: _mapCreated,
        buildingsEnabled: false,
        compassEnabled: false,
        zoomControlsEnabled: false,
        myLocationButtonEnabled: false,
        polylines: _renderPolylines(),
        onCameraIdle: !_addressesSelected
            ? () {
                if (moved == true) {
                  if (_mainBloc.showCurrentLoctaion == false) {
                    _mainBloc.add(GetStreetEvent(
                        lat: point.latitude,
                        lng: point.longitude,
                        isDestination: false));
                  }
                }
              }
            : () {},
        onCameraMove: _onCameraMove,
      );
    });
  }

  Set<Polyline> _renderPolylines() {
    return {
      if (_directionInfo != null)
        Polyline(
          polylineId: const PolylineId('overview_polyline'),
          color: azureRadianceColor,
          width: 5,
          points: _getPoints(_directionInfo),
        ),
    };
  }

  List<LatLng> _getPoints(Direction? directionInfo) {
    if (directionInfo != null) {
      return directionInfo.polylinePoints
          .map((e) => LatLng(e.latitude, e.longitude))
          .toList();
    } else {
      return [];
    }
  }

  Widget _renderNavBar() {
    return SafeArea(
        child: AppBarWidget(
      prefixWidget: FabButton(onTap: _onPressedMenu),
      titleStyle: appBarTitleStyle,
    ));
  }

  Widget _renderTripBar() {
    return AppBarWidget(
        backgroundColor: blackHazeColor,
        titleText: 'Trip',
        titleStyle: appBarTitleStyle,
        prefixWidget: Padding(
          padding: EdgeInsets.fromLTRB(
              1 * constants.rw(context),
              17 * constants.rh(context),
              17 * constants.rw(context),
              17 * constants.rh(context)),
          child: InkWell(
              onTap: () => _onCancel(),
              child: const Text('Cancel', style: appBarNavBtnStyle)),
        ),
        suffixWidget: Padding(
          padding: EdgeInsets.fromLTRB(
              17 * constants.rw(context),
              17 * constants.rh(context),
              1 * constants.rw(context),
              17 * constants.rh(context)),
        ));
  }

  /// Goes to rate screen
  void _onCancel() {
    if (_disableCancelBtn) {
      _mainBloc.add(ViewTripCloseEvent());
      _disableCancelBtn = !_disableCancelBtn;
    }
  }

  Widget _renderBottomSheet() {
    final maxSize = bottomSheetType.getMaxSize(
      context: context,
      amount: amount,
      orderStatusType: orderStatusType,
      btnTextHeight: _btnTextHeight,
      errorTextHeight: _errorMessageTextHeight,
    );

    final minSize = bottomSheetType.getMinSize(
      context: context,
      amount: amount,
      btnTextHeight: _btnTextHeight,
      errorTextHeight: _errorMessageTextHeight,
    );

    return ScrollableBottomSheet(
        key: Key(maxSize.toString() + orderStatus.toString()),
        orderStatus: orderStatus,
        bottomSheetSize: BottomSheetSize(
          initial: bottomSheetType.getMinSize(
              context: context,
              amount: amount,
              btnTextHeight: _btnTextHeight,
              errorTextHeight: _errorMessageTextHeight),
          max: maxSize,
          min: minSize,
        ));
  }

  /// Create resizeable image
  Future<Uint8List> _getBytesFromAsset(String path, int width) async {
    final data = await rootBundle.load(path);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    final fi = await codec.getNextFrame();
    var imageData = await fi.image.toByteData(format: ui.ImageByteFormat.png);
    if (imageData != null) {
      return imageData.buffer.asUint8List();
    } else {
      imageData = await rootBundle.load('assets/images/car_icon.png');
      return data.buffer.asUint8List();
    }
  }

  /// If 'from' and 'destination' selected get amount and to zoom between two coordinates
  Future<void> _drawRoute(Direction? directions) async {
    if (directions != null) {
      final bound = directions.bounds;
      final cameraUpdate = CameraUpdate.newLatLngBounds(bound, 50);

      _controller?.animateCamera(cameraUpdate).then((_) {
        check(cameraUpdate, _controller);
      });

      _directionInfo = directions;
    }
  }

  /// Zoom between two Google map coordinates
  Future<void> check(CameraUpdate cameraUpdate,
      GoogleMapController? googleMapController) async {
    googleMapController?.animateCamera(cameraUpdate);
    _controller?.animateCamera(cameraUpdate);
    final latLngBounds1 = await googleMapController?.getVisibleRegion();
    final latLngBounds2 = await googleMapController?.getVisibleRegion();
    if (latLngBounds1?.southwest.latitude == -90 ||
        latLngBounds2?.southwest.latitude == -90) {
      check(cameraUpdate, googleMapController);
    }
  }

  /// Changes safe areas top state
  void _changeSafeAreaTopState() {
    setState(() {
      _safeAreaTop = !_safeAreaTop;
    });
  }

  /// Remove polyline, markers and get current location
  void _resetPolylineAndGetLocation() {
    resetMarker();
    _mainBloc.add(const GetCurrentLocationEvent());
    _directionInfo = null;
  }

  /// Init controller and get current location
  void _mapCreated(controller) {
    _controllerCompleter.complete(controller);
    _controller = controller;
  }

  /// Set new camera position for new location
  void _animateCamera(LatLng location) {
    _controller?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: location,
      zoom: zoom,
    )));
  }

  /// Get position when google map dragged
  void _onCameraMove(CameraPosition position) {
    if (_mainBloc.showCurrentLoctaion == false) {
      moved = true;
      point = position.target;
    }
  }

  /// Dispose ValueNotifiers
  void _disposeValueNotifiers() {
    _controller?.dispose();
    _trackedLocation.dispose();

    _pinShowNotifier.dispose();

    disposeMarkers();
  }

  /// States when user can't change request data
  bool _isNotEditable() {
    return order.state != OrderStatus.none &&
        order.state != OrderStatus.canceled &&
        order.state != OrderStatus.fromFinished &&
        order.state != OrderStatus.unconfirmed;
  }

  // This method opens ProfileDrawer
  void _onPressedMenu() {
    _pageController.animateToPage(1,
        duration: const Duration(milliseconds: 300), curve: Curves.linear);
  }

  /// This function changes _currentPage value to page, that is opened
  void _onPageChange(int page) {
    setState(() {
      _currentPageNotifier.value = page;
    });
  }

  /// This function returns to MapView screen and is called when user taps outside of ProfileDrawer body
  void _profileDrawerCallbackFuntion() {
    _pageController.animateToPage(0,
        duration: const Duration(milliseconds: 300), curve: Curves.linear);
  }

  /// If order not created get current location else get order data
  void initMapView() {
    _mainBloc.add(const GetCurrentLocationEvent());
    final order = widget.order;
    resetMarker();
    if (order != null) {
      _mainBloc
        ..order = order
        ..add(DrawRouteEvent());
      if (order.state != OrderStatus.finished &&
          order.state != OrderStatus.canceled &&
          order.state != OrderStatus.none) {
        _pinShowNotifier.value = false;
        _mainBloc
          ..add(SubscribeToRequestStatesEvent())
          ..showCurrentLoctaion = false;
      } else if (order.state == OrderStatus.canceled) {
        _pinShowNotifier.value = false;
        _mainBloc.showCurrentLoctaion = true;
      } else {
        _pinShowNotifier.value = true;
        _mainBloc.showCurrentLoctaion = true;
      }
      if (order.state == OrderStatus.onRoad) {
        _mainBloc.add(TrackUserLocationEvent());
      }
      if (order.state != OrderStatus.onRoad) {
        _mainBloc.add(UnsubscribeFromLocationEvent(order: order));
      }
    }
  }
}
