import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sample_apps/src/middlewares/repositories/graph_ql_repository.dart';
import 'package:flutter_sample_apps/src/screens/profile/payment/payment_methods_event.dart';
import 'package:flutter_sample_apps/src/screens/profile/payment/payment_methods_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stripe_sdk/stripe_sdk.dart';

class PaymentMethodsBloc
    extends Bloc<PaymentMethodsEvent, PaymentMethodsState> {
  PaymentMethodsBloc() : super(PaymentMethodsInitialState());

  List get paymentMethods => _paymentMethods;
  List _paymentMethods = [];
  final _graphQlRepository = GraphQlRepository();
  bool _liveOrder = false;

  @override
  Stream<PaymentMethodsState> mapEventToState(
    PaymentMethodsEvent event,
  ) async* {
    if (event is FailedAddCardEvent) {
      yield FailAddCardState();
    }

    if (event is ShowPaymentMethodsEvent) {
      yield* showPaymentMethodsEventToState(event);
    }
    if (event is AddPaymentMethodEvent) {
      yield* addPaymentMethodEventToState(event);
    }
    if (event is RefreshPaymentMethodsEvent) {
      yield* refreshPaymentMethodsEventToState(event);
    }
    if (event is DeletePaymentMethodEvent) {
      yield* deletePaymentMethodEventToState(event);
    }
    if (event is CheckLiveOrderEvent) {
      yield* checkLiveOrderEventToState(event);
    }
  }

  Stream<PaymentMethodsState> addPaymentMethodEventToState(
      AddPaymentMethodEvent event) async* {
    initCustomer();
    final stripeSession = CustomerSession.instance;
    try {
      final paymentMethod =
          await stripeSession.attachPaymentMethod(event.paymentMethod['id']);

      paymentMethods.add(paymentMethod);

      if (paymentMethods.isEmpty) {
        yield FailAddCardState();
      }
      yield AddedCardState();
    } on Exception catch (e) {
      yield ServerSidePaymentErrorState(message: e.toString());
      throw Exception('Something went wrong');
    }
  }

  Stream<PaymentMethodsState> refreshPaymentMethodsEventToState(
      RefreshPaymentMethodsEvent event) async* {
    await refreshPaymentMethods();
    yield RefreshPaymentMethodsState();
  }

  Stream<PaymentMethodsState> deletePaymentMethodEventToState(
      DeletePaymentMethodEvent event) async* {
    await refreshPaymentMethods();
    yield DeletePaymentMethodState();
  }

  Stream<PaymentMethodsState> checkLiveOrderEventToState(
      CheckLiveOrderEvent event) async* {
    final preferences = await SharedPreferences.getInstance();
    final orderId = preferences.getString('order_id');
    try {
      if (orderId != null) {
        final _orderStatusState =
            await _graphQlRepository.getOrderStatusState(orderId);
        _liveOrder = _hasLiveOrder(_orderStatusState);
        if (_liveOrder) {
          yield LiveOrderState();
        } else {
          yield NotLiveOrderState();
        }
      } else {
        yield NotLiveOrderState();
      }
    } catch (e) {
      yield ServerSidePaymentErrorState(message: 'Something went wrong!');
      throw Exception('Something went wrong!');
    }
  }

  Stream<PaymentMethodsState> showPaymentMethodsEventToState(
      ShowPaymentMethodsEvent event) async* {
    yield PaymentMethodsLoadingState();
    await refreshPaymentMethods();

    yield ShowPaymentMethodsState();
  }

  ///Returns existing payment methods
  List getPaymentMethods() {
    final _paymentMethodsList = paymentMethods;
    return _paymentMethodsList.isEmpty ? [] : _paymentMethodsList;
  }

  ///Returns current payment methods id
  Future<void> set(String newPaymentMethod) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('defaultPaymentMethod', newPaymentMethod);
  }

  /// This function creates customer seesion based on ephemeral key
  void initCustomer() {
    CustomerSession.initCustomerSession(
        (_) => GraphQlRepository().getEphemeralKey());
  }

  bool _hasLiveOrder(String _orderStatusState) {
    return _orderStatusState == 'ON ROAD' ||
        _orderStatusState == 'WAITING' ||
        _orderStatusState == 'UNCONFIRMED' ||
        _orderStatusState == 'ACCEPTED';
  }

  /// Refreshs payment methods list
  Future<void> refreshPaymentMethods() async {
    initCustomer();
    final session = CustomerSession.instance;
    await session.listPaymentMethods().then((value) {
      final List listData = value['data'] ?? <PaymentMethod>[];
      _paymentMethods = listData.isEmpty
          ? []
          : listData
              .map((item) => PaymentMethod(
                  item['id'], item['card']['last4'], item['card']['brand']))
              .toList();
    });
  }
}

class PaymentMethod {
  PaymentMethod(this.id, this.last4, this.brand);

  final String id;
  final String last4;
  final String brand;
}
