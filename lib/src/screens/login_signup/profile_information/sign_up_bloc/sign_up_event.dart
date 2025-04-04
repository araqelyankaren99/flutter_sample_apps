import 'package:equatable/equatable.dart';
import 'package:flutter_sample_apps/src/models/user.dart';

abstract class SignUpEvent extends Equatable {
  const SignUpEvent();
  @override
  List<Object> get props => [];
}

class CheckConnectivityEvent extends SignUpEvent {
  const CheckConnectivityEvent();
}

class CreateUserEvent extends SignUpEvent {
  const CreateUserEvent({required this.user});

  final User user;

  @override
  List<Object> get props => [user];
}
