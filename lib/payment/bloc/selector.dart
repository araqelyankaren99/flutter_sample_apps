import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sample_apps/payment/bloc/bloc.dart';
import 'package:flutter_sample_apps/payment_validation_repository.dart';

abstract class PaymentSelector {
  PaymentSelector._();

  static Widget cardNumberImageSelector(BuildContext context) {
    final image = context
        .select((PaymentBloc paymentBloc) => paymentBloc.cardType.cardImage);
    return image;
  }

  static bool hasCardNumberErrorSelector(BuildContext context){
    final hasCardNumberError = context
        .select((PaymentBloc paymentBloc) => paymentBloc.hasCardNumberError);
    return hasCardNumberError;
  }

  static bool hasCardNumberEmptyErrorSelector(BuildContext context){
    final hasCardNumberEmptyError = context
        .select((PaymentBloc paymentBloc) => paymentBloc.hasCardNumberEmptyError);
    return hasCardNumberEmptyError;
  }

  static bool hasCardNumberFullInvalidErrorSelector(BuildContext context){
    final hasCardNumberFullInvalidError = context
        .select((PaymentBloc paymentBloc) => paymentBloc.hasCardNumberFullInvalidError);
    return hasCardNumberFullInvalidError;
  }

  static bool hasCreditCardExpDateErrorSelector(BuildContext context){
    final hasCreditCardExpDateError = context
        .select((PaymentBloc paymentBloc) => paymentBloc.hasCreditCardExpDateError);
    return hasCreditCardExpDateError;
  }

  static bool hasCreditCardExpDateEmptyErrorSelector(BuildContext context){
    final hasCreditCardExpDateEmptyError = context
        .select((PaymentBloc paymentBloc) => paymentBloc.hasCreditCardExpDateEmptyError);
    return hasCreditCardExpDateEmptyError;
  }

  static bool hasCreditCardExpDateFullInvalidErrorSelector(BuildContext context){
    final hasCreditCardExpDateFullInvalidError = context
        .select((PaymentBloc paymentBloc) => paymentBloc.hasCreditCardExpDateFullInvalidError);
    return hasCreditCardExpDateFullInvalidError;
  }

  static bool hasCreditCardCvvErrorSelector(BuildContext context){
    final hasCreditCardCvvError = context
        .select((PaymentBloc paymentBloc) => paymentBloc.hasCreditCardCvvError);
    return hasCreditCardCvvError;
  }

  static bool hasCreditCardCvvEmptyErrorSelector(BuildContext context){
    final hasCreditCardCvvEmptyError = context
        .select((PaymentBloc paymentBloc) => paymentBloc.hasCreditCardCvvEmptyError);
    return hasCreditCardCvvEmptyError;
  }

  static bool hasCreditCardCvvFullInvalidErrorSelector(BuildContext context){
    final hasCardCvvFullInvalidError = context
        .select((PaymentBloc paymentBloc) => paymentBloc.hasCardCvvFullInvalidError);
    return hasCardCvvFullInvalidError;
  }

  static bool hasCreditCardHolderNameErrorSelector(BuildContext context){
    final hasCreditCardHolderNameError = context
        .select((PaymentBloc paymentBloc) => paymentBloc.hasCreditCardHolderNameError);
    return hasCreditCardHolderNameError;
  }

  static bool hasCreditCardBillingAddressErrorSelector(BuildContext context){
    final hasCreditCardBillingAddressError = context
        .select((PaymentBloc paymentBloc) => paymentBloc.hasCreditCardBillingAddressError);
    return hasCreditCardBillingAddressError;
  }

  static bool hasCreditCardZipCodeErrorSelector(BuildContext context){
    final hasCreditCardZipCodeError = context
        .select((PaymentBloc paymentBloc) => paymentBloc.hasCreditCardZipCodeError);
    return hasCreditCardZipCodeError;
  }

  static bool hasCreditCardZipCodeEmptyErrorSelector(BuildContext context){
    final hasCreditCardZipCodeEmptyError = context
        .select((PaymentBloc paymentBloc) => paymentBloc.hasCreditCardZipCodeEmptyError);
    return hasCreditCardZipCodeEmptyError;
  }

  static bool hasCreditCardCityErrorSelector(BuildContext context){
    final hasCreditCardCityError = context
        .select((PaymentBloc paymentBloc) => paymentBloc.hasCreditCardCityError);
    return hasCreditCardCityError;
  }

  static bool hasCreditCardStateErrorSelector(BuildContext context){
    final hasCreditCardStateError = context
        .select((PaymentBloc paymentBloc) => paymentBloc.hasCreditCardStateError);
    return hasCreditCardStateError;
  }

  static bool hasCardStateEmptyErrorSelector(BuildContext context){
    final hasCardStateEmptyError = context
        .select((PaymentBloc paymentBloc) => paymentBloc.hasCardStateEmptyError);
    return hasCardStateEmptyError;
  }
}
