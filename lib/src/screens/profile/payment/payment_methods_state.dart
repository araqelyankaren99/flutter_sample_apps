import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

abstract class PaymentMethodsState extends Equatable {
  @override
  List<Object> get props => [];
}

class PaymentMethodsInitialState extends PaymentMethodsState {
  PaymentMethodsInitialState();

  @override
  List<Object> get props => [];
}

class PaymentMethodsLoadingState extends PaymentMethodsState {
  PaymentMethodsLoadingState();

  @override
  List<Object> get props => [];
}

class ShowPaymentMethodsState extends PaymentMethodsState {
  ShowPaymentMethodsState();
  final String _id = const Uuid().v4();

  @override
  List<Object> get props => [_id];
}

class AddedCardState extends PaymentMethodsState {
  AddedCardState();

  @override
  List<Object> get props => [];
}

class RefreshPaymentMethodsState extends PaymentMethodsState {
  RefreshPaymentMethodsState();
  final String _id = const Uuid().v4();

  @override
  List<Object> get props => [_id];
}

class FailAddCardState extends PaymentMethodsState {
  FailAddCardState();

  @override
  List<Object> get props => [];
}

class AddingCardCanceledState extends PaymentMethodsState {
  AddingCardCanceledState();

  @override
  List<Object> get props => [];
}

class CanNotDeleteCardState extends PaymentMethodsState {
  CanNotDeleteCardState();

  @override
  List<Object> get props => [];
}

class DeletePaymentMethodState extends PaymentMethodsState {
  DeletePaymentMethodState();
  final String _id = const Uuid().v4();

  @override
  List<Object> get props => [_id];
}

class LiveOrderState extends PaymentMethodsState {
  LiveOrderState();

  @override
  List<Object> get props => [];
}

class NotLiveOrderState extends PaymentMethodsState {
  NotLiveOrderState();

  @override
  List<Object> get props => [];
}

class ServerSidePaymentErrorState extends PaymentMethodsState {
  ServerSidePaymentErrorState({required this.message});
  final String message;

  @override
  List<Object> get props => [message];
}
