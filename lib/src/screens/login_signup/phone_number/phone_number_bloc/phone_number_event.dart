import 'package:equatable/equatable.dart';

abstract class PhoneNumberEvent extends Equatable {
  const PhoneNumberEvent();
  @override
  List<Object> get props => [];
}

class PhoneNumberVerifyEvent extends PhoneNumberEvent {
  const PhoneNumberVerifyEvent({
    required this.phoneNumber,
    required this.changingPhoneNumber,
    this.oldPhoneNumber,
  });

  final String phoneNumber;
  final bool changingPhoneNumber;
  final String? oldPhoneNumber;

  @override
  List<Object> get props => [phoneNumber, changingPhoneNumber];
}

class PinCodeCheckEvent extends PhoneNumberEvent {
  const PinCodeCheckEvent(
      {required this.pinCode,
      required this.phoneNumber,
      required this.changingPhoneNumber});
  final String pinCode;
  final String phoneNumber;
  final bool changingPhoneNumber;

  @override
  List<Object> get props => [pinCode, phoneNumber, changingPhoneNumber];
}

class PhoneNumberCheckEvent extends PhoneNumberEvent {
  const PhoneNumberCheckEvent({required this.phoneNumber});

  final String phoneNumber;

  @override
  List<Object> get props => [phoneNumber];
}

class VerifyCodeValidatedEvent extends PhoneNumberEvent {
  const VerifyCodeValidatedEvent({required this.pinCode});

  final String pinCode;

  @override
  List<Object> get props => [pinCode];
}

class ResendCodeEvent extends PhoneNumberEvent {
  const ResendCodeEvent({
    required this.phoneNumber,
  });

  final String phoneNumber;

  @override
  List<Object> get props => [phoneNumber];
}

class SmsVerifyCodeEvent extends PhoneNumberEvent {
  const SmsVerifyCodeEvent({required this.pinCode});

  final String pinCode;

  @override
  List<Object> get props => [pinCode];
}
