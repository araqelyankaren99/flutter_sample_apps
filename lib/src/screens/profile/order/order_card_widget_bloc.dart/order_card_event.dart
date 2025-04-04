import 'package:equatable/equatable.dart';

abstract class OrderCardEvent extends Equatable {
  const OrderCardEvent();

  @override
  List<Object> get props => [];
}

class InvoicePdfEvent extends OrderCardEvent {
  const InvoicePdfEvent({required this.invoiceUrl});
  final String? invoiceUrl;
  @override
  List<Object> get props => [];
}
