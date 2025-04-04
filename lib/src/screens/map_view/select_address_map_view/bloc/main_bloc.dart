import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart' as google_places_sdk;
import 'package:flutter_sample_apps/src/constants.dart' as constants;
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sample_apps/src/middlewares/extensions/datetime.dart';
import 'package:flutter_sample_apps/src/middlewares/notifiers/current_location.dart';
import 'package:flutter_sample_apps/src/middlewares/repositories/graph_ql_repository.dart';
import 'package:flutter_sample_apps/src/middlewares/repositories/locations_repository.dart';
import 'package:flutter_sample_apps/src/models/direction.dart';
import 'package:flutter_sample_apps/src/models/driver.dart';
import 'package:flutter_sample_apps/src/models/order.dart';
import 'package:flutter_sample_apps/src/screens/map_view/enums/request_fields.dart';
import 'package:flutter_sample_apps/src/screens/map_view/shared/token_info.dart';
import 'package:flutter_sample_apps/src/shared/btm_sheet_type_extension.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:location/location.dart';
import 'package:location/location.dart' as location_package;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

part 'main_event.dart';
part 'main_state.dart';

class MainBloc extends Bloc<MainEvent, MainState> {
  MainBloc() : super(MainStateInitial()) {
    on<GetCurrentLocationEvent>(_getCurrentLocationEventToState);
    on<InitFCMEvent>(_initFCM);
    on<GetStreetEvent>(_getStreetEventToState);
    on<AutoCompleteSearchEvent>(_autoCompleteSearchEventToState);
    on<SelectFromStreetEvent>(_selectFromStreetEventToState);
    on<SelectToStreetEvent>(_selectToStreetEventToState);
    on<ChangeOrderDestinationEvent>(_changeOrderDestinationEventToState);
    on<SelectedToStreetEvent>(_selectedToStreetEvent);
    on<ValidateRequestEvent>(_validateRequestEventToState);
    on<SelectDueDateEvent>(_selectDueDateEventToState);
    on<AddCommentEvent>(_addCommentEventToState);
    on<DrawRouteEvent>(_drawRouteEventToState);
    on<RequestStateRecievedEvent>(_requestStateRecievedEventToState);
    on<CreateOrderEvent>(_createOrderEventToState);
    on<CancelOrderEvent>(_cancelOrderEventToState);
    on<SubscribeToRequestStatesEvent>(_subscribeToRequestStatesEventToState);
    on<FinishOrderEvent>(_finishOrderEventToState);
    on<RateDriverEvent>(_rateDriverEventToState);
    on<RateDriverCloseEvent>(_rateDriverCloseEventToState);
    on<TrackUserLocationEvent>(_trackUserLocationEventToState);
    on<TrackedLocationEvent>(_trackedLocationEventToState);
    on<CheckPaymentMethodEvent>(_checkPaymentMethodEventToState);
    on<ViewTripEvent>(_viewTripEventToState);
    on<ViewTripCloseEvent>(_viewTripCloseEventToState);
    on<UnsubscribeFromLocationEvent>(_unsubscribeFromLocationEventToState);
    on<GetBaseFareEvent>(_getGetBaseFareEventToState);
  }

  final LocationsRepository _locationsRepository = LocationsRepository();
  final GraphQlRepository _graphQlRepository = GraphQlRepository();
  StreamSubscription? _subscription;
  final location_package.Location _locationTracker =
      location_package.Location();
  StreamSubscription? _locationSubscription;
  final Map<RequestFields?, bool?> invalidItems = {};
  bool showCurrentLoctaion = false;
  OrderStatus orderStatus = OrderStatus.none;
  BottomSheetType bottomSheetType = BottomSheetType.none;
  OrderStatusType orderStatusType = OrderStatusType.none;
  final currentLocationNotifier = CurrentLocationNotifier();
  final double minMiles = 0.1;
  late String status = '';
  Order order = Order(
    id: '',
    amount: 0,
    createdDate: DateTime.now(),
    destination: '',
    dueDate: DateTime.now().get20MinutesLaterRounded(),
    from: '',
  );
  String userId = '';
  String orderId = '';
  bool get fieldsValid => order.from.isNotEmpty && order.from.isNotEmpty;
  Future<void> _setLoc(LatLng? locationData) async {
    final prefs = await SharedPreferences.getInstance();
    if (locationData == null) {
      return;
    }
    prefs
      ..setDouble('lat', locationData.latitude)
      ..setDouble('lng', locationData.longitude);
  }

