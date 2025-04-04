import 'package:equatable/equatable.dart';

abstract class PhoneNumberState extends Equatable {
  @override
  List<Object> get props => [];
}

class PhoneNumberInitialState extends PhoneNumberState {
  PhoneNumberInitialState();

  @override
  List<Object> get props => [];
}

class PhoneVerifySuccessedState extends PhoneNumberState {
  PhoneVerifySuccessedState();

  @override
  List<Object> get props => [];
}

class PhoneNumberVerifyErrorState extends PhoneNumberState {
  PhoneNumberVerifyErrorState({required this.errorMessage});
  final String errorMessage;

  @override
  List<Object> get props => [errorMessage];
}

class PinCodeVerifySuccessedState extends PhoneNumberState {
  PinCodeVerifySuccessedState({required this.token, this.phone});
  final String token;
  final String? phone;

  @override
  List<Object> get props => [token];
}

class PinCodeNotValidState extends PhoneNumberState {
  PinCodeNotValidState({this.errorMessage});
  final String? errorMessage;

  @override
  List<Object> get props => [errorMessage ?? ''];
}

class PhoneNumberLoadingState extends PhoneNumberState {
  PhoneNumberLoadingState();

  @override
  List<Object> get props => [];
}

class NotAuthenticatedUserState extends PhoneNumberState {
  NotAuthenticatedUserState({this.errorMessage});
  final String? errorMessage;

  @override
  List<Object> get props => [errorMessage ?? ''];
}

class PhoneNumberValidState extends PhoneNumberState {
  PhoneNumberValidState();

  @override
  List<Object> get props => [];
}

class PhoneNumberInvalidState extends PhoneNumberState {
  PhoneNumberInvalidState();
  @override
  List<Object> get props => [];
}

class VerifyCodeValidatedState extends PhoneNumberState {
  VerifyCodeValidatedState({required this.pinCode});

  final String pinCode;

  @override
  List<Object> get props => [pinCode];
}

class ResendCodeSuccessedState extends PhoneNumberState {
  ResendCodeSuccessedState();

  @override
  List<Object> get props => [];
}

class ResendCodeFailedState extends PhoneNumberState {
  ResendCodeFailedState();

  @override
  List<Object> get props => [];
}

class ResendCodeServerFailedState extends PhoneNumberState {
  ResendCodeServerFailedState({required this.errorMessage});

  final String errorMessage;
  @override
  List<Object> get props => [errorMessage];
}

class GetSmsVerifyCodeState extends PhoneNumberState {
  GetSmsVerifyCodeState({required this.pinCode});

  final String pinCode;

  @override
  List<Object> get props => [pinCode];
}
