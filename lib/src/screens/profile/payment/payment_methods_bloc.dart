import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sample_apps/src/middlewares/repositories/graph_ql_repository.dart';
import 'package:flutter_sample_apps/src/screens/profile/payment/payment_methods_event.dart';
import 'package:flutter_sample_apps/src/screens/profile/payment/payment_methods_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stripe_sdk/stripe_sdk.dart';

class PaymentMethodsBloc extends Bloc<PaymentMethodsEvent, PaymentMethodsState> {
  PaymentMethodsBloc() : super(PaymentMethodsInitialState()) {
    on<FailedAddCardEvent>((_, emit) => emit(FailAddCardState()));
    on<ShowPaymentMethodsEvent>(_onShowPaymentMethods);
    on<AddPaymentMethodEvent>(_onAddPaymentMethod);
    on<RefreshPaymentMethodsEvent>(_onRefreshPaymentMethods);
    on<DeletePaymentMethodEvent>(_onDeletePaymentMethod);
    on<CheckLiveOrderEvent>(_onCheckLiveOrder);
  }

  List _paymentMethods = [];
  List get paymentMethods => _paymentMethods;

  final _graphQlRepository = GraphQlRepository();
  bool _liveOrder = false;

  Future<void> _onAddPaymentMethod(
      AddPaymentMethodEvent event,
      Emitter<PaymentMethodsState> emit,
      ) async {
    initCustomer();
    try {
      final paymentMethod =
      await CustomerSession.instance.attachPaymentMethod(event.paymentMethod['id']);

      _paymentMethods.add(paymentMethod);

      if (_paymentMethods.isEmpty) {
        emit(FailAddCardState());
      } else {
        emit(AddedCardState());
      }
    } catch (e) {
      emit(ServerSidePaymentErrorState(message: e.toString()));
    }
  }

  Future<void> _onRefreshPaymentMethods(
      RefreshPaymentMethodsEvent event,
      Emitter<PaymentMethodsState> emit,
      ) async {
    await refreshPaymentMethods();
    emit(RefreshPaymentMethodsState());
  }

  Future<void> _onDeletePaymentMethod(
      DeletePaymentMethodEvent event,
      Emitter<PaymentMethodsState> emit,
      ) async {
    await refreshPaymentMethods();
    emit(DeletePaymentMethodState());
  }

  Future<void> _onCheckLiveOrder(
      CheckLiveOrderEvent event,
      Emitter<PaymentMethodsState> emit,
      ) async {
    final preferences = await SharedPreferences.getInstance();
    final orderId = preferences.getString('order_id');

    try {
      if (orderId != null) {
        final _orderStatusState = await _graphQlRepository.getOrderStatusState(orderId);
        _liveOrder = _hasLiveOrder(_orderStatusState);
        emit(_liveOrder ? LiveOrderState() : NotLiveOrderState());
      } else {
        emit(NotLiveOrderState());
      }
    } catch (_) {
      emit(ServerSidePaymentErrorState(message: 'Something went wrong!'));
    }
  }

  Future<void> _onShowPaymentMethods(
      ShowPaymentMethodsEvent event,
      Emitter<PaymentMethodsState> emit,
      ) async {
    emit(PaymentMethodsLoadingState());
    await refreshPaymentMethods();
    emit(ShowPaymentMethodsState());
  }

  List getPaymentMethods() => _paymentMethods.isEmpty ? [] : _paymentMethods;

  Future<void> set(String newPaymentMethod) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('defaultPaymentMethod', newPaymentMethod);
  }

  void initCustomer() {
    CustomerSession.initCustomerSession((_) => _graphQlRepository.getEphemeralKey());
  }

  bool _hasLiveOrder(String status) {
    return ['ON ROAD', 'WAITING', 'UNCONFIRMED', 'ACCEPTED'].contains(status);
  }

  Future<void> refreshPaymentMethods() async {
    initCustomer();
    final session = CustomerSession.instance;
    final value = await session.listPaymentMethods();
    final listData = value['data'] ?? <PaymentMethod>[];

    _paymentMethods = listData.isEmpty
        ? []
        : listData.map((item) => PaymentMethod(
        item['id'], item['card']['last4'], item['card']['brand'])).toList();
  }
}

class PaymentMethod {
  PaymentMethod(this.id, this.last4, this.brand);

  final String id;
  final String last4;
  final String brand;
}