  Future<LatLng?> _getLoc() async {
    final prefs = await SharedPreferences.getInstance();
    final latitude = prefs.getDouble('lat');
    final longitude = prefs.getDouble('lng');
    if (latitude != null && longitude != null) {
      return LatLng(latitude, longitude);
    }
    return null;
  }

  // Future<void> _onInitCurrentLocationNotifierEventToState(
  //     InitCurrentLocationNotifierEvent event, Emitter<MainState> emit,) async{
  //   _locationSubscription =
  //       _locationTracker.onLocationChanged.listen((LocationData newLocationData) {
  //        currentLocationNotifier.locationData = newLocationData;
  //       });
  // }

  Future<void> _getCurrentLocationEventToState(
      GetCurrentLocationEvent event, Emitter<MainState> emit) async {
    emit(SearchingCurrentLocationState());

    if (!event.getLocationFromShared) {
      try {
        final locationData = await _locationsRepository.getCurrentLocation();

        await _setLoc(locationData);
        if (order.from.isEmpty) {
          order
            ..fromLat = locationData.latitude
            ..fromLng = locationData.longitude
            ..from = await _locationsRepository.getStreetFromLatLng(
                LatLng(order.fromLat ?? 0.0, order.fromLng ?? 0.0));
        }
        emit(GetCurrentLocationTakenState(
            currentLocation:
                LatLng(locationData.latitude, locationData.longitude),
            currentLocationStreet: order.from,
            haveStatus: event.haveStatus));
      }on Exception catch (_) {
        emit(const GetCurrentLocationFailedState(
            errorMessage: 'Something went wrong'));
        throw Exception('Something went wrong');
      }
    } else {
      if (order.from.isEmpty) {
        final location = await _getLoc();
        if (location != null) {
          try {
            order
              ..fromLat = location.latitude
              ..fromLng = location.longitude
              ..from = await _locationsRepository.getStreetFromLatLng(
                  LatLng(order.fromLat ?? 0.0, order.fromLng ?? 0.0));
          } catch (e) {
            emit(const GetCurrentLocationFailedState(
                errorMessage: 'Something went wrong'));
            throw Exception('Something went wrong');
          }
        }
      }
      final location = await _getLoc();
      emit(GetCurrentLocationTakenState(
          currentLocation:
              LatLng(location?.latitude ?? 0.0, location?.longitude ?? 0.0),
          currentLocationStreet: order.from,
          haveStatus: event.haveStatus));
    }
  }

  Future<void> _initFCM(InitFCMEvent event, Emitter<MainState> emit) async {
    // final firebaseMessaging = FirebaseMessaging.instance;
    // await firebaseMessaging.requestPermission();
    // final firebaseToken = await firebaseMessaging.getToken();
    // try {
    //   await _graphQlRepository.createOrUpdateFirebaseCloudMessagingTokenForUser(
    //       firebaseToken: firebaseToken ?? '');
    // } catch (e) {
    //   emit(ServerSideErrorState(message: e.toString()));
    //   throw Exception('Something went wrong');
    // }
  }

  Future<void> _getStreetEventToState(
      GetStreetEvent event, Emitter<MainState> emit) async {
    emit(SearchingState());
    var street = '';
    try {
      if (!event.isDestination) {
        order
          ..fromLat = event.lat
          ..fromLng = event.lng
          ..from = await _locationsRepository.getStreetFromLatLng(
              LatLng(order.fromLat ?? 0.0, order.fromLng ?? 0.0));
        street = order.from;
        if (order.from.isEmpty) {
          order.amount = 0;
        }
      } else {
        order
          ..toLat = event.lat
          ..toLng = event.lng
          ..destination = await _locationsRepository.getStreetFromLatLng(
              LatLng(order.toLat ?? 0.0, order.toLng ?? 0.0));
        if (order.destination.isEmpty) {
          order.amount = 0;
        }
        street = order.destination;
      }
    } catch (e) {
      emit(const GetStreetFailedState(errorMessage: 'Something went wrong'));
      throw Exception('Something went wrong');
    }
    if (order.from.isNotEmpty) {
      invalidItems.remove(RequestFields.from);
    }
    if (order.destination.isNotEmpty) {
      invalidItems.remove(RequestFields.destination);
    }
    emit(GetStreetState(street: street));
  }

