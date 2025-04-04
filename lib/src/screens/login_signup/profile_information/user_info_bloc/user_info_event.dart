import 'package:equatable/equatable.dart';
import 'package:flutter_sample_apps/src/models/user.dart';

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

class UserValidationEvent extends UserInfoEvent {
  const UserValidationEvent({required this.user});

  final User user;

  @override
  List<Object> get props => [user];
}

class UserInfoLoadingEvent extends UserInfoEvent {
  const UserInfoLoadingEvent();

  @override
  List<Object> get props => [];
}
