import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

abstract class UserInfoState extends Equatable {
  @override
  List<Object> get props => [];
}

class UserInfoInitialState extends UserInfoState {
  UserInfoInitialState();

  @override
  List<Object> get props => [];
}

class AddingBirthDateState extends UserInfoState {}

class AddedBirthDateState extends UserInfoState {
  AddedBirthDateState({required this.birthDate});
  final DateTime birthDate;

  @override
  List<Object> get props => [birthDate];
}

class UserInfoLoadingState extends UserInfoState {}

class DriverInvalidState extends UserInfoState {
  DriverInvalidState({required this.error});

  final Map<String, String> error;

  @override
  List<Object> get props => [error];
}

class DriverValidState extends UserInfoState {}

class AddingPhotoState extends UserInfoState {
  final _id = const Uuid().v4();
  @override
  List<Object> get props => [_id];
}

class AddedPhotoState extends UserInfoState {
  AddedPhotoState({required this.image, this.isDownLoaded = false});
  final File image;
  final bool isDownLoaded;
  final _id = const Uuid().v4();

  @override
  List<Object> get props => [image, _id];
}

class UserFieldLoadingState extends UserInfoState {}

class AddingUserCityState extends UserInfoState {
  AddingUserCityState({required this.cities});
  final List cities;

  @override
  List<Object> get props => [cities];
}

class LoadErrorState extends UserInfoState {
  LoadErrorState({required this.error});
  final String error;
  @override
  List<String> get props => [error];
}

class CityIsChoosedState extends UserInfoState {
  CityIsChoosedState({required this.city});
  final String city;
  @override
  List<Object> get props => [city];
}

class UnselectedImageState extends UserInfoState {
  @override
  List<Object> get props => [];
}

class GetAdminPhoneNumberState extends UserInfoState {}

class GetPhoneNumberErrorState extends UserInfoState {}
