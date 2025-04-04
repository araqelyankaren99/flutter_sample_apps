import 'package:equatable/equatable.dart';

abstract class SignUpState extends Equatable {
  @override
  List<Object> get props => [];
}

class SignUpInitialState extends SignUpState {
  SignUpInitialState();

  @override
  List<Object> get props => [];
}

class UserCreatedState extends SignUpState {
  UserCreatedState({required this.id});
  final String id;

  @override
  List<Object> get props => [id];
}

class SignUpLoadingState extends SignUpState {
  SignUpLoadingState();

  @override
  List<Object> get props => [];
}

class UserCreateErrorState extends SignUpState {
  UserCreateErrorState({required this.errorMessage});

  final String errorMessage;

  @override
  List<Object> get props => [errorMessage];
}
