import 'package:equatable/equatable.dart';
import 'package:flutter_sample_apps/payment_validation_repository.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();
  @override
  List<Object> get props => [];
}

class ChangeCreditCardNumberEvent extends PaymentEvent {
  const ChangeCreditCardNumberEvent({required this.cardNumber});

  final String cardNumber;

  @override
  List<Object> get props => [cardNumber];
}

class DetectCreditCardTypeEvent extends PaymentEvent {
  const DetectCreditCardTypeEvent({required this.cardNumber});

  final String cardNumber;

  @override
  List<Object> get props => [cardNumber];
}

class ChangeCreditCardTypeEvent extends PaymentEvent {
  const ChangeCreditCardTypeEvent({required this.cardType});

  final CardType cardType;

  @override
  List<Object> get props => [cardType];
}

class DetectCreditCardNumberFormatterMaskEvent extends PaymentEvent {
  const DetectCreditCardNumberFormatterMaskEvent({required this.cardType});

  final CardType cardType;

  @override
  List<Object> get props => [cardType];
}

class ChangeCreditCardNumberFormatterMaskEvent extends PaymentEvent {
  const ChangeCreditCardNumberFormatterMaskEvent({required this.mask});

  final String mask;

  @override
  List<Object> get props => [mask];
}

class DetectCreditCardCvvFormatterEvent extends PaymentEvent {
  const DetectCreditCardCvvFormatterEvent({required this.cardType});

  final CardType cardType;

  @override
  List<Object> get props => [cardType];
}

class ChangeCreditCardCvvFormatterMaskEvent extends PaymentEvent {
  const ChangeCreditCardCvvFormatterMaskEvent({required this.mask});

  final String mask;

  @override
  List<Object> get props => [mask];
}

class ChangeCreditCardExpDateEvent extends PaymentEvent {
  const ChangeCreditCardExpDateEvent({required this.expDate});

  final String expDate;

  @override
  List<Object> get props => [expDate];
}

class ChangeCreditCardExpDateValidationEvent extends PaymentEvent {
  const ChangeCreditCardExpDateValidationEvent({required this.validate});

  final bool validate;

  @override
  List<Object> get props => [validate];
}

class ChangeCreditCardFillEvent extends PaymentEvent {
  const ChangeCreditCardFillEvent({required this.fill});

  final bool fill;

  @override
  List<Object> get props => [fill];
}

class ChangeCreditCardCvvEvent extends PaymentEvent {
  const ChangeCreditCardCvvEvent({required this.cvv});

  final String cvv;

  @override
  List<Object> get props => [cvv];
}

class ChangeCreditCardHolderNameEvent extends PaymentEvent {
  const ChangeCreditCardHolderNameEvent({required this.holderName});

  final String holderName;

  @override
  List<Object> get props => [holderName];
}

class ChangeCreditCardBillingAddressEvent extends PaymentEvent {
  const ChangeCreditCardBillingAddressEvent({required this.billingAddress});

  final String billingAddress;

  @override
  List<Object> get props => [billingAddress];
}

class ChangeCreditCardZipCodeEvent extends PaymentEvent {
  const ChangeCreditCardZipCodeEvent({required this.zipCode});

  final String zipCode;

  @override
  List<Object> get props => [zipCode];
}

class ChangeCreditCardUnitAptEvent extends PaymentEvent {
  const ChangeCreditCardUnitAptEvent({required this.unitApt});

  final String unitApt;

  @override
  List<Object> get props => [unitApt];
}

class ChangeCreditCardCityEvent extends PaymentEvent {
  const ChangeCreditCardCityEvent({required this.city});

  final String city;

  @override
  List<Object> get props => [city];
}

class ChangeCreditCardStateEvent extends PaymentEvent {
  const ChangeCreditCardStateEvent({required this.addressState});

  final String addressState;

  @override
  List<Object> get props => [addressState];
}

class PayForServiceEvent extends PaymentEvent {
  const PayForServiceEvent();
}

class CheckPaymentValidationEvent extends PaymentEvent {
  const CheckPaymentValidationEvent();
}

class PayForValidateServiceEvent extends PaymentEvent {
  const PayForValidateServiceEvent();
}