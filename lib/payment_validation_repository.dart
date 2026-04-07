import 'dart:async';

import 'package:credit_card_type_detector/constants.dart';
import 'package:credit_card_type_detector/credit_card_type_detector.dart';
import 'package:credit_card_validator/credit_card_validator.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

enum CardType {
  none,
  otherBrand,
  mastercard,
  visa,
  americanExpress,
  discover,
}

class PaymentValidationRepository {
  final _validationRepository = _CreditCardValidationRepository(
    creditCardTypeDetectService: CreditCardTypeDetectService(),
    creditCardValidator: CreditCardValidator(),
  );


  bool validateCardNumber(String cardNumber, MaskTextInputFormatter formatter) {
    final validateCardNumber = _validationRepository.isValidateCreditCardNumber(cardNumber, formatter);
    return validateCardNumber;
  }

  bool validateCardCvv(String cvv, String cardNumber) {
    final validateCvv = _validationRepository.isValidateCreditCardCvv(cvv: cvv, cardNumber: cardNumber);
    return validateCvv;
  }

  bool validateHolderName(String cardName) => cardName.isNotEmpty;

  bool validateBillingAddress(String address) => address.isNotEmpty;

  bool validateZipCode(String zipCode) => zipCode.length == 5;

  bool validateCity(String city) => city.isNotEmpty;

  bool validateAddressState(String addressState) => addressState.length == 2;
}


class _CreditCardValidationRepository {
  _CreditCardValidationRepository({
    required this.creditCardTypeDetectService,
    required this.creditCardValidator,
  });

  final CreditCardTypeDetectService creditCardTypeDetectService;
  final CreditCardValidator creditCardValidator;

  bool isValidateCreditCardNumber(
      String cardNumber,
      MaskTextInputFormatter formatter,
      ) {
    final cardType =
    creditCardTypeDetectService.detectCreditCardType(cardNumber);
    final isFillCardNumber = formatter.isFill();
    if (!isFillCardNumber) {
      return false;
    }
    final validateCardType =
        cardType != CardType.none && cardType != CardType.otherBrand;
    if (!validateCardType) {
      return false;
    }
    final validateUsingCreditCard =
        creditCardValidator.validateCCNum(cardNumber).isValid;
    return validateUsingCreditCard;
  }

  bool isValidateCreditCardExpDate(String expDate) {
    return creditCardValidator.validateExpDate(expDate).isValid;
  }

  bool isValidateCreditCardCvv({
    required String cvv,
    required String cardNumber,
  }) {
    if (cardNumber.isEmpty) {
      return false;
    }
    final types = detectCCType(cardNumber);
    if (types.isEmpty) {
      return false;
    }
    final cardType = types.first;

    return creditCardValidator.validateCVV(cvv, cardType).isValid;
  }
}


class CreditCardTypeDetectService {
  const CreditCardTypeDetectService();

  CardType detectCreditCardType(String cardInput) {
    if (cardInput.isEmpty) {
      return CardType.none;
    }
    final types = detectCCType(cardInput);
    if (types.isEmpty) {
      return CardType.otherBrand;
    }
    final card = types.first;
    switch (card.type) {
      case TYPE_VISA:
        return CardType.visa;
      case TYPE_MASTERCARD:
        return CardType.mastercard;
      case TYPE_AMEX:
        return CardType.americanExpress;
      case TYPE_DISCOVER:
        return CardType.discover;
      default:
        return CardType.otherBrand;
    }
  }
}

extension CreditCardImageExtension on CardType {
  Widget get cardImage {
    switch (this) {
      case CardType.visa:
        return Text('Visa');
      case CardType.discover:
        return Text('Discover');
      case CardType.americanExpress:
        return Text('Amex');
      case CardType.mastercard:
        return Text('Master');
      case CardType.otherBrand :
        return Text('Other');
      case CardType.none:
        return const SizedBox.shrink();
    }
  }
}

class CreditCardFormatterService {
  const CreditCardFormatterService();
  String creditCardFormatterMask(CardType cardType) =>
      cardType == CardType.americanExpress
          ? '#### #### #### ###'
          : '#### #### #### ####';

  String creditCardCvvFormatter(CardType cardType) =>
      cardType == CardType.americanExpress ? '####' : '###';
}

abstract class _Keys {
  static const cardNumberError = 'cardNumberError';
  static const cardNumberEmptyError = 'cardNumberEmptyError';
  static const cardNumberFullInvalidError = 'cardNumberFullInvalidError';