  Future<void> _getGetBaseFareEventToState(
      GetBaseFareEvent event, Emitter<MainState> emit) async {
    try {
      final _queryResult = await _graphQlRepository.getMinimalAmount();

      if (_queryResult.hasException) {
        final _exception = _queryResult.exception;
        if (_exception != null) {
          emit(const GetAmountErrorState(errorMessage: 'Something went wrong'));
        }
        return;
      }

      final data = _queryResult.data;
      if (data != null) {
        final getPrices = data['_getPrices'];
        final jsonData = json.decode(getPrices) as Map<String, dynamic>;
        final baseFare = jsonData['minimumAmount'].toDouble();
        final cancellationAmount = jsonData['cancellationAmount'].toDouble();

        order
          ..cancellationAmount = cancellationAmount
          ..baseFare = baseFare;
        emit(GetBaseFareState());
      }
    } catch (e) {
      emit(const GetAmountErrorState(errorMessage: 'Something went wrong'));
      throw Exception(e.toString());
    }
  }

  Future<void> _autoCompleteSearchEventToState(
      AutoCompleteSearchEvent event, Emitter<MainState> emit) async {
    emit(SearchingPlaceState());
    if (event.placeName != '') {
      try {
        final currLoc = await _getLoc();
        final latitude = currLoc?.latitude;
        final longitude = currLoc?.longitude;
        final result = await event.googlePlace.fetchPlace(event.placeName,
            fields: [],
        );

        // emit(AutoCompleteSearchState(predictions: result.place));
      } catch (e) {
        emit(const AutoCompleteSearchFailedState(
            errorMessage: 'Something went wrong'));
        throw Exception('Something went wrong');
      }
    }
  }

  Future<void> _selectFromStreetEventToState(
      SelectFromStreetEvent event, Emitter<MainState> emit) async {
    // SearchingFromPlaceState();
    // order.from = event.fromStreet.description ?? '';
    // final placeID = event.fromStreet.placeId;
    //
    // final coordinates = await _locationsRepository.getDetails(placeID ?? '');
    //
    // order
    //   ..fromLat = coordinates.latitude
    //   ..fromLng = coordinates.longitude;
    //
    // if (order.from.isNotEmpty) {
    //   invalidItems.remove(RequestFields.from);
    // }
    // emit(SelectedFromStreetState());
  }

  Future<void> _selectToStreetEventToState(
      SelectToStreetEvent event, Emitter<MainState> emit) async {
    // SearchingToPlaceState();
    // order.destination = event.toStreet.description ?? '';
    // final placeID = event.toStreet.placeId;
    //
    // final coordinates = await _locationsRepository.getDetails(placeID ?? '');
    //
    // order
    //   ..toLat = coordinates.latitude
    //   ..toLng = coordinates.longitude;
    //
    // if (order.destination.isNotEmpty) {
    //   invalidItems.remove(RequestFields.destination);
    // }
    // emit(SelectedToStreetState());
  }

  Future<void> _changeOrderDestinationEventToState(
      ChangeOrderDestinationEvent event, Emitter<MainState> emit) async {
    event.isFrom ? order.from = '' : order.destination = '';
    emit(NotValidStreetState());
  }

  Future<void> _selectedToStreetEvent(
      SelectedToStreetEvent event, Emitter<MainState> emit) async {
    emit(SelectedToStreetState());
  }

  Future<void> _validateRequestEventToState(
      ValidateRequestEvent event, Emitter<MainState> emit) async {
    emit(ValidatingRequestState());
    if (order.from.isEmpty) {
      invalidItems[RequestFields.from] = true;
    } else {
      invalidItems.remove(RequestFields.from);
    }

    if (order.destination.isEmpty) {
      invalidItems[RequestFields.destination] = true;
    } else {
      invalidItems.remove(RequestFields.destination);
    }
    emit(CheckedRequestState());
    if (invalidItems.isEmpty) {
      add(CreateOrderEvent());
    }
  }

  Future<void> _selectDueDateEventToState(
      SelectDueDateEvent event, Emitter<MainState> emit) async {
    order.dueDate = order.dueDate.difference(DateTime.now()).inMinutes > 0
        ? event.dueDate
        : DateTime.now().get20MinutesLaterRounded();

    emit(SelectedDueDateState());
  }

  Future<void> _addCommentEventToState(
      AddCommentEvent event, Emitter<MainState> emit) async {
    order.comment = event.comment;
    emit(MainStateInitial());
  }

