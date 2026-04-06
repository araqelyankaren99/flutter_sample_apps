import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

const String _stripeSecretKeyFromEnv = String.fromEnvironment(
  'STRIPE_SECRET_KEY',
  defaultValue: '',
);

class StripeService {
  const StripeService._();

  static final instance = StripeService._();

  Future<void> makePayment() async {
    try {
      String? paymentIntentClientSecret = await _createPaymentIntent(amount: 10, currency: 'usd');
      if(paymentIntentClientSecret == null) {
        return;
      }
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentClientSecret,
          merchantDisplayName: 'Karen Araqelyan',
        ),
      );
      await _presentPaymentSheet();
    } catch (e) {
      print(e);
    }
  }

  ///Do this for backend side
  Future<String?> _createPaymentIntent({
    required int amount,
    required String currency,
  }) async {
    if (_stripeSecretKeyFromEnv.isEmpty) {
      debugPrint(
        'Stripe: STRIPE_SECRET_KEY is not set. Use --dart-define=STRIPE_SECRET_KEY=sk_test_... '
        'or move PaymentIntent creation to a backend.',
      );
      return null;
    }
    try {
      final dio = Dio();
      final Map<String, dynamic> data = {
        "amount": _calculateAmount(amount),
        "currency": currency,
      };
      final response = await dio.post(
        'https://api.stripe.com/v1/payment_intents',
        data: data,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {
            'Authorization': 'Bearer $_stripeSecretKeyFromEnv',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
      );

      if (response.data != null) {
        return response.data['client_secret'];
      }
      return null;
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<void> _presentPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      await Stripe.instance.confirmPaymentSheetPayment();
    } catch (e) {
      print(e);
    }
  }

  String _calculateAmount(int amount) {
    final calculatedAmount = amount * 100;
    return calculatedAmount.toString();
  }
}
