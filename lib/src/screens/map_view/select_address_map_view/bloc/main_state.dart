part of 'main_bloc.dart';

abstract class MainState extends Equatable {
  const MainState();

  @override
  List<Object> get props => [];
}

class MainStateInitial extends MainState {}

class GetCurrentLocationTakenState extends MainState {
  const GetCurrentLocationTakenState(
      {required this.currentLocationStreet,
      required this.currentLocation,
      this.setMarker = false,
      this.haveStatus = false});
  final String currentLocationStreet;
  final LatLng currentLocation;
  final bool setMarker;
  final bool haveStatus;
  @override
  List<Object> get props => [];
}

class GetCurrentLocationFailedState extends MainState {
  const GetCurrentLocationFailedState({required this.errorMessage});

  final String errorMessage;

  @override
  List<Object> get props => [errorMessage];
}

class SearchingState extends MainState {}

class SearchingselctedToStreetState extends MainState {}

class SearchingCurrentLocationState extends MainState {}

class SearchingPlaceState extends MainState {}

class SearchingToPlaceState extends MainState {}

class SearchingFromPlaceState extends MainState {}

class GetStreetState extends MainState {
  const GetStreetState({required this.street});

  final String street;

  @override
  List<Object> get props => [street];
}

class GetStreetFailedState extends MainState {
  const GetStreetFailedState({required this.errorMessage});

  final String errorMessage;

  @override
  List<Object> get props => [errorMessage];
}

class GetAmountErrorState extends MainState {
  const GetAmountErrorState({required this.errorMessage});

  final String errorMessage;

  @override
  List<Object> get props => [];
}

class AutoCompleteSearchState extends MainState {
  const AutoCompleteSearchState({required this.predictions});
  final List<google_places_sdk.AutocompletePrediction>? predictions;
  @override
  List<Object> get props => [];
}

class AutoCompleteSearchFailedState extends MainState {
  const AutoCompleteSearchFailedState({required this.errorMessage});
  final String errorMessage;
  @override
  List<Object> get props => [errorMessage];
}

class SelectedToStreetState extends MainState {}

class SelectedFromStreetState extends MainState {}

class NotValidStreetState extends MainState {}

class CheckedRequestState extends MainState {}

class ValidatingRequestState extends MainState {}

class SelectedDueDateState extends MainState {
  SelectedDueDateState();

  final String _id = const Uuid().v4();

  @override
  List<Object> get props => [_id];
}

class DrawingState extends MainState {}

class DrawnRouteState extends MainState {
  const DrawnRouteState({this.direction});

  final Direction? direction;

  @override
  List<Object> get props => [];
}

class RouteNotFoundState extends MainState {}

class SuccessfullySentRequestState extends MainState {}

class SendErrorState extends MainState {}

class OrderStatusChangedState extends MainState {
  OrderStatusChangedState(
      {required this.requestState,
      this.canceledWithError = false,
      this.canceledForPay = false});

  final OrderStatus requestState;
  final bool? canceledForPay;
  final bool canceledWithError;
  final String _id = const Uuid().v4();

  @override
  List<Object> get props => [_id];
}

class CreatingRequestState extends MainState {}

class RatedState extends MainState {}

class CancelingRequestState extends MainState {}

class RequestCanceledState extends MainState {}

class WaitingStateChangeState extends MainState {}

class RatingNotValidState extends MainState {}

class TrackedLocationState extends MainState {
  const TrackedLocationState({required this.locationData});

  final LocationData locationData;

  @override
  List<Object> get props =>
      [locationData.latitude ?? 0.0, locationData.longitude ?? 0.0];
}

class LoadingDriverState extends MainState {}

class CheckingPaymentMethodsState extends MainState {}

class ViewTripState extends MainState {
  const ViewTripState({this.direction});
  final Direction? direction;

  @override
  List<Object> get props => [];
}

class ViewTripCloseState extends MainState {
  const ViewTripCloseState({this.direction});
  final Direction? direction;

  @override
  List<Object> get props => [];
}

class ExistingPaymentMethodsState extends MainState {
  ExistingPaymentMethodsState();
  final String _id = const Uuid().v4();

  @override
  List<Object> get props => [_id];
}

class NotExistingPaymentMethodsState extends MainState {
  NotExistingPaymentMethodsState();
  final String _id = const Uuid().v4();

  @override
  List<Object> get props => [_id];
}

class PaymentMethodsCheckFailedState extends MainState {
  const PaymentMethodsCheckFailedState({required this.errorMessage});

  final String errorMessage;

  @override
  List<Object> get props => [errorMessage];
}

class PermissionDeniedState extends MainState {
  const PermissionDeniedState({required this.message});
  final String message;
}

class ServerSideErrorState extends MainState {
  const ServerSideErrorState({required this.message});
  final String message;
  @override
  List<Object> get props => [message];
}

class GetBaseFareState extends MainState {}
