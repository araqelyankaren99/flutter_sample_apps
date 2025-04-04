import 'package:flutter_sample_apps/src/middlewares/notifiers/payment_methods.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PaymentMethodBuilder extends StatelessWidget {
  const PaymentMethodBuilder({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Consumer<PaymentMethodsNotifier>(
        builder: (context, notifier, myChild) {
      return child;
    });
  }
}
