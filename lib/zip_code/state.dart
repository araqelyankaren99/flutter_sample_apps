import 'package:equatable/equatable.dart';

abstract class ZipCodeState extends Equatable {
  const ZipCodeState();

  @override
  List<Object> get props => [];
}

class ZipCodeInitial extends ZipCodeState {
  const ZipCodeInitial();
}

class ZipCodeChangedState extends ZipCodeState {
  const ZipCodeChangedState({required this.zipCode});

  final String zipCode;

  @override
  List<Object> get props => [zipCode];
}

class CityChangedState extends ZipCodeState {
  const CityChangedState({required this.city});

  final String city;

  @override
  List<Object> get props => [city];
}

class AddressStateChangedState extends ZipCodeState {
  const AddressStateChangedState({required this.addressState});

  final String addressState;

  @override
  List<Object> get props => [addressState];
}

class ZipCodeLoadingState extends ZipCodeState {
  const ZipCodeLoadingState();
}

class CityEnabledState extends ZipCodeState {
  const CityEnabledState();
}

class CityDisabledState extends ZipCodeState {
  const CityDisabledState();
}

class CityUpdatedState extends ZipCodeState {
  const CityUpdatedState({required this.city});

  final String city;

  @override
  List<Object> get props => [city];
}

class StateEnabledState extends ZipCodeState {
  const StateEnabledState();
}

class StateDisabledState extends ZipCodeState {
  const StateDisabledState();
}

class StateChangedState extends ZipCodeState {
  const StateChangedState({required this.addressState});

  final String addressState;

  @override
  List<Object> get props => [addressState];
}

class CityClearedState extends ZipCodeState {
  const CityClearedState();
}

class StateClearedState extends ZipCodeState {
  const StateClearedState();
}

class ZipRequestFinishedState extends ZipCodeState {
  const ZipRequestFinishedState();
}