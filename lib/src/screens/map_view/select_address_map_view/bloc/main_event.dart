part of 'main_bloc.dart';

abstract class MainEvent extends Equatable {
  const MainEvent();

  @override
  List<Object> get props => [];
}


class GetCurrentLocationEvent extends MainEvent {
  const GetCurrentLocationEvent(
      {this.getLocationFromShared = false,
      this.setMarker = false,
      this.haveStatus = false});

  final bool getLocationFromShared;
  final bool setMarker;
  final bool haveStatus;

  @override
  List<Object> get props => [getLocationFromShared, setMarker, haveStatus];
}

class InitFCMEvent extends MainEvent {}

class GetStreetEvent extends MainEvent {
  const GetStreetEvent(
      {required this.lat, required this.lng, required this.isDestination});

  final double lat;
  final double lng;
  final bool isDestination;

  @override
  List<Object> get props => [lat, lng, isDestination];
}

class AutoCompleteSearchEvent extends MainEvent {
  const AutoCompleteSearchEvent(
      {required this.googlePlace, required this.placeName});

  final google_places_sdk.FlutterGooglePlacesSdk googlePlace;
  final String placeName;

  @override
  List<Object> get props => [googlePlace, placeName];
}

class SelectFromStreetEvent extends MainEvent {
  const SelectFromStreetEvent({required this.fromStreet});

  final google_places_sdk.AutocompletePrediction fromStreet;

  @override
  List<Object> get props => [fromStreet];
}

class ChangeOrderDestinationEvent extends MainEvent {
  const ChangeOrderDestinationEvent({required this.isFrom});

  final bool isFrom;

  @override
  List<Object> get props => [isFrom];
}

class SelectToStreetEvent extends MainEvent {
  const SelectToStreetEvent({required this.toStreet});

  final google_places_sdk.AutocompletePrediction toStreet;

  @override
  List<Object> get props => [toStreet];
}

class ValidateRequestEvent extends MainEvent {}

class SelectedToStreetEvent extends MainEvent {}

class CancelOrderEvent extends MainEvent {
  const CancelOrderEvent({required this.order});

  final Order order;

  @override
  List<Object> get props => [order];
}

class SelectDueDateEvent extends MainEvent {
  const SelectDueDateEvent({required this.dueDate});

  final DateTime dueDate;

  @override
  List<Object> get props => [dueDate];
}

class AddCommentEvent extends MainEvent {
  const AddCommentEvent({required this.comment});

  final String comment;

  @override
  List<Object> get props => [comment];
}

class DrawRouteEvent extends MainEvent {}

class CreateOrderEvent extends MainEvent {}

class RequestStateRecievedEvent extends MainEvent {
  const RequestStateRecievedEvent(
      {required this.requestState, this.canceledForPay = false});

  final String requestState;
  final bool? canceledForPay;

  @override
  List<Object> get props => [requestState];
}

class SubscribeToRequestStatesEvent extends MainEvent {}

class FinishOrderEvent extends MainEvent {
  const FinishOrderEvent({this.withError = false});

  final bool withError;

  @override
  List<Object> get props => [withError];
}

class RateDriverEvent extends MainEvent {
  const RateDriverEvent({required this.rating, required this.comment});

  final double rating;
  final String comment;

  @override
  List<Object> get props => [rating, comment];
}

class RateDriverCloseEvent extends MainEvent {}

class TrackUserLocationEvent extends MainEvent {}

class TrackedLocationEvent extends MainEvent {
  const TrackedLocationEvent({required this.locationData});

  final LocationData locationData;

  @override
  List<Object> get props => [locationData];
}

class ViewTripEvent extends MainEvent {}

class ViewTripCloseEvent extends MainEvent {}

class CheckPaymentMethodEvent extends MainEvent {}

class UnsubscribeFromLocationEvent extends MainEvent {
  const UnsubscribeFromLocationEvent({this.order});

  final Order? order;

  @override
  List<Object> get props => [];
}

class GetBaseFareEvent extends MainEvent {}