  static const cardExpDateError = 'cardExpDateError';
  static const cardExpDateEmptyError = 'cardExpDateEmptyError';
  static const cardExpDateFullInvalidError = 'cardExpDateFullInvalidError';

  static const cardCvvError = 'cardCvvError';
  static const cardCvvEmptyError = 'cardCvvEmptyError';
  static const cardCvvFullInvalidError = 'cardCvvFullInvalidError';

  static const cardHolderNameError = 'cardHolderNameError';
  static const cardBillingAddressError = 'cardBillingAddressError';

  static const cardZipCodeError = 'cardZipCodeError';
  static const cardZipCodeEmptyError = 'cardZipCodeEmptyError';

  static const cardCityError = 'cardCityError';

  static const cardStateError = 'cardStateError';
  static const cardStateEmptyError = 'cardStateEmptyError';
}

class PaymentInputsErrorService {
  final Map<String, bool> _inputErrors = {
    _Keys.cardNumberError: false,
    _Keys.cardNumberEmptyError : false,
    _Keys.cardNumberFullInvalidError : false,
    _Keys.cardExpDateError: false,
    _Keys.cardExpDateEmptyError : false,
    _Keys.cardExpDateFullInvalidError : false,
    _Keys.cardCvvError: false,
    _Keys.cardCvvEmptyError : false,
    _Keys.cardCvvFullInvalidError : false,
    _Keys.cardHolderNameError: false,
    _Keys.cardBillingAddressError: false,
    _Keys.cardZipCodeError: false,
    _Keys.cardZipCodeEmptyError : false,
    _Keys.cardCityError: false,
    _Keys.cardStateError: false,
    _Keys.cardStateEmptyError : false,
  };

  bool get hasCardNumberError => _inputErrors[_Keys.cardNumberError] ?? false;

  bool get hasCardNumberEmptyError => _inputErrors[_Keys.cardNumberEmptyError] ?? false;

  bool get hasCardNumberFullInvalidError => _inputErrors[_Keys.cardNumberFullInvalidError] ?? false;

  bool get hasCardExpDateError => _inputErrors[_Keys.cardExpDateError] ?? false;

  bool get hasCardExpDateEmptyError => _inputErrors[_Keys.cardExpDateEmptyError] ?? false;

  bool get hasCardExpDateFullInvalidError => _inputErrors[_Keys.cardExpDateFullInvalidError] ?? false;

  bool get hasCardCvvError => _inputErrors[_Keys.cardCvvError] ?? false;

  bool get hasCardCvvEmptyError => _inputErrors[_Keys.cardCvvEmptyError] ?? false;

  bool get hasCardCvvFullInvalidError => _inputErrors[_Keys.cardCvvFullInvalidError] ?? false;

  bool get hasCardHolderNameError =>
      _inputErrors[_Keys.cardHolderNameError] ?? false;

  bool get hasCardBillingAddressError =>
      _inputErrors[_Keys.cardBillingAddressError] ?? false;

  bool get hasCardStateError => _inputErrors[_Keys.cardStateError] ?? false;

  bool get hasCardStateEmptyError => _inputErrors[_Keys.cardStateEmptyError] ?? false;

  bool get hasCardZipCodeError => _inputErrors[_Keys.cardZipCodeError] ?? false;

  bool get hasCardZipCodeEmptyError => _inputErrors[_Keys.cardZipCodeEmptyError] ?? false;

  bool get hasCardCityError => _inputErrors[_Keys.cardCityError] ?? false;

  void clearCardNumberError() {
    _inputErrors[_Keys.cardNumberError] = false;
  }

  void clearCardNumberEmptyError() {
    _inputErrors[_Keys.cardNumberEmptyError] = false;
  }

  void clearCardNumberFullInvalidError() {
    _inputErrors[_Keys.cardNumberFullInvalidError] = false;
  }

  void clearCardExpDateError() {
    _inputErrors[_Keys.cardExpDateError] = false;
  }

  void clearCardExpDateEmptyError() {
    _inputErrors[_Keys.cardExpDateEmptyError] = false;
  }

  void clearCardExpDateFullInvalidError() {
    _inputErrors[_Keys.cardExpDateFullInvalidError] = false;
  }

  void clearCardCvvError() {
    _inputErrors[_Keys.cardCvvError] = false;
  }

  void clearCardCvvEmptyError() {
    _inputErrors[_Keys.cardCvvEmptyError] = false;
  }

