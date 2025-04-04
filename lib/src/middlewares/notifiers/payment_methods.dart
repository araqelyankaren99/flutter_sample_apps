import 'package:flutter/material.dart';

class PaymentMethodsNotifier with ChangeNotifier {
  PaymentMethodsNotifier();

  bool get hasPaymentMethods => _hasPaymentMethods;
  bool _hasPaymentMethods = false;

  set hasPaymentMethods(bool hasPaymentMethods) {
    final prevPaymentMethodsStatus = _hasPaymentMethods;
    _hasPaymentMethods = hasPaymentMethods;
    if (prevPaymentMethodsStatus != hasPaymentMethods) {
      notifyListeners();
    }
  }
}
