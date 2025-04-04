import 'package:flutter_sample_apps/src/models/user.dart';
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

class UserLogOutEvent extends ProfileInformationEvent {
  const UserLogOutEvent();

  @override
  List<Object> get props => [];
}

class UserPhoneNumberChangedEvent extends ProfileInformationEvent {
  const UserPhoneNumberChangedEvent({required this.changedPhoneNumber});
  final String changedPhoneNumber;

  @override
  List<Object> get props => [changedPhoneNumber];
}

class CheckPaymentMethodEvent extends ProfileInformationEvent {}