  void clearCardCvvFullInvalidError() {
    _inputErrors[_Keys.cardCvvFullInvalidError] = false;
  }

  void clearCardHolderNameError() {
    _inputErrors[_Keys.cardHolderNameError] = false;
  }

  void clearCardBillingAddressError() {
    _inputErrors[_Keys.cardBillingAddressError] = false;
  }

  void clearCardStateError() {
    _inputErrors[_Keys.cardStateError] = false;
  }

  void clearCardStateEmptyError() {
    _inputErrors[_Keys.cardStateEmptyError] = false;
  }

  void clearCardZipCodeError() {
    _inputErrors[_Keys.cardZipCodeError] = false;
  }

  void clearCardZipCodeEmptyError() {
    _inputErrors[_Keys.cardZipCodeEmptyError] = false;

  }

  void clearCardCityError() {
    _inputErrors[_Keys.cardCityError] = false;
  }

  set hasCardNumberError(bool hasCardNumberError) {
    _inputErrors[_Keys.cardNumberError] = hasCardNumberError;
  }

  set hasCardNumberEmptyError(bool hasCardNumberEmptyError) {
    _inputErrors[_Keys.cardNumberEmptyError] = hasCardNumberEmptyError;
  }

  set hasCardNumberFullInvalidError(bool hasCardNumberFullInvalidError){
    _inputErrors[_Keys.cardNumberFullInvalidError] = hasCardNumberFullInvalidError;
  }

  set hasCardCvvError(bool hasCardCvvError) {
    _inputErrors[_Keys.cardCvvError] = hasCardCvvError;
  }

  set hasCardCvvEmptyError(bool hasCardCvvEmptyError){
    _inputErrors[_Keys.cardCvvEmptyError] = hasCardCvvEmptyError;
  }

  set hasCardCvvFullInvalidError(bool hasCardCvvFullInvalidError){
    _inputErrors[_Keys.cardCvvFullInvalidError] = hasCardCvvFullInvalidError;
  }

  set hasCardExpDateError(bool hasCardExpDateError) {
    _inputErrors[_Keys.cardExpDateError] = hasCardExpDateError;
  }

  set hasCardExpDateEmptyError(bool hasCardExpDateEmptyError){
    _inputErrors[_Keys.cardExpDateEmptyError] = hasCardExpDateEmptyError;
  }

  set hasCardExpDateFullInvalidError(bool hasCardExpDateFullInvalidError){
    _inputErrors[_Keys.cardExpDateFullInvalidError] = hasCardExpDateFullInvalidError;
  }

  set hasCardHolderNameError(bool hasCardHolderNameError) {
    _inputErrors[_Keys.cardHolderNameError] = hasCardHolderNameError;
  }

  set hasCardBillingAddressError(bool hasCardBillingAddressError) {
    _inputErrors[_Keys.cardBillingAddressError] = hasCardBillingAddressError;
  }

  set hasCardZipCodeError(bool hasCardZipCodeError) {
    _inputErrors[_Keys.cardZipCodeError] = hasCardZipCodeError;
  }

  set hasCardZipCodeEmptyError(bool hasCardZipCodeEmptyError) {
    _inputErrors[_Keys.cardZipCodeEmptyError] = hasCardZipCodeEmptyError;
  }

  set hasCardCityError(bool hasCardCityError) {
    _inputErrors[_Keys.cardCityError] = hasCardCityError;
  }

  set hasCardStateError(bool hasCardStateError) {
    _inputErrors[_Keys.cardStateError] = hasCardStateError;
  }

  set hasCardStateEmptyError(bool hasCardStateEmptyError) {
    _inputErrors[_Keys.cardStateEmptyError] = hasCardStateEmptyError;
  }

  bool validate() {
    return !hasCardHolderNameError &&
        !hasCardBillingAddressError &&
        !hasCardStateError &&
        !hasCardStateEmptyError &&
        !hasCardZipCodeError &&
        !hasCardZipCodeEmptyError &&
        !hasCardCityError;
  }
}

