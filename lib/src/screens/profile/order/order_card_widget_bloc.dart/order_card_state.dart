import 'package:equatable/equatable.dart';

abstract class OrderCardState extends Equatable {
  @override
  List<Object> get props => [];
}

class OrderCardInitialState extends OrderCardState {
  @override
  List<Object> get props => [];
}

class InvoicePdfLoaded extends OrderCardState {
  InvoicePdfLoaded();

  @override
  List<Object> get props => [];
}

class InvoicePdfLoadError extends OrderCardState {
  InvoicePdfLoadError();

  @override
  List<Object> get props => [];
}

class OrderCardLoadingState extends OrderCardState {
  OrderCardLoadingState();

  @override
  List<Object> get props => [];
}
