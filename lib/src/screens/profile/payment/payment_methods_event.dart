import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

abstract class PaymentMethodsEvent extends Equatable {
  const PaymentMethodsEvent();

  @override
  List<Object> get props => [];
}

class AddPaymentMethodEvent extends PaymentMethodsEvent {
  const AddPaymentMethodEvent({required this.paymentMethod});
  final Map paymentMethod;
  @override
  List<Object> get props => [paymentMethod];
}

class ShowPaymentMethodsEvent extends PaymentMethodsEvent {
  ShowPaymentMethodsEvent();
  final String _id = const Uuid().v4();

  @override
  List<Object> get props => [_id];
}

class RefreshPaymentMethodsEvent extends PaymentMethodsEvent {
  RefreshPaymentMethodsEvent();
  final String _id = const Uuid().v4();

  @override
  List<Object> get props => [_id];
}

class DeletePaymentMethodEvent extends PaymentMethodsEvent {
  const DeletePaymentMethodEvent();

  @override
  List<Object> get props => [];
}

class CheckLiveOrderEvent extends PaymentMethodsEvent {
  const CheckLiveOrderEvent();

  @override
  List<Object> get props => [];
}

class FailedAddCardEvent extends PaymentMethodsEvent {}
