import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sample_apps/payment/bloc/event.dart';
import 'package:flutter_sample_apps/payment/bloc/state.dart';
import 'package:flutter_sample_apps/payment/my_stripe_service.dart';
import 'package:flutter_sample_apps/payment_validation_repository.dart';
import 'package:flutter_sample_apps/stripe_service.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  PaymentBloc({
    required this.paymentValidationRepository,
    required this.paymentInputsErrorService,
    required this.paymentApiClient,
    required this.creditCardTypeDetectService,
    required this.creditCardFormatterService,
    required this.stripeService,
  }) : super(const PaymentInitial()) {
    on<ChangeCreditCardNumberEvent>(_onChangeCreditCardNumberEventToState);
    on<DetectCreditCardTypeEvent>(_onDetectCreditCardTypeEventToState);
    on<ChangeCreditCardTypeEvent>(_onChangeCreditCardTypeEventToState);
    on<DetectCreditCardNumberFormatterMaskEvent>(
      _onDetectCreditCardNumberFormatterMaskEventToState,
    );
    on<ChangeCreditCardNumberFormatterMaskEvent>(
      _onChangeCreditCardNumberFormatterMaskEventToState,
    );
    on<DetectCreditCardCvvFormatterEvent>(
      _onDetectCreditCardCvvFormatterEventToState,
    );
    on<ChangeCreditCardCvvFormatterMaskEvent>(
      _onChangeCreditCardCvvFormatterMaskEventToState,
    );
    on<ChangeCreditCardExpDateEvent>(_onChangeCreditCardExpDateEventToState);
    on<ChangeCreditCardExpDateValidationEvent>(
      _onChangeCreditCardExpDateValidationEventToState,
    );
    on<ChangeCreditCardFillEvent>(_onChangeCreditCardFillEventToState);
    on<ChangeCreditCardCvvEvent>(_onChangeCreditCardCvvEventToState);
    on<ChangeCreditCardHolderNameEvent>(
      _onChangeCreditCardHolderNameEventToState,
    );
    on<ChangeCreditCardBillingAddressEvent>(
      _onChangeCreditCardBillingAddressEventToState,
    );
    on<ChangeCreditCardUnitAptEvent>(_onChangeCreditCardUnitAptEventToState);
    on<ChangeCreditCardZipCodeEvent>(_onChangeCreditCardZipCodeEventToState);
    on<ChangeCreditCardCityEvent>(_onChangeCreditCardCityEventToState);
    on<ChangeCreditCardStateEvent>(_onChangeCreditCardStateEventToState);
    on<PayForServiceEvent>(_onPayForServiceEventToState);
    on<CheckPaymentValidationEvent>(_onCheckPaymentValidationEventToState);
    on<PayForValidateServiceEvent>(_onPayForValidateServiceEventToState);
  }

  late final int? serviceId;
  final CreditCardFormatterService creditCardFormatterService;
  final CreditCardTypeDetectService creditCardTypeDetectService;
  final PaymentValidationRepository paymentValidationRepository;
  final PaymentInputsErrorService paymentInputsErrorService;
  final MyStripeService stripeService;
  final PaymentApiClient paymentApiClient;

  bool get hasCardNumberError => paymentInputsErrorService.hasCardNumberError;

  bool get hasCardNumberEmptyError =>
      paymentInputsErrorService.hasCardNumberEmptyError;

  bool get hasCardNumberFullInvalidError =>
      paymentInputsErrorService.hasCardNumberFullInvalidError;

  bool get hasCreditCardExpDateError =>
      paymentInputsErrorService.hasCardExpDateError;

  bool get hasCreditCardExpDateEmptyError =>
      paymentInputsErrorService.hasCardExpDateEmptyError;

  bool get hasCreditCardExpDateFullInvalidError =>
      paymentInputsErrorService.hasCardExpDateFullInvalidError;

  bool get hasCreditCardCvvError => paymentInputsErrorService.hasCardCvvError;

  bool get hasCreditCardCvvEmptyError =>
      paymentInputsErrorService.hasCardCvvEmptyError;

  bool get hasCardCvvFullInvalidError =>
      paymentInputsErrorService.hasCardCvvFullInvalidError;

  bool get hasCreditCardHolderNameError =>
      paymentInputsErrorService.hasCardHolderNameError;

  bool get hasCreditCardBillingAddressError =>
      paymentInputsErrorService.hasCardBillingAddressError;

  bool get hasCreditCardZipCodeError =>
      paymentInputsErrorService.hasCardZipCodeError;

  bool get hasCreditCardZipCodeEmptyError =>
      paymentInputsErrorService.hasCardZipCodeEmptyError;

  bool get hasCreditCardCityError => paymentInputsErrorService.hasCardCityError;

  bool get hasCreditCardStateError =>
      paymentInputsErrorService.hasCardStateError;

  bool get hasCardStateEmptyError =>
      paymentInputsErrorService.hasCardStateEmptyError;

  CardType get cardType => _cardType;
  CardType _cardType = CardType.none;

  bool _isFillExpDate = false;
  bool _isValidExpDate = false;

  final _cardNumberFormatter = MaskTextInputFormatter();

  MaskTextInputFormatter get cardNumberFormatter => _cardNumberFormatter;

  MaskTextInputFormatter get cvvFormatter => _cvvFormatter;
  final _cvvFormatter = MaskTextInputFormatter();

  String _cardFormatterMask = '';
  String _cvvFormatterMask = '';

  String _cardNumber = '';
  String _nameOnCard = '';

  String _address = '';
  String _unitApt = '';
  String _city = '';
  String _addressState = '';
  String _zip = '';


  Future<void> _onChangeCreditCardNumberEventToState(
    ChangeCreditCardNumberEvent event,
    Emitter<PaymentState> emit,
  ) async {
    final cardNumber = event.cardNumber;
    paymentInputsErrorService
      ..clearCardNumberError()
      ..clearCardNumberEmptyError()
      ..clearCardNumberFullInvalidError();
    _cardNumber = _cardNumberFormatter.unmaskText(cardNumber);
    add(DetectCreditCardTypeEvent(cardNumber: cardNumber));
    emit(CreditCardNumberChangedState(cardNumber: cardNumber));
    await Future.delayed(Duration.zero);
    if (_cardNumberFormatter.isFill()){
      final validateCardNumber = paymentValidationRepository.validateCardNumber(
        _cardNumber,
        _cardNumberFormatter,
      );
      paymentInputsErrorService.hasCardNumberFullInvalidError =
      !validateCardNumber;
    }
  }

  Future<void> _onDetectCreditCardTypeEventToState(
    DetectCreditCardTypeEvent event,
    Emitter<PaymentState> emit,
  ) async {
    final cardType =
        creditCardTypeDetectService.detectCreditCardType(event.cardNumber);
    add(ChangeCreditCardTypeEvent(cardType: cardType));
  }

  Future<void> _onChangeCreditCardTypeEventToState(
    ChangeCreditCardTypeEvent event,
    Emitter<PaymentState> emit,
  ) async {
    final cardType = event.cardType;
    if (cardType == _cardType) {
      return;
    }
    _cardType = cardType;
    add(DetectCreditCardNumberFormatterMaskEvent(cardType: cardType));
    add(DetectCreditCardCvvFormatterEvent(cardType: cardType));
    emit(CreditCardTypeChangedState(cardType: cardType));
  }

  Future<void> _onDetectCreditCardNumberFormatterMaskEventToState(
    DetectCreditCardNumberFormatterMaskEvent event,
    Emitter<PaymentState> emit,
  ) async {
    final cardFormatterMask =
        creditCardFormatterService.creditCardFormatterMask(event.cardType);
    add(ChangeCreditCardNumberFormatterMaskEvent(mask: cardFormatterMask));
  }

  Future<void> _onChangeCreditCardNumberFormatterMaskEventToState(
    ChangeCreditCardNumberFormatterMaskEvent event,
    Emitter<PaymentState> emit,
  ) async {
    final cardFormatterMask = event.mask;
    if (cardFormatterMask == _cardFormatterMask) {
      return;
    }
    _cardFormatterMask = cardFormatterMask;
    _updateCardNumberFormatterMask(cardFormatterMask);
    emit(
      CreditCardFormatterMaskChangedState(
        cardFormatterMask: cardFormatterMask,
      ),
    );
  }

  Future<void> _onDetectCreditCardCvvFormatterEventToState(
    DetectCreditCardCvvFormatterEvent event,
    Emitter<PaymentState> emit,
  ) async {
    final cvvFormatterMask =
        creditCardFormatterService.creditCardCvvFormatter(event.cardType);
    add(ChangeCreditCardCvvFormatterMaskEvent(mask: cvvFormatterMask));
  }

  Future<void> _onChangeCreditCardCvvFormatterMaskEventToState(
    ChangeCreditCardCvvFormatterMaskEvent event,
    Emitter<PaymentState> emit,
  ) async {
    final cvvFormatterMask = event.mask;

    if (cvvFormatterMask == _cvvFormatterMask) {
      return;
    }
    _cvvFormatterMask = cvvFormatterMask;
    _updateCardCvvFormatter(cvvFormatterMask);
    emit(
      CreditCardCvvFormatterMaskChangedState(
        cvvFormatterMask: cvvFormatterMask,
      ),
    );
  }

  Future<void> _onChangeCreditCardExpDateEventToState(
    ChangeCreditCardExpDateEvent event,
    Emitter<PaymentState> emit,
  ) async {
    final expDate = event.expDate;
    paymentInputsErrorService..clearCardExpDateError()..clearCardExpDateEmptyError()..clearCardExpDateFullInvalidError();
    emit(CreditCardExpDateChangedState(expDate: expDate));
    await Future.delayed(Duration.zero);
    if (_isValidExpDate) {
    }
  }

  Future<void> _onChangeCreditCardExpDateValidationEventToState(
    ChangeCreditCardExpDateValidationEvent event,
    Emitter<PaymentState> emit,
  ) async {
    final validate = event.validate;
    _isValidExpDate = validate;
    if (!validate && _isFillExpDate) {
      paymentInputsErrorService.hasCardExpDateFullInvalidError = true;
    }
    emit(CreditCardExpDateValidationChangedState(validate: validate));
  }

  Future<void> _onChangeCreditCardFillEventToState(
    ChangeCreditCardFillEvent event,
    Emitter<PaymentState> emit,
  ) async {
    final isFill = event.fill;
    if (_isFillExpDate == isFill) {
      return;
    }
    _isFillExpDate = isFill;
    emit(CreditCardExpDateFillChangedState(isFill: isFill));
  }

  Future<void> _onChangeCreditCardCvvEventToState(
    ChangeCreditCardCvvEvent event,
    Emitter<PaymentState> emit,
  ) async {
    final cvv = event.cvv;
    paymentInputsErrorService
      ..clearCardCvvError()
      ..clearCardCvvEmptyError()
      ..clearCardCvvFullInvalidError();
    emit(CreditCardCvvChangedState(cvv: cvv));
  }

  Future<void> _onChangeCreditCardHolderNameEventToState(
    ChangeCreditCardHolderNameEvent event,
    Emitter<PaymentState> emit,
  ) async {
    final holderName = event.holderName;
    paymentInputsErrorService.clearCardHolderNameError();
    _nameOnCard = holderName;
    emit(CreditCardHolderNameChangedState(holderName: holderName));
  }

  Future<void> _onChangeCreditCardBillingAddressEventToState(
    ChangeCreditCardBillingAddressEvent event,
    Emitter<PaymentState> emit,
  ) async {
    final billingAddress = event.billingAddress;
    paymentInputsErrorService.clearCardBillingAddressError();
    _address = billingAddress;
    emit(CreditCardBillingAddressChangedState(billingAddress: billingAddress));
  }

  Future<void> _onChangeCreditCardUnitAptEventToState(
    ChangeCreditCardUnitAptEvent event,
    Emitter<PaymentState> emit,
  ) async {
    final unitApt = event.unitApt;
    _unitApt = unitApt;
    emit(CreditCardUnitAptChangedState(unitApt: unitApt));
  }

  Future<void> _onChangeCreditCardZipCodeEventToState(
    ChangeCreditCardZipCodeEvent event,
    Emitter<PaymentState> emit,
  ) async {
    final zipCode = event.zipCode;
    _zip = zipCode;
    paymentInputsErrorService
      ..clearCardZipCodeError()
      ..clearCardZipCodeEmptyError();
    emit(CreditCardZipCodeChangedState(zipCode: zipCode));
  }

  Future<void> _onChangeCreditCardCityEventToState(
    ChangeCreditCardCityEvent event,
    Emitter<PaymentState> emit,
  ) async {
    final city = event.city;
    _city = city;
    paymentInputsErrorService.clearCardCityError();
    emit(CreditCardCityChangedState(city: city));
  }

  Future<void> _onChangeCreditCardStateEventToState(
    ChangeCreditCardStateEvent event,
    Emitter<PaymentState> emit,
  ) async {
    final addressState = event.addressState;
    _addressState = addressState;
    paymentInputsErrorService
      ..clearCardStateError()
      ..clearCardStateEmptyError();
    emit(CreditCardAddressStateChangedState(addressState: addressState));
  }

  Future<void> _onPayForServiceEventToState(
    PayForServiceEvent event,
    Emitter<PaymentState> emit,
  ) async {
    add((const CheckPaymentValidationEvent()));
    await stream.firstWhere(
      (state) => state is PaymentValidationCheckedState,
    );
    final validate = paymentInputsErrorService.validate();
    if (!validate) {
      return;
    }
    add(const PayForValidateServiceEvent());
  }

  Future<void> _onCheckPaymentValidationEventToState(
    CheckPaymentValidationEvent event,
    Emitter<PaymentState> emit,
  ) async {
    // Card validation is handled by Stripe CardField / createPaymentMethod
    final cardHolderName = _nameOnCard;
    final validateHolderName =
        paymentValidationRepository.validateHolderName(cardHolderName);
    paymentInputsErrorService.hasCardHolderNameError = !validateHolderName;

    final billingAddress = _address;
    final validateBillingAddress =
        paymentValidationRepository.validateBillingAddress(billingAddress);
    paymentInputsErrorService.hasCardBillingAddressError =
        !validateBillingAddress;

    if (_zip.isEmpty) {
      paymentInputsErrorService.hasCardZipCodeEmptyError = true;
    } else {
      final validateZipCode = paymentValidationRepository.validateZipCode(_zip);
      paymentInputsErrorService.hasCardZipCodeError = !validateZipCode;
    }

    final validateCity = paymentValidationRepository.validateCity(_city);
    paymentInputsErrorService.hasCardCityError = !validateCity;

    if (_addressState.isEmpty) {
      paymentInputsErrorService.hasCardStateEmptyError = true;
    } else {
      final validateAddressState =
          paymentValidationRepository.validateAddressState(_addressState);
      paymentInputsErrorService.hasCardStateError = !validateAddressState;
    }

    emit(PaymentValidationCheckedState());
  }

  Future<void> _onPayForValidateServiceEventToState(
    PayForValidateServiceEvent event,
    Emitter<PaymentState> emit,
  ) async {
    try {
      emit(const PaymentLoadingState());

      final paymentMethodId = await stripeService.createPaymentMethod(
        name: _nameOnCard,
        addressLine1: _address,
        addressLine2: _unitApt.isNotEmpty ? _unitApt : null,
        addressCity: _city,
        addressState: _addressState,
        addressPostalCode: _zip,
        countryCode: 'US',
      );

      if (paymentMethodId.isEmpty) {
        emit(const PaymentFailedState(errorMessage: 'Please complete your card details correctly.'));
        return;
      }

      final paymentModel = PaymentModel(
        serviceId: serviceId ?? -1,
        params: 'params',
        nameOnCard: _nameOnCard,
        paymentMethodId: paymentMethodId,
        address: AddressModel(
          address: _address,
          zip: _zip,
          apt: _unitApt,
          city: _city,
          state: _addressState,
        ),
      );
      final token = 'token';
      final authorizationRequest = AuthorizationRequest(authorization: token);
      await paymentApiClient.makeSelfPatient(
        paymentModel: paymentModel,
        authorizationRequest: authorizationRequest,
      );
      emit(PaymentSuccessState(stepInfo: null));
    }finally {
      emit(const PaymentFinishedState());
    }
  }

  void _updateCardNumberFormatterMask(String mask) {
    _cardNumberFormatter.updateMask(mask: mask);
  }

  void _updateCardCvvFormatter(String mask) {
    _cvvFormatter.updateMask(mask: mask);
  }
}
