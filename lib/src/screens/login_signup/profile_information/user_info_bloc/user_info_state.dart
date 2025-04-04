import 'package:equatable/equatable.dart';
import 'package:flutter_sample_apps/src/models/user.dart';

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

class UserInfoLoadingState extends UserInfoState {
  UserInfoLoadingState();

  @override
  List<Object> get props => [];
}

class UserInvalidState extends UserInfoState {
  UserInvalidState({required this.error});

  final Map<String, String> error;

  @override
  List<Object> get props => [error];
}

class UserValidState extends UserInfoState {
  UserValidState({required this.user});

  final User user;

  @override
  List<Object> get props => [user];
}