class PaymentModel {
  const PaymentModel({
    required this.serviceId,
    required this.params,
    required this.nameOnCard,
    required this.paymentMethodId,
    required this.address,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) =>
      PaymentModel(
        serviceId: json['service_id'] as int,
        params: json['params'] as String,
        nameOnCard: json['name_on_card'] as String,
        paymentMethodId: json['payment_method_id'] as String,
        address: AddressModel.fromJson(json['address'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() =>  <String, dynamic>{
    'service_id': serviceId,
    'params': params,
    'name_on_card': nameOnCard,
    'payment_method_id': paymentMethodId,
    'address':address,
  };

  final int serviceId;
  final String params;
  final String nameOnCard;
  final String paymentMethodId;
  final AddressModel address;

  @override
  String toString() => 'PaymentModel(\n'
      'serviceId : $serviceId\n'
      'nameOnCard : $nameOnCard\n'
      'paymentMethodId : $paymentMethodId\n'
      'address : $address\n'
      ')';
}

class AddressModel {
  const AddressModel({
    required this.address,
    this.apt,
    required this.city,
    required this.state,
    required this.zip,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) =>
      AddressModel(
        address: json['address'] as String,
        apt: json['apt'] as String?,
        city: json['city'] as String,
        state: json['state'] as String,
        zip: json['zip'] as String,
      );

  Map<String, dynamic> toJson() {
    final result = <String,dynamic>{};
    result['address'] = address;
    result['city'] = city;
    result['state'] = state;
    result['zip'] = zip;
    if(apt != null){
      result['apt'] = apt;
    }
    return result;
  }

  final String address;
  final String? apt;
  final String city;
  final String state;
  final String zip;

  AddressModel copyWith({
    String? address,
    String? apt,
    String? city,
    String? state,
    String? zip,
  }) {
    return AddressModel(
      address: address ?? this.address,
      apt: apt ?? this.apt,
      city: city ?? this.city,
      state: state ?? this.state,
      zip: zip ?? this.zip,
    );
  }

  @override
  String toString() => 'AddressModel('
      'address : $address\n'
      'apt : $apt\n'
      'city : $city\n'
      'state : $state\n'
      'zip : $zip\n'
      ')';
}

class AuthorizationRequest {
  const AuthorizationRequest({required this.authorization});

  factory AuthorizationRequest.fromJson(Map<String, String> json) =>
      AuthorizationRequest(
        authorization: json['authorization'] ?? '',
      );

  Map<String, String> toJson() => <String, String>{
    'authorization': authorization,
  };

  final String authorization;

  @override
  String toString() => 'AuthorizationRequest(authorization : $authorization)';
}

abstract class PaymentApiClient {
  const PaymentApiClient();

  FutureOr<void> makeSelfPatient({
    required PaymentModel paymentModel,
    required AuthorizationRequest authorizationRequest,
  });
}

class PaymentApiClientImpl extends PaymentApiClient {
  @override
  Future<void> makeSelfPatient({
    required PaymentModel paymentModel,
    required AuthorizationRequest authorizationRequest,
  }) async {
    try {
      final baseUrl = 'baseUrl';
      final url = '$baseUrl/patient/make-self-payment';
      final json = paymentModel.toJson();

      await Dio().post(
        url,
        data: json,
        options: Options(headers: {
          'authorization': authorizationRequest.authorization,
        },
        ),
      );
    } on Exception catch (error, stackTrace) {
      throw Error.throwWithStackTrace(error, stackTrace);
    }
  }
}


class ApiClientException implements Exception {
  const ApiClientException();
}

class ApiClientTimeoutException extends ApiClientException {
  const ApiClientTimeoutException({required this.request,});

  final Object request;

  @override
  String toString() => 'ApiClientTimeoutException(request : $request)';
}

class ApiClientUnauthorizedException extends ApiClientException {
  const ApiClientUnauthorizedException({
    required this.request,
    required this.response,
  });

  final Object request;
  final dynamic response;

  @override
  String toString() => 'ApiClientUnauthorizedException('
      'request : $request \n'
      'response : $response)';
}

class ApiClientPathNotFountException extends ApiClientException {
  const ApiClientPathNotFountException({required this.request});

  final Object request;

  @override
  String toString() => 'ApiClientPathNotFountException(request : $request)';
}

class ApiClientBadRequestException extends ApiClientException {
  const ApiClientBadRequestException({
    required this.body,
    required this.request,
    required this.errorMessage,
  });

  final Map<String,dynamic> body;
  final Object request;
  final String errorMessage;

  @override
  String toString() => 'ApiClientBadRequestException('
      'request : $request\n'
      'body : $body)';
}

class ApiClientNetworkException extends ApiClientException {
  const ApiClientNetworkException({required this.request});

  final Object request;

  @override
  String toString() => 'ApiClientNetworkException(request : $request\n)';
}
