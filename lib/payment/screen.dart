import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sample_apps/custom_input_widget.dart';
import 'package:flutter_sample_apps/payment/bloc/event.dart';
import 'package:flutter_sample_apps/payment/bloc/selector.dart';
import 'package:flutter_sample_apps/payment/bloc/state.dart';
import 'package:flutter_sample_apps/zip_code_input_widget.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';

import 'bloc/bloc.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late PaymentBloc _paymentBloc;

  @override
  void didChangeDependencies() {
    _paymentBloc = context.read<PaymentBloc>();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _paymentBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PaymentBloc, PaymentState>(
        listener: _paymentBlocListener,
        child:  Scaffold(
            body: _PaymentScreenBody(),
          ),
    );
  }

  void _paymentBlocListener(BuildContext context, PaymentState state) {
    if (state is PaymentLoadingState) {
      // showLoader();
    }
    if (state is PaymentFailedState) {
      // context.showErrorDialog(
      //   errorMessage: state.errorMessage,
      //   statusCode: state.statusCode,
      // );
    }

    if (state is PaymentFinishedState) {
      // hideLoader();
    }
    if (state is PaymentSuccessState) {
      // final stepInfo = state.stepInfo;
      // final nextScreen = stepInfo.keys.first;
      // final arguments = stepInfo.values.first;
      // context.navigationController.pushAndRemoveUntil(
      //   pageName: nextScreen,
      //   arguments: arguments,
      // );
    }
  }
}

class _PaymentScreenBody extends StatelessWidget {
  const _PaymentScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 47),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PaymentInfoHeaderWidget(),
                  _PaymentInputsWidget(),
                  _PayButtonWidget(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PaymentInfoHeaderWidget extends StatelessWidget {
  const _PaymentInfoHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50),
      child: Text(
        'headerText',
      ),
    );
  }
}

class _PaymentInputsWidget extends StatelessWidget {
  const _PaymentInputsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StripeCardFieldWidget(),
          _CardHolderNameInputWidget(),
           Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: _CardBillingAddressInputWidget()),
                Expanded(child: _CardBillingUnitAptInputWidget()),
              ],
            ),
          _ZipCodeSectionWidget(),
        ],
      ),
    );
  }
}

class _StripeCardFieldWidget extends StatelessWidget {
  const _StripeCardFieldWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: const CardField(
        style: TextStyle(
          // borderColor: Colors.grey.shade300,
          // borderRadius: 8,
          color: Colors.black87,
        ),
        autofocus: false,
      ),
    );
  }
}

class _CardHolderNameInputWidget extends StatelessWidget {
  const _CardHolderNameInputWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomInputWidget(
      hasError: false,
      hintText: 'cCardNameHintText',
      onChanged: (holderName) => _onChanged(context, holderName),
    );
  }

  void _onChanged(BuildContext context, String holderName) {
    context
        .read<PaymentBloc>()
        .add(ChangeCreditCardHolderNameEvent(holderName: holderName));
  }
}

class _CardBillingAddressInputWidget extends StatelessWidget {
  const _CardBillingAddressInputWidget({super.key});

  @override
  Widget build(BuildContext context) {

    return CustomInputWidget(
      hintText: 'cCardAddressHintText',
      hasError: false,
      onChanged: (billingAddress) => _onChanged(context, billingAddress),
    );
  }

  void _onChanged(BuildContext context, String billingAddress) {
    context.read<PaymentBloc>().add(
      ChangeCreditCardBillingAddressEvent(billingAddress: billingAddress),
    );
  }
}

class _CardBillingUnitAptInputWidget extends StatelessWidget {
  const _CardBillingUnitAptInputWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomInputWidget(
      hintText: 'cUnitAptHintText',
      onChanged: (unitApt) => _onChanged(context, unitApt),
    );
  }

  void _onChanged(BuildContext context, String unitApt) {
    context
        .read<PaymentBloc>()
        .add(ChangeCreditCardUnitAptEvent(unitApt: unitApt));
  }
}

class _PayButtonWidget extends StatelessWidget {
  const _PayButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: ElevatedButton(
        onPressed: () => _onTap(context),
        child: Text('100\$'),
      ),
    );
  }

  void _onTap(BuildContext context) {
    context.read<PaymentBloc>().add(const PayForServiceEvent());
  }
}

class _ZipCodeSectionWidget extends StatelessWidget {
  const _ZipCodeSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final hasZipCodeError =
    PaymentSelector.hasCreditCardZipCodeErrorSelector(context);
    final hasCreditCardZipCodeEmptyError =
    PaymentSelector.hasCreditCardZipCodeEmptyErrorSelector(context);

    final hasCityError =
    PaymentSelector.hasCreditCardCityErrorSelector(context);

    final hasStateError =
    PaymentSelector.hasCreditCardStateErrorSelector(context);
    final hasCardStateEmptyErrorSelector =
    PaymentSelector.hasCardStateEmptyErrorSelector(context);

    return ZipCodeInputWidget(
      onZipCodeChange: (zipCode) => _onZipCodeChange(context, zipCode),
      hasZipCodeError: hasZipCodeError,
      onCityChanged: (city) => _onCityChanged(context, city),
      hasCityError: hasCityError,
      onStateChanged: (state) => _onStateChanged(context, state),
      hasStateError: hasStateError,
      hasZipCodeEmptyError: hasCreditCardZipCodeEmptyError,
      hasAddressStateEmptyError: hasCardStateEmptyErrorSelector,
    );
  }

  void _onZipCodeChange(BuildContext context, String zipCode) {
    context
        .read<PaymentBloc>()
        .add(ChangeCreditCardZipCodeEvent(zipCode: zipCode));
  }

  void _onCityChanged(BuildContext context, String city) {
    context.read<PaymentBloc>().add(ChangeCreditCardCityEvent(city: city));
  }

  void _onStateChanged(BuildContext context, String addressState) {
    context
        .read<PaymentBloc>()
        .add(ChangeCreditCardStateEvent(addressState: addressState));
  }
}
