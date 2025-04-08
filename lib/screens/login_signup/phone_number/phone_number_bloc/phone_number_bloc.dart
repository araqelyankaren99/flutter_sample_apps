import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_sample_apps/middlewares/extension/string.dart';
import 'package:flutter_sample_apps/middlewares/repositories/driver_repository.dart';
import 'package:flutter_sample_apps/middlewares/repositories/graph_ql_repository.dart';
import 'package:flutter_sample_apps/middlewares/repositories/validation_repository.dart';
import 'package:flutter_sample_apps/screens/login_signup/phone_number/phone_number_bloc/phone_number_event.dart';
import 'package:flutter_sample_apps/screens/login_signup/phone_number/phone_number_bloc/phone_number_state.dart';

class PhoneNumberBloc extends Bloc<PhoneNumberEvent, PhoneNumberState> {
  PhoneNumberBloc() : super(PhoneNumberInitialState());
  final GraphQlRepository _graphQlRepository = GraphQlRepository();
  final ValidationRepository _validationRepository = ValidationRepository();
  final DriverRepository _driverRepository = DriverRepository();
  String _phoneNumber = '';

  @override
  Stream<PhoneNumberState> mapEventToState(
    PhoneNumberEvent event,
  ) async* {
    if (event is SmsVerifyCodeEvent) {
      yield GetSmsVerifyCodeState(pinCode: event.pinCode);
    }

    if (event is PhoneNumberVerifyEvent) {
      yield* phoneNumberVerifyEventToState(event);
    }

    if (event is PhoneNumberCheckEvent) {
      yield* phoneNumberCheckEventToState(event);
    }

    if (event is PinCodeCheckEvent) {
      yield* pinCodeCheckEventToState(event);
    }
    if (event is NextButtonValidationEvent) {
      yield* nextButtonValidationEventToState(event);
    }
    if (event is ResendCodeEvent) {
      yield* resendCodeEventToState(event);
    }
    if (event is VerifyCodeValidatedEvent) {
      yield* verifyCodeCheckEventToState(event);
    }
  }

  Stream<PhoneNumberState> resendCodeEventToState(
      ResendCodeEvent event,) async* {
    yield GetPhoneNumberLoadingState();
    yield PhoneNumberLoadingState();
    _phoneNumber = event.phoneNumber;
    try {
      await _graphQlRepository.verifyPhone(phoneNumber: _phoneNumber);
      yield ResendCodeSuccessedState();
    } catch (e) {
      yield ResendCodeFailedState();
    }
  }

  Stream<PhoneNumberState> verifyCodeCheckEventToState(
      VerifyCodeValidatedEvent event,) async* {
    final pinCode = event.pinCode;
    yield VerifyCodeValidatedState(pinCode: pinCode);
  }

  Stream<PhoneNumberState> phoneNumberVerifyEventToState(
      PhoneNumberVerifyEvent event,) async* {
    yield PhoneNumberLoadingState();
    _phoneNumber = event.phoneNumber.phoneNumberWithoutScope();

    if (event.changingPhoneNumber) {
      if (event.oldPhoneNumber != null &&
          event.oldPhoneNumber == _phoneNumber) {
        yield PhoneNumberVerifyErrorState(
            errorMessage: 'This is your current phone number',);
        return;
      }
      try {
        final queryResult =
            await _graphQlRepository.checkPhone(phoneNumber: _phoneNumber);

        final data = queryResult.data;

        if (data == null || !(data['checkPhone'] as bool)) {
          yield PhoneNumberVerifyErrorState(
              errorMessage:
                  'Phone number is already taken. Write another phone number',);
          return;
        }
      } catch (e) {
        yield PhoneNumberVerifyErrorState(errorMessage: e.toString());
        return;
      }
    }
    try {
      await _graphQlRepository.verifyPhone(phoneNumber: _phoneNumber);
      if (!event.changingPhoneNumber) {
        await _driverRepository.storePhoneNumber(_phoneNumber);
      }
      yield PhoneVerifySuccessedState();
    } catch (e) {
      yield PhoneNumberVerifyErrorState(errorMessage: e.toString());
    }
  }

  Stream<PhoneNumberState> pinCodeCheckEventToState(
      PinCodeCheckEvent event,) async* {
    yield PhoneNumberLoadingState();
    _phoneNumber = event.phoneNumber;
    final pinCode = event.pinCode;

    //if user is already logged in and is changing his phone number
    if (event.changingPhoneNumber) {
      try {
        final queryResult = await _graphQlRepository.authenticateDriverEdit(
            code: pinCode, phoneNumber: _phoneNumber,);
        final data = queryResult.data;
        if (data != null) {
          final refreshToken = data['authenticateDriverEdit']['refreshToken'];
          _driverRepository
            ..storePhoneNumber(_phoneNumber)
            ..storeToken(refreshToken as String);

          yield PinCodeVerifySuccessedState(token: refreshToken);
          return;
        }
      } catch (e) {
        yield PinCodeNotValidState(errorMessage: e.toString());
      }
    }

    //if user is logging in or signing up
    try {
      final queryResult = await _graphQlRepository.authenticateDriver(
          token: pinCode, phoneNumber: _phoneNumber,);
      final data = queryResult.data;
      if (data != null) {
        final authUser = data['authenticateDriver'];
        if (authUser != null) {
          final token = authUser['authToken'] as String;
          final tokenExpiredTime = authUser['tokenExpiresAfter'] as int;
          final refreshToken = authUser['refreshToken'] as String;
          final refreshTokenExpiredTime =
              authUser['refreshTokenExpiresAfter'] as int;

          await _driverRepository.storeToken(token,
              tokenExpiredTime: tokenExpiredTime,
              refreshToken: refreshToken,
              refreshTokenExpiredTime: refreshTokenExpiredTime,);
          final phoneNumber = await _driverRepository.checkNumber(token);
          if (phoneNumber == null) {
            yield PinCodeVerifySuccessedState(
              token: token,
            );
            return;
          }
          final isActive = await _driverRepository.isActivated(token);
          if (isActive != null) {
            if (!isActive) {
              final driver = await _driverRepository.getDriverInfo();
              if (driver != null) {
                yield PinCodeVerifySuccessedState(
                    token: token, driver: driver,);
                return;
              }
            }
          }
          yield PinCodeVerifySuccessedState(
            token: token,
            phone: phoneNumber,
          );
          return;
        }
      }
    } catch (e) {
      yield PinCodeNotValidState(errorMessage: e.toString());
    }
  }

  Stream<PhoneNumberState> phoneNumberCheckEventToState(
      PhoneNumberCheckEvent event,) async* {
    _phoneNumber = event.phoneNumber.phoneNumberWithoutScope();
    if (_validationRepository.isValidPhoneNumber(_phoneNumber)) {
      yield PhoneNumberValidState();
    } else {
      yield PhoneNumberInvalidState();
    }
  }

  Stream<PhoneNumberState> nextButtonValidationEventToState(
      NextButtonValidationEvent event,) async* {
    final pinCode = event.pinCode;

    if (_validationRepository.isPinCodeValid(pinCode)) {
      yield NextButtonValidatedState();
    } else {
      yield NextButtonNotValidatedState();
    }
  }
}
