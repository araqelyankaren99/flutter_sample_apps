import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

abstract class SignUpState extends Equatable {
  @override
  List<Object> get props => [];
}

class SignUpInitialState extends SignUpState {
  SignUpInitialState();

  @override
  List<Object> get props => [];
}

class DriverCreatedState extends SignUpState {
  DriverCreatedState({
    required this.id,
    this.firstTimeCreated = false,
  });
  final String id;
  final bool firstTimeCreated;

  @override
  List<Object> get props => [id];
}

class DriverCreateErrorState extends SignUpState {
  DriverCreateErrorState({required this.message});
  final String message;
  @override
  List<Object> get props => [];
}

class DriverIsActivateState extends SignUpState {}

class DriverIsNotActivateState extends SignUpState {}

class DriverIsEditableState extends SignUpState {}

class SignUpLoadingState extends SignUpState {}

class LoadingIndicatorState extends SignUpState {
  LoadingIndicatorState({required this.percent});

  final _id = const Uuid().v4();
  final double percent;
  @override
  List<Object> get props => [percent, _id];
}
