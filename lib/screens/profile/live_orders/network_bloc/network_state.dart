import 'package:flutter_sample_apps/main.dart';
import 'package:equatable/equatable.dart';

abstract class NetworkState extends Equatable {
  @override
  List<Object> get props => [];
}

class ConnectionInitial extends NetworkState {}

class ConnectionSuccess extends NetworkState {
  ConnectionSuccess({required this.homeScreen, this.firstCheck = true});
  final Map<HomeScreenType, Object?> homeScreen;
  final bool firstCheck;
}

class ConnectionFailure extends NetworkState {}
