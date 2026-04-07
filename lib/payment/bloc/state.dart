import 'package:equatable/equatable.dart';
import 'package:flutter_sample_apps/payment_validation_repository.dart';
import 'package:uuid/uuid.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object> get props => [];
}

class PaymentInitial extends PaymentState {
  const PaymentInitial();
}

class CreditCardNumberChangedState extends PaymentState {
  const CreditCardNumberChangedState({required this.cardNumber});

  final String cardNumber;

  @override
  List<Object> get props => [cardNumber];
}

class CreditCardTypeChangedState extends PaymentState {
  const CreditCardTypeChangedState({required this.cardType});

  final CardType cardType;

  @override
  List<Object> get props => [cardType];
}

class CreditCardFormatterMaskChangedState extends PaymentState {
  const CreditCardFormatterMaskChangedState({required this.cardFormatterMask});

  final String cardFormatterMask;

  @override
  List<Object> get props => [cardFormatterMask];
}

class CreditCardCvvFormatterMaskChangedState extends PaymentState {
  const CreditCardCvvFormatterMaskChangedState({
    required this.cvvFormatterMask,
  });

  final String cvvFormatterMask;

  @override
  List<Object> get props => [cvvFormatterMask];
}

class CreditCardExpDateChangedState extends PaymentState {
  const CreditCardExpDateChangedState({required this.expDate});

  final String expDate;

  @override
  List<Object> get props => [expDate];
}

class CreditCardExpDateValidationChangedState extends PaymentState {
  const CreditCardExpDateValidationChangedState({required this.validate});

  final bool validate;

  @override
  List<Object> get props => [validate];
}

class CreditCardExpDateFillChangedState extends PaymentState {
  const CreditCardExpDateFillChangedState({required this.isFill});

  final bool isFill;

  @override
  List<Object> get props => [isFill];
}

class CreditCardCvvChangedState extends PaymentState {
  const CreditCardCvvChangedState({required this.cvv});

  final String cvv;

  @override
  List<Object> get props => [cvv];
}

class CreditCardHolderNameChangedState extends PaymentState {
  const CreditCardHolderNameChangedState({required this.holderName});

  final String holderName;

  @override
  List<Object> get props => [holderName];
}

class CreditCardBillingAddressChangedState extends PaymentState {
  const CreditCardBillingAddressChangedState({required this.billingAddress});

  final String billingAddress;

  @override
  List<Object> get props => [billingAddress];
}

class CreditCardZipCodeChangedState extends PaymentState {
  const CreditCardZipCodeChangedState({required this.zipCode});

  final String zipCode;

  @override
  List<Object> get props => [zipCode];
}

class CreditCardUnitAptChangedState extends PaymentState {
  const CreditCardUnitAptChangedState({required this.unitApt});

  final String unitApt;

  @override
  List<Object> get props => [unitApt];
}

class CreditCardCityChangedState extends PaymentState {
  const CreditCardCityChangedState({required this.city});

  final String city;

  @override
  List<Object> get props => [city];
}

class CreditCardAddressStateChangedState extends PaymentState {
  const CreditCardAddressStateChangedState({required this.addressState});

  final String addressState;

  @override
  List<Object> get props => [addressState];
}

class PaymentValidationCheckedState extends PaymentState {
  final _id = const Uuid().v4();

  @override
  List<Object> get props => [_id];
}

class PaymentLoadingState extends PaymentState {
  const PaymentLoadingState();
}

class PaymentFailedState extends PaymentState {
  const PaymentFailedState({required this.errorMessage, this.statusCode});

  final String errorMessage;
  final int? statusCode;
}

class PaymentSuccessState extends PaymentState {
  const PaymentSuccessState({required this.stepInfo});

  final Map<String, Object?>? stepInfo;

  @override
  List<Object> get props => [stepInfo ?? {}];
}

class PaymentFinishedState extends PaymentState {
  const PaymentFinishedState();
}
