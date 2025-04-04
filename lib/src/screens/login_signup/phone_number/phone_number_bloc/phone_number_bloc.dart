import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sample_apps/src/middlewares/extensions/string.dart';
import 'package:flutter_sample_apps/src/middlewares/repositories/graph_ql_repository.dart';
import 'package:flutter_sample_apps/src/middlewares/repositories/validation_repository.dart';
import 'package:flutter_sample_apps/src/screens/login_signup/phone_number/phone_number_bloc/phone_number_event.dart';
import 'package:flutter_sample_apps/src/screens/login_signup/phone_number/phone_number_bloc/phone_number_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PhoneNumberBloc extends Bloc<PhoneNumberEvent, PhoneNumberState> {
  PhoneNumberBloc() : super(PhoneNumberInitialState()) {
    on<SmsVerifyCodeEvent>(_smsVerifyCodeEventToState);
    on<PhoneNumberVerifyEvent>(_phoneNumberVerifyEventToState);
    on<ResendCodeEvent>(_resendCodeEventToState);
    on<PhoneNumberCheckEvent>(_phoneNumberCheckEventToState);
    on<PinCodeCheckEvent>(_pinCodeCheckEventToState);
    on<VerifyCodeValidatedEvent>(_verifyCodeCheckEventToState);
  }

  final GraphQlRepository _graphQlRepository = GraphQlRepository();
  final ValidationRepository _validationRepository = ValidationRepository();

  String _phoneNumber = '';
  String get phoneNumber => _phoneNumber;

  Future<void> _smsVerifyCodeEventToState(
      SmsVerifyCodeEvent event, Emitter<PhoneNumberState> emit) async {
    emit(GetSmsVerifyCodeState(pinCode: event.pinCode));
  }

  Future<void> _phoneNumberVerifyEventToState(
      PhoneNumberVerifyEvent event, Emitter<PhoneNumberState> emit) async {
    emit(PhoneNumberLoadingState());
    _phoneNumber = event.phoneNumber.phoneNumberWithoutScope();

    if (event.changingPhoneNumber) {
      if (event.oldPhoneNumber != null &&
          event.oldPhoneNumber == _phoneNumber) {
        emit(PhoneNumberVerifyErrorState(
            errorMessage: 'This is your current phone number'));
        return;
      }
      try {
        final _queryResult =
            await _graphQlRepository.checkPhone(phoneNumber: _phoneNumber);

        if (_queryResult.hasException) {
          emit(PhoneNumberVerifyErrorState(
              errorMessage: 'Something went wrong.'));
          return;
        }
        final data = _queryResult.data;

        if (data == null || !data['checkPhone']) {
          emit(PhoneNumberVerifyErrorState(
              errorMessage:
                  'Phone number is already taken. Write another phone number'));
          return;
        }
      } catch (e) {
        emit(
            PhoneNumberVerifyErrorState(errorMessage: 'Something went wrong.'));
        throw Exception('Something went wrong.');
      }
    }

    try {
      final _queryResult =
          await _graphQlRepository.verifyPhone(phoneNumber: _phoneNumber);

      if (_queryResult.hasException) {
        final _errorMessage =
            '$_phoneNumber number is not valid. Please check again';

        emit(PhoneNumberVerifyErrorState(errorMessage: _errorMessage));
        return;
      }
      if (!event.changingPhoneNumber) {
        await _storePhoneNumber();
      }
      emit(PhoneVerifySuccessedState());
    }on Exception catch (e) {
      emit(PhoneNumberVerifyErrorState(errorMessage: 'Something went wrong.'));
      throw Exception('Something went wrong.');
    }
  }

  Future<void> _resendCodeEventToState(
      ResendCodeEvent event, Emitter<PhoneNumberState> emit) async {
    emit(PhoneNumberLoadingState());
    _phoneNumber = event.phoneNumber;

    try {
      final _queryResult =
          await _graphQlRepository.verifyPhone(phoneNumber: _phoneNumber);

      if (_queryResult.hasException) {
        emit(ResendCodeFailedState());
        return;
      }
      emit(ResendCodeSuccessedState());
    } catch (e) {
      emit(ResendCodeServerFailedState(errorMessage: 'Something went wrong.'));
      throw Exception('Something went wrong.');
    }
  }

  Future<void> _phoneNumberCheckEventToState(
      PhoneNumberCheckEvent event, Emitter<PhoneNumberState> emit) async {
    _phoneNumber = event.phoneNumber.phoneNumberWithoutScope();
    if (_validationRepository.isValidPhoneNumber(_phoneNumber)) {
      emit(PhoneNumberValidState());
    } else {
      emit(PhoneNumberInvalidState());
    }
  }

  Future<void> _pinCodeCheckEventToState(
      PinCodeCheckEvent event, Emitter<PhoneNumberState> emit) async {
    emit(PhoneNumberLoadingState());
    _phoneNumber = event.phoneNumber;
    final _pinCode = event.pinCode;

    /// If user is already logged in and is changing his phone number
    if (event.changingPhoneNumber) {
      try {
        final _queryResult = await _graphQlRepository.authenticateUserEdit(
            code: _pinCode, phoneNumber: _phoneNumber);

        if (_queryResult.hasException) {
          emit(PinCodeNotValidState(errorMessage: 'Something went wrong'));
          return;
        }
        final data = _queryResult.data;

        if (data != null) {
          final _refreshToken = data['authenticateUserEdit']['refreshToken'];
          _storePhoneNumber();
          _storeToken(_refreshToken);

          emit(PinCodeVerifySuccessedState(token: _refreshToken));
          return;
        }
      } catch (e) {
        emit(PinCodeNotValidState(errorMessage: 'Something went wrong'));
        throw Exception('Something went wrong');
      }
    }

    /// If user is logging in or signing up

    try {
      final _queryResult = await _graphQlRepository.authenticateUser(
          token: _pinCode, phoneNumber: _phoneNumber);
      if (_queryResult.hasException) {
        final _error = _queryResult.exception;
        if (_error != null) {
          emit(PinCodeNotValidState(errorMessage: 'Something went wrong'));
          return;
        }
      } else {
        final _data = _queryResult.data;
        if (_data != null) {
          final _authUser = _data['authenticateUser'];
          if (_authUser != null) {
            final _token = _authUser['authToken'] as String;

            final _tokenExpiredTime = _authUser['tokenExpiresAfter'] as int;
            final _refreshToken = _authUser['refreshToken'] as String;
            final _refreshTokenExpiredTime =
                _authUser['refreshTokenExpiresAfter'] as int;

            _storeToken(_token,
                tokenExpiredTime: _tokenExpiredTime,
                refreshToken: _refreshToken,
                refreshTokenExpiredTime: _refreshTokenExpiredTime);

            final phoneNumber = await _checkNumber(_token);
            if (phoneNumber == null) {
              emit(PinCodeVerifySuccessedState(token: _token));
              return;
            }
            if (!phoneNumber.contains('+')) {
              emit(NotAuthenticatedUserState(errorMessage: phoneNumber));
              return;
            }
            emit(
                PinCodeVerifySuccessedState(token: _token, phone: phoneNumber));
            return;
          }
        }
      }
    } catch (e) {
      emit(PinCodeNotValidState(errorMessage: 'Something went wrong'));
      throw Exception('Something went wrong');
    }
  }

  Future<void> _verifyCodeCheckEventToState(
      VerifyCodeValidatedEvent event, Emitter<PhoneNumberState> emit) async {
    final _pinCode = event.pinCode;
    emit(VerifyCodeValidatedState(pinCode: _pinCode));
  }

  /// This function return number phone or error message or null(if number is not used)
  Future<String?> _checkNumber(String token) async {
    final _queryResultForNumber = await _graphQlRepository.getUser(token);
    if (_queryResultForNumber.hasException) {
      final _error = _queryResultForNumber.exception;
      if (_error != null) {
        return _error.graphqlErrors.first.toString();
      }
    }
    final _data = _queryResultForNumber.data;
    if (_data != null) {
      if (_data['thisUser'] == null) {
        return null;
      }
      return _data['thisUser']['phone'] as String;
    }
    return null;
  }

  /// Add token to SharedPreferences
  Future<bool> _storeToken(String token,
      {int? tokenExpiredTime,
      String? refreshToken,
      int? refreshTokenExpiredTime}) async {
    final prefs = await SharedPreferences.getInstance();
    final currentTime = DateTime.now().millisecondsSinceEpoch / 1000;

    if (tokenExpiredTime != null) {
      final _tokenExpiredTime = currentTime.toInt() + tokenExpiredTime;
      prefs.setInt('tokenExpiredTime', _tokenExpiredTime);
    }

    if (refreshToken != null) {
      prefs.setString('refreshToken', refreshToken);
    }

    if (refreshTokenExpiredTime != null) {
      final _refreshTokenExpiredTime =
          currentTime.toInt() + refreshTokenExpiredTime;

      prefs.setInt('refreshTokenExpiredTime', _refreshTokenExpiredTime);
    }
    return prefs.setString('token', token);
  }

  /// Add phone to SharedPreferences
  Future<bool> _storePhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString('phone', _phoneNumber);
  }
}
