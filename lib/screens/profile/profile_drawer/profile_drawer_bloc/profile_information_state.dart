import 'package:flutter_sample_apps/models/user.dart';
import 'package:equatable/equatable.dart';

abstract class ProfileInformationState extends Equatable {
  @override
  List<Object> get props => [];
}

class ProfileInformationInitialState extends ProfileInformationState {
  @override
  List<Object> get props => [];
}

class LoadingState extends ProfileInformationState {
  @override
  List<Object> get props => [];
}

class ProfileInformationLoaded extends ProfileInformationState {
  ProfileInformationLoaded();

  @override
  List<Object> get props => [];
}

class ProfileInformationLoadErrorState extends ProfileInformationState {
  ProfileInformationLoadErrorState({required this.errorMessage});

  final String errorMessage;

  @override
  List<Object> get props => [errorMessage];
}

class UserEditErrorState extends ProfileInformationState {
  UserEditErrorState();

  @override
  List<Object> get props => [];
}

class UserEditSuccessState extends ProfileInformationState {
  UserEditSuccessState({required this.editedUser});

  final User editedUser;

  @override
  List<Object> get props => [editedUser];
}

class DriverLoggedOutState extends ProfileInformationState {
  DriverLoggedOutState();

  @override
  List<Object> get props => [];
}
