import 'dart:typed_data';

import 'package:flutter_sample_apps/models/driver.dart';
import 'package:flutter_sample_apps/screens/login_signup/shared/profile_information/photo_information.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

abstract class UserInfoEvent extends Equatable {
  const UserInfoEvent();
  @override
  List<Object> get props => [];
}

class UserInfoInitialEvent extends UserInfoEvent {
  const UserInfoInitialEvent();

  @override
  List<Object> get props => [];
}

class AddBirthDateEvent extends UserInfoEvent {
  const AddBirthDateEvent();

  @override
  List<Object> get props => [];
}

class ChooseBirthDateEvent extends UserInfoEvent {
  const ChooseBirthDateEvent({required this.birthDate});

  final DateTime birthDate;

  @override
  List<Object> get props => [birthDate];
}

class DriverValidationEvent extends UserInfoEvent {
  const DriverValidationEvent({required this.driver});

  final Driver driver;
}

class ChoosePhotoEvent extends UserInfoEvent {
  ChoosePhotoEvent({required this.direction});
  final PhotoDirection direction;
  final _id = const Uuid().v4();

  @override
  List<Object> get props => [direction, _id];
}

class AddPhotoEvent extends UserInfoEvent {
  final _id = const Uuid().v4();
  @override
  List<Object> get props => [_id];
}

class PhotoIsAdded extends UserInfoEvent {}

class LoadUserCityEvent extends UserInfoEvent {}

class ChoosingUserCityEvent extends UserInfoEvent {
  const ChoosingUserCityEvent({required this.city});
  final String city;
  @override
  List<Object> get props => [city];
}

class LoadCitiesEvent extends UserInfoEvent {}

class DownLoadImage extends UserInfoEvent {
  const DownLoadImage({required this.bytes});
  final Uint8List bytes;
  @override
  List<Object> get props => [bytes];
}

class UnselectedImageEvent extends UserInfoEvent {
  @override
  List<Object> get props => [];
}

class GetAdminPhoneNumberEvent extends UserInfoEvent {}
