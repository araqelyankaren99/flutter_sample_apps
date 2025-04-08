part of 'order_view_bloc.dart';

abstract class OrderViewState extends Equatable {
  const OrderViewState();

  @override
  List<Object> get props => [];
}

class OrderViewInitial extends OrderViewState {}

class OrderConfirmFailedState extends OrderViewState {}

class CannotConfirmOrderState extends OrderViewState {
  const CannotConfirmOrderState(this.errorMessagePreferance);
  final ErrorMessagePreferance errorMessagePreferance;
  @override
  List<Object> get props => [errorMessagePreferance];
}

class AwaitUserFailedState extends OrderViewState {}

class StartOrderFailedState extends OrderViewState {}

class CancelOrderFailedState extends OrderViewState {}

class ServerErrorState extends OrderViewState {
  const ServerErrorState({required this.message});
  final String message;
}

class FinishOrderFailedState extends OrderViewState {}

class OrderStatusChangedState extends OrderViewState {
  const OrderStatusChangedState(
      {required this.orderStatus, this.showAlert = true,});
  final OrderStatus orderStatus;
  final bool showAlert;
  @override
  List<Object> get props => [orderStatus, showAlert];
}

class ChangingState extends OrderViewState {
  @override
  List<Object> get props => [];
}

class CancelingState extends OrderViewState {}

class DrawingState extends OrderViewState {
  const DrawingState();
  @override
  List<Object> get props => [];
}

class DrawnRouteState extends OrderViewState {
  const DrawnRouteState(
      {required this.origin, required this.destination, this.direction,});
  final Direction? direction;
  final LatLng origin;
  final LatLng destination;
  @override
  List<Object> get props => [];
}

class RouteNotFoundState extends OrderViewState {
  const RouteNotFoundState();
  @override
  List<Object> get props => [];
}

class TrackedLocationState extends OrderViewState {
  const TrackedLocationState({required this.locationData});
  final LocationData locationData;

  @override
  List<Object> get props =>
      [locationData.latitude ?? 0.0, locationData.longitude ?? 0.0];
}

class OrderTakenState extends OrderViewState {
  const OrderTakenState();
}

class FirebaseTokenUpdateFailed extends OrderViewState {
  const FirebaseTokenUpdateFailed({required this.message});
  final String message;
}
