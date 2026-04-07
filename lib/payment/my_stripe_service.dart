import 'package:flutter_stripe/flutter_stripe.dart';

/// Service to create Stripe PaymentMethods from the CardField.
/// Card data never touches the app - Stripe tokenizes it and returns an id.
abstract class MyStripeService {
  /// Creates a PaymentMethod from the CardField input.
  /// Call when CardField is mounted and user has entered card details.
  /// Returns the PaymentMethod id (pm_xxx) or null on failure.
  Future<String> createPaymentMethod({
    String? name,
    String? addressLine1,
    String? addressLine2,
    String? addressCity,
    String? addressState,
    String? addressPostalCode,
    String? countryCode,
  });
}

class StripeServiceImpl implements MyStripeService {
  @override
  Future<String> createPaymentMethod({
    String? name,
    String? addressLine1,
    String? addressLine2,
    String? addressCity,
    String? addressState,
    String? addressPostalCode,
    String? countryCode,
  }) async {
    try {
      final billingDetails = BillingDetails(
        name: name,
        address: Address(
          line1: addressLine1,
          line2: addressLine2,
          city: addressCity,
          state: addressState,
          postalCode: addressPostalCode,
          country: countryCode,
        ),
      );

      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: billingDetails,
          ),
        ),
      );

      return paymentMethod.id;
    } on StripeException catch (error,stackTrace) {
      return Error.throwWithStackTrace(error, stackTrace);
    }
  }
}
