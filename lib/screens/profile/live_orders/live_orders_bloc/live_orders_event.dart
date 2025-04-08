import 'package:equatable/equatable.dart';

abstract class LiveOrdersEvent extends Equatable {
  const LiveOrdersEvent();

  @override
  List<Object> get props => [];
}

class GetUnconfirmedOrdersEvent extends LiveOrdersEvent {
  const GetUnconfirmedOrdersEvent();

  @override
  List<Object> get props => [];
}

class UpdateDriverLocationEvent extends LiveOrdersEvent {
  const UpdateDriverLocationEvent();

  @override
  List<Object> get props => [];
}

class NoInternetEvent extends LiveOrdersEvent {}
