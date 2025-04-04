import 'package:flutter_sample_apps/src/constants.dart' as constants;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sample_apps/src/middlewares/notifiers/payment_methods.dart';
import 'package:flutter_sample_apps/src/screens/profile/payment/payment_methods_bloc.dart';
import 'package:flutter_sample_apps/src/screens/profile/payment/payment_methods_event.dart';
import 'package:flutter_sample_apps/src/screens/profile/payment/payment_methods_state.dart';
import 'package:flutter_sample_apps/src/screens/profile/payment/stripe_preferences.dart';
import 'package:flutter_sample_apps/src/shared/alert_widget.dart';
import 'package:flutter_sample_apps/src/shared/app_bar_widget.dart';
import 'package:flutter_sample_apps/src/shared/next_button.dart';
import 'package:flutter_sample_apps/src/style.dart';
import 'package:provider/provider.dart';
import 'package:stripe_sdk/stripe_sdk.dart';

class PaymentMethodsAddingScreen extends StatefulWidget {
  const PaymentMethodsAddingScreen(
      {Key? key, this.type = AddPaymentMethodType.initial})
      : super(key: key);

  final AddPaymentMethodType type;

  @override
  State<PaymentMethodsAddingScreen> createState() =>
      _PaymentMethodsAddingScreenState();
}

class _PaymentMethodsAddingScreenState
    extends State<PaymentMethodsAddingScreen> {
  late PaymentMethodsBloc _paymentMethodsBloc;
  final GlobalKey<FormState> _formKey = GlobalKey();
  // final _cardData = StripeCard();
  final _stripeApi = StripeApi(StripePreferences.publicKey);

  @override
  Widget build(BuildContext context) {
    return _render();
  }

  Widget _render() {
    return BlocProvider<PaymentMethodsBloc>(
        create: (context) {
          return _paymentMethodsBloc = PaymentMethodsBloc();
        },
        child: BlocListener<PaymentMethodsBloc, PaymentMethodsState>(
            listener: _listener,
            child: WillPopScope(
                onWillPop: () async => true, child: _renderFieldOnScreen())));
  }

  Widget _renderFieldOnScreen() {
    return BlocBuilder<PaymentMethodsBloc, PaymentMethodsState>(
        builder: (context, state) {
      return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Container(
              color: Colors.white,
              child: Scaffold(
                  resizeToAvoidBottomInset: false,
                  backgroundColor: azureRadianceColor,
                  body: _renderBody())));
    });
  }

  Widget _renderBody() {
    return SafeArea(
      bottom: false,
      child: Stack(children: [
        Container(color: blackHazeColor),
        Column(
          children: [_renderAppBar(),
            // _cardForm(),
            _renderNextButton()],
        ),
      ]),
    );
  }

  Widget _renderAppBar() {
    return AppBarWidget(
      backgroundColor: azureRadianceColor,
      titleText: 'Add payment method',
      titleStyle:
          getStyle(color: whiteColor, fontSize: 20, weight: FontWeight.w500),
      prefixWidget: InkWell(
        onTap: () => Navigator.pop(context),
        child: const Icon(
          Icons.arrow_back,
          color: whiteColor,
        ),
      ),
    );
  }

  Future<void> _addCard() async {
    try {
      if (_formKey.currentState != null) {
        final currentState = _formKey.currentState;
        if (currentState != null) {
          if (currentState.validate()) {
            currentState.save();
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                  strokeWidth: 2,
                ),
              ),
            );

            // final paymentMethod =
            //     await _stripeApi.createPaymentMethodFromCard(_cardData);
            //
            // _paymentMethodsBloc
            //     .add(AddPaymentMethodEvent(paymentMethod: paymentMethod));
          }
        }
      }
    } catch (e) {
      _paymentMethodsBloc.add(FailedAddCardEvent());
      throw Exception('Something went wrong');
    }
  }

  // Widget _cardForm() {
  //   return Padding(
  //       padding: const EdgeInsets.all(16.0),
  //       child: CardForm(
  //         card: _cardData,
  //         formKey: _formKey,
  //       ));
  // }

  Widget _renderNextButton() {
    return NextButton(
        padding: EdgeInsets.only(top: 20 * constants.rh(context)),
        onPress: _addCard,
        text: 'Save',
        textColor: whiteColor);
  }

  void _listener(context, state) {
    if (state is AddedCardState) {
      AlertWidget(closeAction: () {
        Navigator.pop(context);
        Navigator.pop(context);
        if (widget.type == AddPaymentMethodType.initial) {
          Provider.of<PaymentMethodsNotifier>(context, listen: false)
              .hasPaymentMethods = true;
        }
      }).acceptAction(context, 'Card is added');
    }

    if (state is FailAddCardState || state is ServerSidePaymentErrorState) {
      AlertWidget(closeAction: () {
        Navigator.pop(context);
        Navigator.pop(context);
      }).cancelAction(context, 'Fail adding card');
    }
  }
}

enum AddPaymentMethodType { initial, fromList }
