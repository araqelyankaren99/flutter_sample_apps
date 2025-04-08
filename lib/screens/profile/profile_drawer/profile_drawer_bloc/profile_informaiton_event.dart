import 'package:flutter_sample_apps/models/user.dart';
import 'package:equatable/equatable.dart';

abstract class ProfileInformationEvent extends Equatable {
  const ProfileInformationEvent();

  @override
  List<Object> get props => [];
}

class GetProfileInformationEvent extends ProfileInformationEvent {
  const GetProfileInformationEvent();

  @override
  List<Object> get props => [];
}

class UserEditEvent extends ProfileInformationEvent {
  const UserEditEvent({required this.user, required this.userBeforeEditing});

  final User user;
  final User userBeforeEditing;

  @override
  List<Object> get props => [user, userBeforeEditing];
}

class DriverLogOutEvent extends ProfileInformationEvent {
  const DriverLogOutEvent();

  @override
  List<Object> get props => [];
}

class DriverPhoneNumberChangedEvent extends ProfileInformationEvent {
  const DriverPhoneNumberChangedEvent({required this.changedPhoneNumber});
  final String changedPhoneNumber;

  @override
  List<Object> get props => [changedPhoneNumber];
}
