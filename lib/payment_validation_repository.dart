import 'package:credit_card_type_detector/constants.dart';
import 'package:credit_card_type_detector/credit_card_type_detector.dart';
import 'package:credit_card_validator/credit_card_validator.dart';
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
    creditCardTypeDetectService: _CreditCardTypeDetectService(),
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

  final _CreditCardTypeDetectService creditCardTypeDetectService;
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


class _CreditCardTypeDetectService {
  const _CreditCardTypeDetectService();

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