  Future<void> _drawRouteEventToState(
      DrawRouteEvent event, Emitter<MainState> emit) async {
    emit(DrawingState());

    final fromLat = order.fromLat;
    final fromLng = order.fromLng;
    final toLat = order.toLat;
    final toLng = order.toLng;

    if (fromLng != null && fromLat != null && toLat != null && toLng != null) {
      final roadInfo = await _graphQlRepository.getRoad(
          origin: LatLng(fromLat, fromLng), destination: LatLng(toLat, toLng));
      if (roadInfo != null) {
        final direction = roadInfo.direction;
        order
          ..amount = roadInfo.amount
          ..mile = max(roadInfo.miles, minMiles);

        if (direction.polylinePoints.isNotEmpty) {
          emit(DrawnRouteState(direction: direction));
        }
      }
    } else {
      emit(RouteNotFoundState());
    }
  }

  Future<void> _requestStateRecievedEventToState(
      RequestStateRecievedEvent event, Emitter<MainState> emit) async {
    order.state = StateExtension.castStringToStatusEnum(event.requestState);
    emit(OrderStatusChangedState(
        requestState: order.state ?? OrderStatus.none,
        canceledForPay: event.canceledForPay));
  }

  Future<void> _createOrderEventToState(
      CreateOrderEvent event, Emitter<MainState> emit) async {
    emit(CreatingRequestState());
    try {
      final createdOrder = await _graphQlRepository.createOrder(order);

      if (createdOrder != null) {
        order = createdOrder
          ..cancellationAmount = order.cancellationAmount
          ..baseFare = order.baseFare;

        emit(OrderStatusChangedState(
            requestState: order.state ?? OrderStatus.none));
        add(SubscribeToRequestStatesEvent());
      } else {
        emit(SendErrorState());
      }
    } catch (e) {
      emit(const ServerSideErrorState(message: 'Something went wrong'));
      add(const FinishOrderEvent(withError: true));
      throw Exception('Something went wrong');
    }
  }

  Future<void> _cancelOrderEventToState(
      CancelOrderEvent event, Emitter<MainState> emit) async {
    emit(CancelingRequestState());
    try {
      await _graphQlRepository.cancelOrder(event.order);
    } catch (e) {
      emit(const ServerSideErrorState(message: 'Something went wrong'));
      throw Exception('Something went wrong');
    }
    await _clearOrder();
    order.resetOrderData();
    emit(OrderStatusChangedState(requestState: OrderStatus.canceled));
  }

  Future<void> _subscribeToRequestStatesEventToState(
      SubscribeToRequestStatesEvent event, Emitter<MainState> emit) async {
    Future<String?> getUserToken() async {
      final token = await TokenInfo.getToken();
      return token;
    }

    final token = await getUserToken();

    final webSocketLink = WebSocketLink(
      constants.getSubscriptionEndpoint(),
      config: SocketClientConfig(
          inactivityTimeout: const Duration(seconds: 1000),
          initialPayload: () async {
            final token = await getUserToken();
            return {'authentication': 'Bearer $token'};
          }),
    );
    _subscription = _graphQlRepository
        .subscribeToStates(webSocketLink, token ?? '')
        .listen((result) {
      if (result.hasException) {
        return;
      }
      if (result.isLoading) {
        return;
      }

      final resultData = result.data;
      if (resultData != null) {
        status = resultData['orderChanged']['state'];
        order.state = StateExtension.castStringToStatusEnum(status);
        final driver = resultData['orderChanged']['driver'];
        if (driver != null) {
          order.driver = Driver.fromMap(driver as Map<String, dynamic>);
        }
        unsubscribeFromStates(
            webSocketLink, StateExtension.castStringToStatusEnum(status));
        unsubscribeFromLocationTracking(
            StateExtension.castStringToStatusEnum(status));

        final canceledForPay = resultData['orderChanged']['canceledForPay'];

        add(RequestStateRecievedEvent(
            requestState: status, canceledForPay: canceledForPay));
      }
    });
  }

  Future<void> _finishOrderEventToState(
      FinishOrderEvent event, Emitter<MainState> emit) async {
    orderStatus = OrderStatus.none;
    final _withError = event.withError;
    if (_withError) {
      await _clearOrder();
      order.resetOrderData();
    }

    emit(OrderStatusChangedState(
        canceledWithError: _withError,
        requestState: _withError ? OrderStatus.canceled : OrderStatus.rate));
  }

