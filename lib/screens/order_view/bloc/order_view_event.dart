part of 'order_view_bloc.dart';

abstract class OrderViewEvent extends Equatable {
  const OrderViewEvent();

  @override
  List<Object> get props => [];
}

class ConfirmOrderEvent extends OrderViewEvent {
  const ConfirmOrderEvent({
    required this.orderId,
  });

  final String orderId;

  @override
  List<Object> get props => [orderId];
}

class AwaitUserEvent extends OrderViewEvent {
  const AwaitUserEvent({
    required this.orderId,
  });

  final String orderId;

  @override
  List<Object> get props => [orderId];
}

class CancelOrderEvent extends OrderViewEvent {
  const CancelOrderEvent({
    required this.orderId,
  });

  final String orderId;

  @override
  List<Object> get props => [orderId];
}

class FinishOrderEvent extends OrderViewEvent {
  const FinishOrderEvent({
    required this.orderId,
  });

  final String orderId;

  @override
  List<Object> get props => [orderId];
}

class StartOrderEvent extends OrderViewEvent {
  const StartOrderEvent({
    required this.orderId,
  });

  final String orderId;

  @override
  List<Object> get props => [orderId];
}

class DrawRouteEvent extends OrderViewEvent {
  const DrawRouteEvent({required this.origin, required this.destination});
  final LatLng origin;
  final LatLng destination;
  @override
  List<Object> get props => [];
}

class TrackUserLocationEvent extends OrderViewEvent {
  const TrackUserLocationEvent();

  @override
  List<Object> get props => [];
}

class TrackedLocationEvent extends OrderViewEvent {
  const TrackedLocationEvent({required this.locationData});
  final LocationData locationData;

  @override
  List<Object> get props => [locationData];
}

class UnsubscribeFromTrackingEvent extends OrderViewEvent {
  const UnsubscribeFromTrackingEvent();
}

class InitFCMEvent extends OrderViewEvent {
  const InitFCMEvent();
}

class GetOrderCurrentState extends OrderViewEvent {
  const GetOrderCurrentState({required this.order});
  final Order order;
}

class SubscribeToStates extends OrderViewEvent {
  const SubscribeToStates({required this.orderId});
  final String orderId;
}

class StatusChangeEvent extends OrderViewEvent {
  const StatusChangeEvent({required this.orderStatus});
  final OrderStatus orderStatus;
}
