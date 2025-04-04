import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sample_apps/src/middlewares/notifiers/payment_methods.dart';
import 'package:flutter_sample_apps/src/screens/profile/payment/payment_methods_adding_screen.dart';
import 'package:flutter_sample_apps/src/screens/profile/payment/payment_methods_bloc.dart';
import 'package:flutter_sample_apps/src/screens/profile/payment/payment_methods_event.dart';
import 'package:flutter_sample_apps/src/screens/profile/payment/payment_methods_state.dart';
import 'package:flutter_sample_apps/src/shared/alert_widget.dart';
import 'package:flutter_sample_apps/src/shared/app_bar_widget.dart';
import 'package:flutter_sample_apps/src/shared/loading_widget.dart';
import 'package:flutter_sample_apps/src/style.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stripe_sdk/stripe_sdk.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({Key? key}) : super(key: key);

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  PaymentMethodsBloc _paymentMethodsBloc = PaymentMethodsBloc();
  late List _paymentMethods = [];
  String? paymentMethodId = '';
  bool _hasLiveOrder = false;

  @override
  void initState() {
    super.initState();
    defaultCardId();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PaymentMethodsBloc>(
      create: (context) {
        _paymentMethodsBloc = PaymentMethodsBloc();
        _paymentMethodsBloc.add(ShowPaymentMethodsEvent());

        return _paymentMethodsBloc;
      },
      child: BlocListener<PaymentMethodsBloc, PaymentMethodsState>(
        listener: listener,
        child: BlocBuilder<PaymentMethodsBloc, PaymentMethodsState>(
          builder: (context, state) {
            _paymentMethodsBloc.add(const CheckLiveOrderEvent());

            _paymentMethods = _paymentMethodsBloc.getPaymentMethods();

            return WillPopScope(
              onWillPop: () async => true,
              child: LoadingWidget(
                  isLoading: state is PaymentMethodsLoadingState,
                  child: _render(context)),
            );
          },
        ),
      ),
    );
  }

  Widget _render(BuildContext context) {
    return Scaffold(
      backgroundColor: azureRadianceColor,
      body: _renderBody(context),
    );
  }

  Widget _renderAppBar() {
    return AppBarWidget(
      backgroundColor: azureRadianceColor,
      titleText: 'Payment methods',
      suffixWidget: InkWell(
        onTap: () => _addPaymentMethod(),
        child: const Icon(
          Icons.add,
          color: whiteColor,
        ),
      ),
      titleStyle:
          getStyle(color: whiteColor, fontSize: 20, weight: FontWeight.w500),
      prefixWidget: InkWell(
        onTap: _onPreviusPageAction,
        child: const Icon(
          Icons.arrow_back,
          color: whiteColor,
        ),
      ),
    );
  }

  Widget _renderBody(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Stack(children: [
        Container(color: blackHazeColor),
        Column(
          children: [_renderAppBar(), _renderPaymentItems(context)],
        ),
      ]),
    );
  }

  Widget _renderPaymentItems(BuildContext context) {
    return Expanded(
      child: RefreshIndicator(
        onRefresh: () async {
          await _paymentMethodsBloc.refreshPaymentMethods();
        },
        child: ListView.builder(
            itemCount: _paymentMethods.length,
            itemBuilder: (BuildContext context, int index) {
              final card = _paymentMethods[index];

              return ListTile(
                onLongPress: () => _longPressOnDelete(index),
                onTap: () {
                  setState(() {
                    _getCardId();
                  });
                },
                subtitle: Text(card.last4),
                title: Text(card.brand),
                leading: const Icon(Icons.credit_card),
                trailing:
                    card.id == paymentMethodId || _paymentMethods.length == 1
                        ? const Icon(Icons.check_circle)
                        : null,
              );
            }),
      ),
    );
  }

  Future<void> _deleteCard(
    BuildContext rootContext,
    CustomerSession stripeSession,
    // PaymentMethod card,
    List paymentMethods,
  ) async {
    return showDialog(
        barrierDismissible: false,
        context: rootContext,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Delete card'),
            content: const Text('Do you want to delete this card?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(rootContext),
                child: const Text('No'),
              ),
              TextButton(
                  onPressed: () async {
                    Navigator.pop(rootContext);
                    showDialog(
                        context: rootContext,
                        barrierDismissible: false,
                        builder: (rootContext) => const Center(
                                child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.black),
                              strokeWidth: 2,
                            )));

                    // await stripeSession.detachPaymentMethod(card.id);
                    _paymentMethodsBloc.add(const DeletePaymentMethodEvent());
                  },
                  child: const Text('Yes'))
            ],
          );
        });
  }

  Future<void> _showDelete(int index) async {
    final card = _paymentMethods[index];
    final stripeSession = CustomerSession.instance;

    final paymentMethods = _paymentMethodsBloc.getPaymentMethods();
    _deleteCard(context, stripeSession, card);
  }

  void _onPreviusPageAction() {
    Provider.of<PaymentMethodsNotifier>(context, listen: false)
        .hasPaymentMethods = _paymentMethods.isNotEmpty;
    Navigator.pop(context);
  }

  /// Checks if order is live then opens delete dialog
  void _longPressOnDelete(int index) {
    if (!_hasLiveOrder) {
      _showDelete(index);
    }
  }

  /// Returns current cards id
  Future<String?> _getCardId() async {
    // await _paymentMethodsBloc.set(card.id);
    paymentMethodId = await _getPaymentId();
    return null;
  }

  /// Sets current cards id
  Future<String?> _getPaymentId() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('defaultPaymentMethod') ?? '';
  }

  /// Updates payment screen after adding card
  Future<void> listener(BuildContext context, PaymentMethodsState state) async {
    if (state is DeletePaymentMethodState) {
      Navigator.pop(context);
    }
    if (state is ServerSidePaymentErrorState) {
      AlertWidget().showMessage(context, state.message);
    }
    if (state is LiveOrderState) {
      _hasLiveOrder = true;
    }
  }

  Future<void> _addPaymentMethod() async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const PaymentMethodsAddingScreen(
                type: AddPaymentMethodType.fromList)));
    _paymentMethodsBloc.add(RefreshPaymentMethodsEvent());
  }

  /// Returns default payment methods id
  Future<void> defaultCardId() async {
    paymentMethodId = await _getPaymentId();
  }
}
