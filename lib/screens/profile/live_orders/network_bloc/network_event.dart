import 'package:flutter_sample_apps/screens/profile/live_orders/network_bloc/network_state.dart';
import 'package:equatable/equatable.dart';

abstract class NetworkEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class ListenConnection extends NetworkEvent {}

class ConnectionChanged extends NetworkEvent {
  ConnectionChanged({required this.connection});
  final NetworkState connection;
}

class CheckConnection extends NetworkEvent {}
