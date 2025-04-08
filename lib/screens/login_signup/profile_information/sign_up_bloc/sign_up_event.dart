import 'package:flutter_sample_apps/models/driver.dart';
import 'package:flutter_sample_apps/screens/login_signup/profile_information/sign_up_bloc/sign_up_state.dart';
import 'package:equatable/equatable.dart';

abstract class SignUpEvent extends Equatable {
  const SignUpEvent();
  @override
  List<Object> get props => [];
}

class CreateDriverEvent extends SignUpEvent {
  const CreateDriverEvent({required this.driver});

  final Driver driver;

  @override
  List<Object> get props => [driver];
}

class DriverIsAlreadyCreatedEvent extends SignUpEvent {
  const DriverIsAlreadyCreatedEvent({required this.driver});
  final Driver driver;

  @override
  List<Object> get props => [driver];
}

class ListenDriverActivationEvent extends SignUpEvent {}

class DriverActivationChangeEvent extends SignUpEvent {
  const DriverActivationChangeEvent({required this.state});
  final SignUpState state;
  @override
  List<Object> get props => [state];
}
