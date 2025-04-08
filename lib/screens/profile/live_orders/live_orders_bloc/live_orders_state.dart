import 'package:flutter_sample_apps/models/order.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

abstract class LiveOrdersState extends Equatable {
  @override
  List<Object> get props => [];
}

class LiveOrdersInitialState extends LiveOrdersState {
  @override
  List<Object> get props => [];
}

class UnconfirmedOrdersLoadedState extends LiveOrdersState {
  UnconfirmedOrdersLoadedState({required this.unconfirmedOrders});

  final String _id = const Uuid().v4();
  final List<Order> unconfirmedOrders;

  @override
  List<Object> get props => [_id, unconfirmedOrders];
}

class UnconfirmedOrdersLoadingState extends LiveOrdersState {
  @override
  List<Object> get props => [];
}

class UnconfirmedOrdersLoadErrorState extends LiveOrdersState {
  UnconfirmedOrdersLoadErrorState({required this.errorMessage});

  final String errorMessage;

  @override
  List<Object> get props => [errorMessage];
}

class LocationUpdateFailedState extends LiveOrdersState {
  LocationUpdateFailedState({required this.message});
  final String message;
  @override
  List<Object> get props => [];
}

class NoInternetState extends LiveOrdersState {}
