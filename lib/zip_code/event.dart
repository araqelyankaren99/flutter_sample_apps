import 'package:equatable/equatable.dart';

abstract class ZipCodeEvent extends Equatable {
  const ZipCodeEvent();

  @override
  List<Object?> get props => [];
}

class ChangeZipCodeEvent extends ZipCodeEvent {
  const ChangeZipCodeEvent({required this.zipCode});

  final String zipCode;

  @override
  List<Object?> get props => [zipCode];
}

class ChangeCityEvent extends ZipCodeEvent {
  const ChangeCityEvent({required this.city});

  final String city;

  @override
  List<Object> get props => [city];
}

class ChangeAddressStateEvent extends ZipCodeEvent {
  const ChangeAddressStateEvent({required this.addressState});

  final String addressState;

  @override
  List<Object> get props => [];
}

class CheckZipCodeEvent extends ZipCodeEvent {
  const CheckZipCodeEvent({required this.zipCode});

  final String zipCode;

  @override
  List<Object> get props => [zipCode];
}

class ZipCodeResultNotExistingEvent extends ZipCodeEvent {
  const ZipCodeResultNotExistingEvent();
}

class CheckCityEvent extends ZipCodeEvent {
  const CheckCityEvent({required this.city});

  final String? city;

  @override
  List<Object?> get props => [city];
}

class CheckStateEvent extends ZipCodeEvent {
  const CheckStateEvent({required this.addressState});

  final String? addressState;

  @override
  List<Object?> get props => [addressState];
}

class ClearZipCodeDataEvent extends ZipCodeEvent {
  const ClearZipCodeDataEvent();
}