  Future<void> _rateDriverEventToState(
      RateDriverEvent event, Emitter<MainState> emit) async {
    emit(LoadingDriverState());
    try {
      final _queryResult = await _graphQlRepository.rateDriver(
          order.id, event.rating, event.comment);

      if (_queryResult.hasException) {
        emit(RatingNotValidState());
      } else {
        await _clearOrder();
        order.resetOrderData();

        emit(OrderStatusChangedState(requestState: OrderStatus.fromFinished));
        emit(RatedState());
      }
    } catch (e) {
      emit(RatingNotValidState());
      throw Exception('Something went wrong');
    }
  }

  Future<void> _rateDriverCloseEventToState(
      RateDriverCloseEvent event, Emitter<MainState> emit) async {
    order.resetOrderData();

    emit(OrderStatusChangedState(requestState: OrderStatus.fromFinished));
  }

  Future<void> _trackUserLocationEventToState(
      TrackUserLocationEvent event, Emitter<MainState> emit) async {
    if (order.state == OrderStatus.onRoad) {
      if (_locationSubscription != null) {
        _locationSubscription?.cancel();
      }

      final permission = await _locationTracker.hasPermission();
      if (permission != PermissionStatus.denied &&
          permission != PermissionStatus.deniedForever) {
        _locationTracker.getLocation();
      } else {
        emit(const PermissionDeniedState(
            message: 'Please, allow to access your location.'));
      }

      _locationSubscription =
          _locationTracker.onLocationChanged.listen((LocationData newLocationData) {
        add(TrackedLocationEvent(locationData: newLocationData));
      });
    }
  }

  Future<void> _trackedLocationEventToState(
      TrackedLocationEvent event, Emitter<MainState> emit) async {
    emit(TrackedLocationState(locationData: event.locationData));
  }

  Future<void> _checkPaymentMethodEventToState(
      CheckPaymentMethodEvent event, Emitter<MainState> emit) async {
    emit(CheckingPaymentMethodsState());
    try {
      final _queryResult = await _graphQlRepository.hasPaymentMethod();

      if (_queryResult.hasException) {
      } else {
        final _data = _queryResult.data;
        if (_data != null) {
          final _paymentMethod = _data['paymentMethods'];
          if (_paymentMethod.length != 0) {
            emit(ExistingPaymentMethodsState());
          } else {
            emit(NotExistingPaymentMethodsState());
          }
        }
      }
    } catch (e) {
      emit(const PaymentMethodsCheckFailedState(
          errorMessage: 'Something went wrong'));
      throw Exception('Something went wrong');
    }
  }

  Future<void> _viewTripEventToState(
      ViewTripEvent event, Emitter<MainState> emit) async {
    emit(DrawingState());
    final direction = await getDirection();
    if (direction != null) {
      if (direction.polylinePoints.isNotEmpty) {
        emit(ViewTripState(direction: direction));
      }
    } else {
      emit(RouteNotFoundState());
    }
  }

  Future<void> _viewTripCloseEventToState(
      ViewTripCloseEvent event, Emitter<MainState> emit) async {
    emit(DrawingState());
    final direction = await getDirection();
    if (direction != null) {
      if (direction.polylinePoints.isNotEmpty) {
        emit(ViewTripCloseState(direction: direction));
      }
    } else {
      emit(RouteNotFoundState());
    }
  }

  Future<void> _unsubscribeFromLocationEventToState(
      UnsubscribeFromLocationEvent event, Emitter<MainState> emit) async {
    unsubscribeFromLocationTracking(event.order?.state ?? OrderStatus.none);
  }

  void unsubscribeFromStates(WebSocketLink webSocketLink, OrderStatus status) {
    if (status == OrderStatus.canceled || status == OrderStatus.finished) {
      webSocketLink.dispose();
    }
  }

  void unsubscribeFromLocationTracking(OrderStatus status) {
    if (status != OrderStatus.onRoad) {
      _locationSubscription?.cancel();
    }
  }

  Future<Direction?> getDirection() async {
    final roadiInfo = await _graphQlRepository.getRoad(
        origin: LatLng(order.fromLat ?? 0.0, order.fromLng ?? 0.0),
        destination: LatLng(order.toLat ?? 0.0, order.toLng ?? 0.0));
    return roadiInfo?.direction;
  }

  Future<void> _clearOrder() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove('order_id');
  }

  @override
  Future<void> close() async{
    await _subscription?.cancel();
    return super.close();
  }
}
