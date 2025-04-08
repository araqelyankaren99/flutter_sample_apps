import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter_sample_apps/middlewares/repositories/driver_repository.dart';
import 'package:flutter_sample_apps/middlewares/repositories/graph_ql_repository.dart';
import 'package:flutter_sample_apps/middlewares/repositories/order_repository.dart';
import 'package:flutter_sample_apps/models/direction.dart';
import 'package:flutter_sample_apps/models/order.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:location/location.dart' as location_package;

part 'order_view_event.dart';
part 'order_view_state.dart';

enum ErrorMessagePreferance { confirmed, failed, somethingWentWrong }

class OrderViewBloc extends Bloc<OrderViewEvent, OrderViewState> {
  OrderViewBloc() : super(OrderViewInitial());

  final GraphQlRepository _graphQlRepository = GraphQlRepository();
  final OrderRepository _orderRepository = OrderRepository();
  final DriverRepository _driverRepository = DriverRepository();
  StreamSubscription? _locationSubscription;
  final location_package.Location _locationTracker =
      location_package.Location();
  StreamSubscription? _subscription;

  @override
  Stream<OrderViewState> mapEventToState(
    OrderViewEvent event,
  ) async* {
    if (event is ConfirmOrderEvent) {
      yield* confirmOrderEventToState(event);
    }
    if (event is AwaitUserEvent) {
      yield* awaitUserEventToState(event);
    }
    if (event is FinishOrderEvent) {
      yield* finishOrderEventToState(event);
    }
    if (event is CancelOrderEvent) {
      yield* cancelOrderEventToState(event);
    }
    if (event is StartOrderEvent) {
      yield* startOrderEventToState(event);
    }
    if (event is DrawRouteEvent) {
      yield* drawRouteEventToState(event);
    }
    if (event is TrackUserLocationEvent) {
      yield* trackUserLocationEventToState(event);
    }
    if (event is TrackedLocationEvent) {
      yield* trackedLocationEventToState(event);
    }
    if (event is UnsubscribeFromTrackingEvent) {
      yield* unsubscribeFromTrackingEventToState(event);
    }
    if (event is InitFCMEvent) {
      // yield* initFirebaseMessagignEventToState(event);
    }
    if (event is GetOrderCurrentState) {
      yield* getOrderCurrentStateEventToState(event);
    }
    if (event is SubscribeToStates) {
      yield* subscribeEventToState(event);
    }
    if (event is StatusChangeEvent) {
      yield* statusChangeEventToState(event);
    }
  }

  Stream<OrderViewState> confirmOrderEventToState(
      ConfirmOrderEvent event,) async* {
    yield ChangingState();
    if (event.orderId.isNotEmpty) {
      final orderStatus = await _confirmOrder(event.orderId);
      if (orderStatus != null) {
        if (orderStatus == ErrorMessagePreferance.somethingWentWrong) {
          yield OrderConfirmFailedState();
        } else if (orderStatus == ErrorMessagePreferance.confirmed) {
          await _orderRepository.storeId(event.orderId);
          add(SubscribeToStates(orderId: event.orderId));
          yield const OrderStatusChangedState(
              orderStatus: OrderStatus.confirmed,);
        } else {
          yield CannotConfirmOrderState(orderStatus);
        }
      }
    }
  }

  Future<ErrorMessagePreferance?> _confirmOrder(String orderId) async {
    try {
      final result = await _graphQlRepository.confirmOrder(orderId: orderId);
      final data = result.data;
      if (data != null) {
        if (data['confirmOrder']['state'] == 'ACCEPTED') {
          return ErrorMessagePreferance.confirmed;
        }
      }
    } on Exception catch (e) {
      if (e.toString() == Exception(ErrorType.customError).toString()) {
        return ErrorMessagePreferance.somethingWentWrong;
      } else {
        return ErrorMessagePreferance.failed;
      }
    }
    return null;
  }

  Stream<OrderViewState> startOrderEventToState(StartOrderEvent event) async* {
    yield ChangingState();
    try {
      final result =
          await _graphQlRepository.startOrder(orderId: event.orderId);
      if (event.orderId.isNotEmpty) {
        var orderStatus = OrderStatus.none;
        final data = result.data;

        if (data?['startOrder']['state'] == 'ON ROAD') {
          orderStatus = OrderStatus.onRoad;
        }
        yield OrderStatusChangedState(orderStatus: orderStatus);
      } else {
        yield StartOrderFailedState();
      }
    } catch (e) {
      yield ServerErrorState(message: e.toString());
    }
  }

  Stream<OrderViewState> awaitUserEventToState(AwaitUserEvent event) async* {
    yield ChangingState();

    try {
      final result = await _graphQlRepository.awaitUser(orderId: event.orderId);
      if (event.orderId.isNotEmpty) {
        var orderStatus = OrderStatus.none;
        final data = result.data;

        if (data?['awaitUser']['state'] == 'WAITING') {
          orderStatus = OrderStatus.awaiting;
        }
        yield OrderStatusChangedState(orderStatus: orderStatus);
      } else {
        yield AwaitUserFailedState();
      }
    } catch (e) {
      yield ServerErrorState(message: e.toString());
    }
  }

  Stream<OrderViewState> finishOrderEventToState(
      FinishOrderEvent event,) async* {
    yield ChangingState();

    try {
      if (event.orderId.isNotEmpty) {
        final result =
            await _graphQlRepository.finishOrder(orderId: event.orderId);
        final data = result.data;
        if (data != null) {
          var orderStatus = OrderStatus.none;
          if (data['finishOrder']['state'] == 'FINISHED') {
            add(const UnsubscribeFromTrackingEvent());
            await _orderRepository.deleteStoreId();
            orderStatus = OrderStatus.finished;
          }
          yield OrderStatusChangedState(orderStatus: orderStatus);
        }
      } else {
        yield FinishOrderFailedState();
      }
    } catch (e) {
      yield ServerErrorState(message: e.toString());
    }
  }

  Stream<OrderViewState> cancelOrderEventToState(
      CancelOrderEvent event,) async* {
    yield CancelingState();
    try {
      if (event.orderId.isNotEmpty) {
        final result =
            await _graphQlRepository.cancelOrder(orderId: event.orderId);

        if (result.data == null) {
          add(const UnsubscribeFromTrackingEvent());
          await _orderRepository.deleteStoreId();
        }
        yield const OrderStatusChangedState(orderStatus: OrderStatus.canceled);
      } else {
        yield CancelOrderFailedState();
      }
    } catch (e) {
      yield ServerErrorState(message: e.toString());
    }
  }

  Stream<OrderViewState> drawRouteEventToState(DrawRouteEvent event) async* {
    yield const DrawingState();

    final fromLat = event.origin.latitude;
    final fromLng = event.origin.longitude;
    final toLat = event.destination.latitude;
    final toLng = event.destination.longitude;

    try {
      final roadInfo = await _graphQlRepository.getRoad(
          origin: LatLng(fromLat, fromLng), destination: LatLng(toLat, toLng),);

      if (roadInfo != null) {
        final direction = roadInfo.direction;

        if (direction.polylinePoints.isNotEmpty) {
          yield DrawnRouteState(
              direction: direction,
              origin: event.origin,
              destination: event.destination,);
        }
      } else {
        yield const RouteNotFoundState();
      }
    } catch (e) {
      yield ServerErrorState(message: e.toString());
      throw Exception(e.toString());
    }
  }

  Stream<OrderViewState> trackUserLocationEventToState(
      TrackUserLocationEvent event,) async* {
    try {
      if (_locationSubscription != null) {
        _locationSubscription?.cancel();
      }

      _locationTracker.getLocation();

      _locationSubscription =
          _locationTracker.onLocationChanged.listen((newLocationData) {
        add(TrackedLocationEvent(locationData: newLocationData));
      });
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        debugPrint('Permission Denied');
      }
    }
  }

  Stream<OrderViewState> trackedLocationEventToState(
      TrackedLocationEvent event,) async* {
    yield TrackedLocationState(locationData: event.locationData);
  }

  Stream<OrderViewState> unsubscribeFromTrackingEventToState(
      UnsubscribeFromTrackingEvent event,) async* {
    _locationSubscription?.cancel();
  }

  Stream<OrderViewState> initFirebaseMessagingEventToState(
      InitFCMEvent event,) async* {
    // final firebaseMessaging = FirebaseMessaging.instance;
    // await firebaseMessaging.requestPermission();
    // final firebaseToken = await firebaseMessaging.getToken();
    try {
      await _graphQlRepository
          .createOrUpdateFirebaseCloudMessagingTokenForDriver(
              // firebaseToken: firebaseToken ?? '',
              firebaseToken: '',
      );
    } catch (e) {
      yield FirebaseTokenUpdateFailed(message: e.toString());
    }
  }

  Stream<OrderViewState> subscribeEventToState(SubscribeToStates event) async* {
    await _subscription?.cancel();
    final token = await _driverRepository.getToken();
    _subscription = _graphQlRepository
        .subscribe(token: token, lastOrderId: event.orderId)
        .listen((
      result,
    ) {
      if (result.hasException) {
        throw Exception('Failed to subscribe');
      }
      if (result.isLoading) {
        return;
      }
      final data = result.data;
      if (data != null) {
        final orderStatus = StateExtension.castStringToStatusEnum(data['orderChanged']['state'] as String);
        if (orderStatus == OrderStatus.canceled) {
          add(StatusChangeEvent(
              orderStatus: StateExtension.castStringToStatusEnum(data['orderChanged']['state'] as String),),);
        }
        if (orderStatus == OrderStatus.canceled ||
            orderStatus == OrderStatus.finished) {
          _orderRepository.deleteStoreId();
          _subscription?.cancel();
        }
      }
    }, onDone: () async => await _subscription?.cancel(),);
  }

  Stream<OrderViewState> getOrderCurrentStateEventToState(
      GetOrderCurrentState event,) async* {
    yield OrderStatusChangedState(
        orderStatus: event.order.state ?? OrderStatus.none, showAlert: false,);
  }

  Stream<OrderViewState> statusChangeEventToState(
      StatusChangeEvent event,) async* {
    yield OrderStatusChangedState(orderStatus: event.orderStatus);
  }
}
